#!/bin/bash
# Conductor Workspace Setup Script (Universal)
# Auto-detects project type and configures accordingly
set -e

echo "=== Conductor Workspace Setup ==="
echo "Workspace: $CONDUCTOR_WORKSPACE_NAME"
echo "Root: $CONDUCTOR_ROOT_PATH"
echo ""

# ------------------------------------------------------------------------------
# Helper: Symlink file from root if it exists
# ------------------------------------------------------------------------------
link_from_root() {
    local filename="$1"
    local source="$CONDUCTOR_ROOT_PATH/$filename"
    local target="./$filename"

    if [ -L "$target" ]; then
        echo "  [skip] $filename (symlink exists)"
    elif [ -f "$target" ]; then
        echo "  [skip] $filename (file exists)"
    elif [ -f "$source" ]; then
        ln -sf "$source" "$target"
        echo "  [link] $filename"
    else
        echo "  [miss] $filename (not in root)"
    fi
}

# Helper: Symlink directory from root
link_dir_from_root() {
    local dirname="$1"
    local source="$CONDUCTOR_ROOT_PATH/$dirname"
    local target="./$dirname"

    if [ -L "$target" ]; then
        echo "  [skip] $dirname (symlink exists)"
    elif [ -d "$target" ]; then
        echo "  [skip] $dirname (directory exists)"
    elif [ -d "$source" ]; then
        ln -sf "$source" "$target"
        echo "  [link] $dirname"
    else
        echo "  [miss] $dirname (not in root)"
    fi
}

# ------------------------------------------------------------------------------
# Environment Files
# ------------------------------------------------------------------------------
echo "--- Environment files ---"
link_from_root ".env"
link_from_root ".env.local"      # Optional - only linked if exists in root
link_from_root ".env.vercel"     # Optional - only linked if exists in root
echo ""

# ------------------------------------------------------------------------------
# MCP Configuration
# ------------------------------------------------------------------------------
echo "--- MCP configuration ---"
link_from_root ".mcp.json"
echo ""

# ------------------------------------------------------------------------------
# Vercel Project Link
# ------------------------------------------------------------------------------
echo "--- Vercel project link ---"
link_dir_from_root ".vercel"
echo ""

# ------------------------------------------------------------------------------
# Claude Configuration (if exists)
# ------------------------------------------------------------------------------
echo "--- Claude configuration ---"
link_dir_from_root ".claude"
echo ""

# ------------------------------------------------------------------------------
# Install Dependencies (root level)
# ------------------------------------------------------------------------------
echo "--- Installing dependencies ---"
npm ci --prefer-offline 2>/dev/null || npm install
echo ""

# ------------------------------------------------------------------------------
# Prisma Client (root level)
# ------------------------------------------------------------------------------
echo "--- Prisma client ---"
if [ -f "prisma/schema.prisma" ]; then
    npx prisma generate
    echo "  [done] Generated Prisma client"
else
    echo "  [skip] No Prisma schema in root"
fi

# ------------------------------------------------------------------------------
# Auto-detect Monorepo: Setup subprojects
# Finds all directories with package.json (excluding node_modules)
# Each subproject gets its own env symlinks and npm install
# ------------------------------------------------------------------------------
echo ""
echo "--- Checking for subprojects ---"

# Auto-detect: find directories with package.json (depth 1, skip node_modules)
for subdir in */; do
    subdir="${subdir%/}"  # Remove trailing slash

    # Skip node_modules and hidden directories
    [[ "$subdir" == "node_modules" ]] && continue
    [[ "$subdir" == .* ]] && continue

    if [ -f "$subdir/package.json" ]; then
        echo "  [found] $subdir"

        # Link env files to subproject from root
        for envfile in .env .env.local .env.vercel; do
            if [ -f "$CONDUCTOR_ROOT_PATH/$subdir/$envfile" ]; then
                [ ! -L "$subdir/$envfile" ] && [ ! -f "$subdir/$envfile" ] && \
                    ln -sf "$CONDUCTOR_ROOT_PATH/$subdir/$envfile" "$subdir/$envfile"
            fi
        done

        # Install dependencies in subproject
        (cd "$subdir" && npm ci --prefer-offline 2>/dev/null || npm install)

        # Generate Prisma if exists
        if [ -f "$subdir/prisma/schema.prisma" ]; then
            (cd "$subdir" && npx prisma generate)
            echo "  [done] $subdir: Prisma generated"
        fi
    fi
done

echo ""

# ------------------------------------------------------------------------------
# Auto-generate conductor.json with correct run command
# Detects: Inngest (dev:all), monorepo (frontend subdir), or standard
# ------------------------------------------------------------------------------
echo "--- Detecting run configuration ---"

RUN_CMD=""
RUN_REASON=""

# Check 1: Does root package.json have dev:all? (Inngest projects)
if [ -f "package.json" ] && grep -q '"dev:all"' package.json 2>/dev/null; then
    RUN_CMD="npm run dev:all"
    RUN_REASON="Inngest detected (dev:all script)"

# Check 2: No root package.json? Find frontend subproject (monorepo)
elif [ ! -f "package.json" ]; then
    # Look for directories with Next.js (prioritize *-Frontend naming)
    for subdir in */; do
        subdir="${subdir%/}"
        [ ! -d "$subdir" ] && continue
        [[ "$subdir" == "node_modules" ]] && continue
        [[ "$subdir" == .* ]] && continue

        if [ -f "$subdir/package.json" ] && grep -q '"next"' "$subdir/package.json" 2>/dev/null; then
            # Prefer directories with "Frontend" in name
            if [[ "$subdir" == *Frontend* ]] || [[ "$subdir" == *frontend* ]]; then
                RUN_CMD="cd $subdir && npm run dev -- --port \$CONDUCTOR_PORT"
                RUN_REASON="Monorepo frontend: $subdir"
                break
            elif [ -z "$RUN_CMD" ]; then
                # First Next.js project found as fallback
                RUN_CMD="cd $subdir && npm run dev -- --port \$CONDUCTOR_PORT"
                RUN_REASON="Monorepo frontend: $subdir"
            fi
        fi
    done

    # Fallback for monorepo without detected frontend
    if [ -z "$RUN_CMD" ]; then
        RUN_CMD="echo 'No frontend detected - configure manually'"
        RUN_REASON="Monorepo (no frontend found)"
    fi

# Check 3: Standard Next.js project
else
    RUN_CMD="npm run dev -- --port \$CONDUCTOR_PORT"
    RUN_REASON="Standard project"
fi

echo "  [detected] $RUN_REASON"
echo "  [run cmd]  $RUN_CMD"

# Generate conductor.json
cat > conductor.json << EOF
{
  "scripts": {
    "setup": "./scripts/setup.sh",
    "run": "$RUN_CMD",
    "archive": "./scripts/archive.sh"
  },
  "runScriptMode": "nonconcurrent"
}
EOF
echo "  [wrote] conductor.json"

echo ""

# ------------------------------------------------------------------------------
# Done
# ------------------------------------------------------------------------------
echo "=== Setup Complete ==="
echo "Port range: $CONDUCTOR_PORT - \$((CONDUCTOR_PORT + 9))"

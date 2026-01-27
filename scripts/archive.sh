#!/bin/bash
# Conductor Workspace Archive Script
# Cleans up workspace-specific resources before deletion
set -e

echo "=== Archiving: $CONDUCTOR_WORKSPACE_NAME ==="

# Clean main workspace
echo "--- Cleaning root ---"
rm -rf node_modules .next .cache .turbo 2>/dev/null || true
echo "  [done] Removed node_modules, .next, .cache"

# Clean subprojects (auto-detect directories with node_modules)
echo "--- Cleaning subprojects ---"
for subdir in */; do
    subdir="${subdir%/}"
    [[ "$subdir" == "node_modules" ]] && continue
    [[ "$subdir" == .* ]] && continue

    if [ -d "$subdir/node_modules" ]; then
        rm -rf "$subdir/node_modules" "$subdir/.next" "$subdir/.cache" 2>/dev/null || true
        echo "  [done] Cleaned $subdir"
    fi
done

echo ""
echo "=== Archive Complete ==="

# @ainarsklavins/date-mcp

[![npm version](https://badge.fury.io/js/%40ainarsklavins%2Fdate-mcp.svg)](https://www.npmjs.com/package/@ainarsklavins/date-mcp)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

An MCP server that provides real-time date, time, and timezone information to AI assistants like Claude.

## Why Use This?

AI models don't inherently know the current date or time. This MCP server solves that by providing tools that return accurate, real-time temporal information.

## Quick Start

### Claude Code

Add to `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "date-mcp": {
      "command": "npx",
      "args": ["-y", "@ainarsklavins/date-mcp"]
    }
  }
}
```

### Claude Desktop

Add to your config file:

| OS | Path |
|----|------|
| macOS | `~/Library/Application Support/Claude/claude_desktop_config.json` |
| Windows | `%APPDATA%\Claude\claude_desktop_config.json` |

```json
{
  "mcpServers": {
    "date-mcp": {
      "command": "npx",
      "args": ["-y", "@ainarsklavins/date-mcp"]
    }
  }
}
```

<details>
<summary>Alternative: Global Installation</summary>

```bash
npm install -g @ainarsklavins/date-mcp
```

Then configure with just:
```json
{
  "mcpServers": {
    "date-mcp": {
      "command": "date-mcp"
    }
  }
}
```
</details>

## Available Tools

| Tool | Description | Read-only |
|------|-------------|-----------|
| `get-current-datetime` | Get current date/time with timezone | Yes |
| `get-day-of-week` | Get day name for any date | Yes |
| `get-timezone-info` | Get timezone offset and details | Yes |
| `format-date` | Format dates in various styles | Yes |

All tools are read-only and have no side effects.

### get-current-datetime

Returns the current date and time.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `timezone` | string | No | IANA timezone (e.g., `America/New_York`) |

**Example:**
```json
{
  "iso": "2024-12-15T14:30:00.000Z",
  "formatted": "12/15/2024, 9:30:00 AM",
  "timezone": "America/New_York",
  "timestamp": 1734272200000
}
```

### get-day-of-week

Returns the day of the week for a given date.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `date` | string | No | Date in YYYY-MM-DD format (defaults to today) |
| `locale` | string | No | Locale code (e.g., `en-US`, `de-DE`) |

**Example:**
```json
{
  "dayName": "Sunday",
  "dayNumber": 0,
  "date": "2024-12-15"
}
```

### get-timezone-info

Returns detailed timezone information.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `timezone` | string | No | IANA timezone name |

**Example:**
```json
{
  "timezone": "America/New_York",
  "offset": "GMT-05:00",
  "abbreviation": "EST",
  "currentTime": "12/15/2024, 9:30:00 AM"
}
```

### format-date

Formats a date in various styles.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `date` | string | No | Date in ISO format (defaults to today) |
| `style` | string | No | `short`, `medium`, `long`, or `full` |
| `locale` | string | No | Locale code (e.g., `en-US`, `fr-FR`) |

**Example:**
```json
{
  "formatted": "December 15, 2024",
  "style": "long",
  "locale": "en-US",
  "iso": "2024-12-15T00:00:00.000Z"
}
```

## Supported Timezones

Uses IANA timezone database. Common examples:
- `America/New_York`, `America/Los_Angeles`, `America/Chicago`
- `Europe/London`, `Europe/Paris`, `Europe/Berlin`
- `Asia/Tokyo`, `Asia/Shanghai`, `Asia/Singapore`
- `Australia/Sydney`
- `UTC`

Full list: [IANA Time Zone Database](https://www.iana.org/time-zones)

## Development

```bash
git clone https://github.com/ainarsklavins/date-mcp.git
cd date-mcp
npm install
npm run build
```

### Testing Locally

```bash
# Test with MCP Inspector
npx @modelcontextprotocol/inspector node dist/index.js

# Or add to Claude Code with direct path (see below)
```

**Local testing with Claude Code:**

Add to `~/.claude/settings.json`:
```json
{
  "mcpServers": {
    "date-mcp": {
      "command": "node",
      "args": ["/path/to/date-mcp/dist/index.js"]
    }
  }
}
```

## License

MIT - see [LICENSE](LICENSE)

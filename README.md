# @ainarsklavins/date-mcp

An MCP (Model Context Protocol) server that provides date, time, and timezone tools for Claude and other MCP-compatible clients.

## Why?

AI models often don't know the current date or time. This MCP server gives them accurate, real-time date/time information.

## Features

- **get-current-datetime** - Get current date and time with optional timezone
- **get-day-of-week** - Get day name and number for any date
- **get-timezone-info** - Get timezone offset, abbreviation, and details
- **format-date** - Format dates in short/medium/long/full styles

All tools support IANA timezone names (e.g., `America/New_York`, `Europe/London`, `UTC`).

## Installation

### For Claude Code (CLI)

Add to your Claude settings (`~/.claude/settings.json`):

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

### For Claude Desktop

Add to your `claude_desktop_config.json`:

**macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
**Windows:** `%APPDATA%\Claude\claude_desktop_config.json`

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

### Global Installation (Alternative)

```bash
npm install -g @ainarsklavins/date-mcp
```

Then configure:

```json
{
  "mcpServers": {
    "date-mcp": {
      "command": "date-mcp"
    }
  }
}
```

## Available Tools

### get-current-datetime

Returns the current date and time.

**Parameters:**
- `timezone` (optional): IANA timezone name

**Example Response:**
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
- `date` (optional): Date in YYYY-MM-DD format (defaults to today)
- `locale` (optional): Locale for day name (e.g., "en-US", "de-DE")

**Example Response:**
```json
{
  "dayName": "Sunday",
  "dayNumber": 0,
  "date": "2024-12-15"
}
```

### get-timezone-info

Returns timezone information.

**Parameters:**
- `timezone` (optional): IANA timezone name

**Example Response:**
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
- `date` (optional): Date in ISO format (defaults to today)
- `style` (optional): `short`, `medium`, `long`, or `full`
- `locale` (optional): Locale code (e.g., "en-US", "fr-FR")

**Example Response:**
```json
{
  "formatted": "December 15, 2024",
  "style": "long",
  "locale": "en-US",
  "iso": "2024-12-15T00:00:00.000Z"
}
```

## Supported Timezones

Common examples:
- `America/New_York`
- `America/Los_Angeles`
- `Europe/London`
- `Europe/Paris`
- `Asia/Tokyo`
- `Asia/Shanghai`
- `Australia/Sydney`
- `UTC`

See [IANA Time Zone Database](https://www.iana.org/time-zones) for the full list.

## Development

```bash
# Clone the repo
git clone https://github.com/ainarsklavins/date-mcp.git
cd date-mcp

# Install dependencies
npm install

# Build
npm run build

# Watch mode
npm run dev
```

## License

MIT

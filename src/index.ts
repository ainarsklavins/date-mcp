import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';

const server = new McpServer({
  name: '@ainarsklavins/date-mcp',
  version: '1.0.1'
});

// Tool 1: get-current-datetime
server.registerTool(
  'get-current-datetime',
  {
    title: 'Get Current Date and Time',
    description: 'Returns the current date and time. Optionally specify a timezone.',
    inputSchema: {
      timezone: z.string().optional().describe('IANA timezone (e.g., "America/New_York", "Europe/London", "UTC")')
    }
  },
  async ({ timezone }) => {
    const now = new Date();
    const tz = timezone || Intl.DateTimeFormat().resolvedOptions().timeZone;

    try {
      const formatted = now.toLocaleString('en-US', { timeZone: tz });
      return {
        content: [{
          type: 'text',
          text: JSON.stringify({
            iso: now.toISOString(),
            formatted,
            timezone: tz,
            timestamp: now.getTime()
          }, null, 2)
        }]
      };
    } catch {
      return {
        content: [{ type: 'text', text: `Error: Invalid timezone "${timezone}". Use IANA format like "America/New_York".` }],
        isError: true
      };
    }
  }
);

// Tool 2: get-day-of-week
server.registerTool(
  'get-day-of-week',
  {
    title: 'Get Day of Week',
    description: 'Returns the day of the week for a given date or today.',
    inputSchema: {
      date: z.string().optional().describe('Date in YYYY-MM-DD format (defaults to today)'),
      locale: z.string().optional().describe('Locale for day name (e.g., "en-US", "de-DE")')
    }
  },
  async ({ date, locale = 'en-US' }) => {
    const targetDate = date ? new Date(date + 'T00:00:00') : new Date();

    if (isNaN(targetDate.getTime())) {
      return {
        content: [{ type: 'text', text: 'Error: Invalid date format. Use YYYY-MM-DD.' }],
        isError: true
      };
    }

    try {
      return {
        content: [{
          type: 'text',
          text: JSON.stringify({
            dayName: targetDate.toLocaleDateString(locale, { weekday: 'long' }),
            dayNumber: targetDate.getDay(),
            date: targetDate.toISOString().split('T')[0]
          }, null, 2)
        }]
      };
    } catch {
      return {
        content: [{ type: 'text', text: `Error: Invalid locale "${locale}".` }],
        isError: true
      };
    }
  }
);

// Tool 3: get-timezone-info
server.registerTool(
  'get-timezone-info',
  {
    title: 'Get Timezone Information',
    description: 'Returns information about the current or specified timezone.',
    inputSchema: {
      timezone: z.string().optional().describe('IANA timezone name (e.g., "America/New_York")')
    }
  },
  async ({ timezone }) => {
    const tz = timezone || Intl.DateTimeFormat().resolvedOptions().timeZone;
    const now = new Date();

    try {
      const longFormatter = new Intl.DateTimeFormat('en-US', {
        timeZone: tz,
        timeZoneName: 'longOffset'
      });
      const shortFormatter = new Intl.DateTimeFormat('en-US', {
        timeZone: tz,
        timeZoneName: 'short'
      });

      const longParts = longFormatter.formatToParts(now);
      const shortParts = shortFormatter.formatToParts(now);

      const offset = longParts.find(p => p.type === 'timeZoneName')?.value || 'Unknown';
      const abbreviation = shortParts.find(p => p.type === 'timeZoneName')?.value || 'Unknown';

      return {
        content: [{
          type: 'text',
          text: JSON.stringify({
            timezone: tz,
            offset,
            abbreviation,
            currentTime: now.toLocaleString('en-US', { timeZone: tz })
          }, null, 2)
        }]
      };
    } catch {
      return {
        content: [{ type: 'text', text: `Error: Invalid timezone "${timezone}". Use IANA format.` }],
        isError: true
      };
    }
  }
);

// Tool 4: format-date
server.registerTool(
  'format-date',
  {
    title: 'Format Date',
    description: 'Format a date in various styles (short, medium, long, full).',
    inputSchema: {
      date: z.string().optional().describe('Date in ISO format (defaults to today)'),
      style: z.enum(['short', 'medium', 'long', 'full']).optional().describe('Date style'),
      locale: z.string().optional().describe('Locale code (e.g., "en-US", "fr-FR")')
    }
  },
  async ({ date, style = 'medium', locale = 'en-US' }) => {
    const targetDate = date ? new Date(date) : new Date();

    if (isNaN(targetDate.getTime())) {
      return {
        content: [{ type: 'text', text: 'Error: Invalid date format.' }],
        isError: true
      };
    }

    try {
      const styleMap: Record<string, 'short' | 'medium' | 'long' | 'full'> = {
        short: 'short',
        medium: 'medium',
        long: 'long',
        full: 'full'
      };

      return {
        content: [{
          type: 'text',
          text: JSON.stringify({
            formatted: targetDate.toLocaleDateString(locale, { dateStyle: styleMap[style] }),
            style,
            locale,
            iso: targetDate.toISOString()
          }, null, 2)
        }]
      };
    } catch {
      return {
        content: [{ type: 'text', text: `Error: Invalid locale "${locale}".` }],
        isError: true
      };
    }
  }
);

// Start the server
const transport = new StdioServerTransport();
await server.connect(transport);

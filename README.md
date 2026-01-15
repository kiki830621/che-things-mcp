# che-things-mcp

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-13.0%2B-blue)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org/)
[![MCP](https://img.shields.io/badge/MCP-Compatible-green.svg)](https://modelcontextprotocol.io/)

**Things 3 MCP server** - Native AppleScript integration for comprehensive task management.

---

## Features

- **37 tools** for comprehensive Things 3 management
- **Native AppleScript** integration for reliable data access
- **Universal Binary** supporting both Apple Silicon and Intel Macs
- **Zero dependencies** at runtime - just the binary

---

## Quick Start

### For Claude Desktop

#### Option A: MCPB One-Click Install (Recommended)

Download the latest `.mcpb` file from [Releases](https://github.com/kiki830621/che-things-mcp/releases) and double-click to install.

#### Option B: Manual Configuration

Edit `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "che-things-mcp": {
      "command": "/usr/local/bin/che-things-mcp"
    }
  }
}
```

### For Claude Code (CLI)

```bash
# Download the latest release
curl -L https://github.com/kiki830621/che-things-mcp/releases/latest/download/CheThingsMCP -o /usr/local/bin/che-things-mcp
chmod +x /usr/local/bin/che-things-mcp

# Add to Claude Code
claude mcp add che-things-mcp /usr/local/bin/che-things-mcp
```

### Build from Source (Optional)

```bash
git clone https://github.com/kiki830621/che-things-mcp.git
cd che-things-mcp
swift build -c release
```

On first use, macOS will prompt for **Automation** permission to control Things 3 - click "Allow".

---

## Authentication

Some operations (like checklist management) require a Things3 auth token.

### Getting your token

1. Open **Things3** → **Settings** (⌘,)
2. Go to **General** → **Enable Things URLs**
3. Click **Manage** and copy your token

### Configuration

**Claude Desktop** (`~/Library/Application Support/Claude/claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "che-things-mcp": {
      "command": "/usr/local/bin/che-things-mcp",
      "env": {
        "THINGS3_AUTH_TOKEN": "your-token-here"
      }
    }
  }
}
```

**Claude Code**:

```bash
claude mcp add che-things-mcp /usr/local/bin/che-things-mcp -e THINGS3_AUTH_TOKEN=your-token
```

You can also set the token at runtime using the `set_auth_token` tool.

---

## All 37 Tools

<details>
<summary><b>List Access (7)</b></summary>

| Tool | Description |
|------|-------------|
| `get_inbox` | Get all to-dos in the Inbox |
| `get_today` | Get all to-dos scheduled for Today |
| `get_upcoming` | Get all to-dos in the Upcoming list |
| `get_anytime` | Get all to-dos in the Anytime list |
| `get_someday` | Get all to-dos in the Someday list |
| `get_logbook` | Get completed to-dos from the Logbook |
| `get_projects` | Get all projects with details |

</details>

<details>
<summary><b>Task Operations (5)</b></summary>

| Tool | Description |
|------|-------------|
| `add_todo` | Create a new to-do with optional scheduling |
| `update_todo` | Update an existing to-do |
| `complete_todo` | Mark a to-do as completed or incomplete |
| `delete_todo` | Delete a to-do (moves to Trash) |
| `search_todos` | Search for to-dos by name or notes |

</details>

<details>
<summary><b>Project Operations (3)</b></summary>

| Tool | Description |
|------|-------------|
| `add_project` | Create a new project |
| `update_project` | Update an existing project |
| `delete_project` | Delete a project (moves to Trash) |

</details>

<details>
<summary><b>Areas & Tags (2)</b></summary>

| Tool | Description |
|------|-------------|
| `get_areas` | Get all areas |
| `get_tags` | Get all tags |

</details>

<details>
<summary><b>Move Operations (2)</b></summary>

| Tool | Description |
|------|-------------|
| `move_todo` | Move a to-do to a different list or project |
| `move_project` | Move a project to a different area |

</details>

<details>
<summary><b>UI Operations (4)</b></summary>

| Tool | Description |
|------|-------------|
| `show_todo` | Show a to-do in the Things 3 app |
| `show_project` | Show a project in the Things 3 app |
| `show_list` | Show a list in the Things 3 app |
| `show_quick_entry` | Open the Quick Entry panel |

</details>

<details>
<summary><b>Utility Operations (2)</b></summary>

| Tool | Description |
|------|-------------|
| `empty_trash` | Permanently delete all items in Trash |
| `get_selected_todos` | Get currently selected to-dos |

</details>

<details>
<summary><b>Advanced Queries (3)</b></summary>

| Tool | Description |
|------|-------------|
| `get_todos_in_project` | Get all to-dos in a specific project |
| `get_todos_in_area` | Get all to-dos in a specific area |
| `get_projects_in_area` | Get all projects in a specific area |

</details>

<details>
<summary><b>Batch Operations (5)</b></summary>

| Tool | Description |
|------|-------------|
| `create_todos_batch` | Create multiple to-dos in a single operation |
| `complete_todos_batch` | Mark multiple to-dos as completed |
| `delete_todos_batch` | Delete multiple to-dos |
| `move_todos_batch` | Move multiple to-dos to a different list/project |
| `update_todos_batch` | Update multiple to-dos |

Batch operations return detailed results:
```json
{
  "total": 3,
  "succeeded": 2,
  "failed": 1,
  "results": [
    {"index": 0, "success": true, "id": "ABC123"},
    {"index": 1, "success": true, "id": "DEF456"},
    {"index": 2, "success": false, "error": "To-do not found with ID: XYZ"}
  ]
}
```

</details>

<details>
<summary><b>Checklist Operations (2)</b></summary>

| Tool | Description |
|------|-------------|
| `add_checklist_items` | Add checklist items to an existing to-do |
| `set_checklist_items` | Replace all checklist items in a to-do |

> ⚠️ **API Limitation**: Due to Things 3's AppleScript limitations, checklist operations can only **add** or **replace** items. Reading existing checklist items or marking individual items as complete is not supported.

</details>

<details>
<summary><b>Auth Token (2)</b></summary>

| Tool | Description |
|------|-------------|
| `set_auth_token` | Set the Things3 auth token at runtime |
| `check_auth_status` | Check if auth token is configured |

</details>

---

## Usage Examples

```
"Show me my tasks for today"
"Add a todo called 'Review quarterly report' with due date tomorrow"
"Find all tasks related to 'marketing'"
"Mark the 'Submit expense report' task as done"
"Move task 'Buy groceries' to the Someday list"
"Show me all my areas"
```

---

## Scheduling Options

When creating or updating tasks:

- `today` - Schedule for today
- `tomorrow` - Schedule for tomorrow
- `evening` - Schedule for this evening
- `anytime` - Available anytime (clears scheduling)
- `someday` - Defer indefinitely
- Date string (e.g., `2024-12-25`) - Schedule for specific date

---

## Requirements

- macOS 13.0 (Ventura) or later
- [Things 3](https://culturedcode.com/things/) installed

---

## Privacy

This extension:
- Runs entirely locally on your Mac
- Does not transmit any data externally
- Only accesses Things 3 data through AppleScript
- See [PRIVACY.md](mcpb/PRIVACY.md) for full details

---

## Version History

| Version | Changes |
|---------|---------|
| v1.0.0 | **First stable release.** 37 tools with full i18n support. Fixed localization bug for non-English systems. |
| v0.4.1 | Fixed delete operations failing on localized Things3 (Chinese, Japanese, etc.) |
| v0.4.0 | Added auth token support for URL Scheme operations. Added 2 new tools: `set_auth_token`, `check_auth_status`. |
| v0.3.0 | Added 7 new tools: batch operations (5) and checklist support (2). Improved error messages with specific IDs. Added unit tests. |
| v0.2.0 | Added 13 new tools: areas, tags, move operations, UI controls, utility operations, advanced queries |
| v0.1.0 | Initial release with 15 tools |

---

## Related Projects

- [che-ical-mcp](https://github.com/kiki830621/che-ical-mcp) - MCP server for macOS Calendar & Reminders

---

## License

MIT

## Author

[Che Cheng](https://github.com/kiki830621)

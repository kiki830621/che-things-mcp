# che-things-mcp

A Swift-based MCP (Model Context Protocol) server for [Things 3](https://culturedcode.com/things/), the award-winning personal task manager for Mac.

## Features

- **28 tools** for comprehensive Things 3 management
- **Native AppleScript** integration for reliable data access
- **Universal Binary** supporting both Apple Silicon and Intel Macs
- **Zero dependencies** at runtime - just the binary

## Requirements

- macOS 13.0 (Ventura) or later
- [Things 3](https://culturedcode.com/things/) installed
- Automation permission for Claude Desktop to control Things 3

## Installation

### Claude Desktop

Add to your Claude Desktop configuration:

```json
{
  "mcpServers": {
    "che-things-mcp": {
      "command": "/path/to/CheThingsMCP"
    }
  }
}
```

### Claude Code

```bash
claude mcp add che-things-mcp /path/to/CheThingsMCP
```

### From Source

```bash
# Clone the repository
git clone https://github.com/kiki830621/che-things-mcp.git
cd che-things-mcp

# Build release binary
swift build -c release

# Binary location
.build/release/CheThingsMCP
```

## Available Tools

### List Access (7 tools)

| Tool | Description |
|------|-------------|
| `get_inbox` | Get all to-dos in the Inbox |
| `get_today` | Get all to-dos scheduled for Today |
| `get_upcoming` | Get all to-dos in the Upcoming list |
| `get_anytime` | Get all to-dos in the Anytime list |
| `get_someday` | Get all to-dos in the Someday list |
| `get_logbook` | Get completed to-dos from the Logbook |
| `get_projects` | Get all projects with details |

### Task Operations (5 tools)

| Tool | Description |
|------|-------------|
| `add_todo` | Create a new to-do with optional scheduling |
| `update_todo` | Update an existing to-do |
| `complete_todo` | Mark a to-do as completed or incomplete |
| `delete_todo` | Delete a to-do (moves to Trash) |
| `search_todos` | Search for to-dos by name or notes |

### Project Operations (3 tools)

| Tool | Description |
|------|-------------|
| `add_project` | Create a new project |
| `update_project` | Update an existing project |
| `delete_project` | Delete a project (moves to Trash) |

### Areas & Tags (2 tools)

| Tool | Description |
|------|-------------|
| `get_areas` | Get all areas |
| `get_tags` | Get all tags |

### Move Operations (2 tools)

| Tool | Description |
|------|-------------|
| `move_todo` | Move a to-do to a different list or project |
| `move_project` | Move a project to a different area |

### UI Operations (4 tools)

| Tool | Description |
|------|-------------|
| `show_todo` | Show a to-do in the Things 3 app |
| `show_project` | Show a project in the Things 3 app |
| `show_list` | Show a list in the Things 3 app |
| `show_quick_entry` | Open the Quick Entry panel |

### Utility Operations (2 tools)

| Tool | Description |
|------|-------------|
| `empty_trash` | Permanently delete all items in Trash |
| `get_selected_todos` | Get currently selected to-dos |

### Advanced Queries (3 tools)

| Tool | Description |
|------|-------------|
| `get_todos_in_project` | Get all to-dos in a specific project |
| `get_todos_in_area` | Get all to-dos in a specific area |
| `get_projects_in_area` | Get all projects in a specific area |

## Usage Examples

### Get Today's Tasks

```
"Show me my tasks for today"
```

### Create a New Task

```
"Add a todo called 'Review quarterly report' with due date tomorrow"
```

### Search Tasks

```
"Find all tasks related to 'marketing'"
```

### Complete a Task

```
"Mark the 'Submit expense report' task as done"
```

### Move Tasks

```
"Move task 'Buy groceries' to the Someday list"
```

### View Areas and Tags

```
"Show me all my areas"
"List all tags I have"
```

## Scheduling Options

When creating or updating tasks, you can use these scheduling options:

- `today` - Schedule for today
- `tomorrow` - Schedule for tomorrow
- `evening` - Schedule for this evening
- `anytime` - Available anytime (clears scheduling)
- `someday` - Defer indefinitely
- Date string (e.g., `2024-12-25`) - Schedule for specific date

## Building MCPB Package

To create a distributable MCPB package:

```bash
./scripts/build-mcpb.sh
```

This creates:
- Universal Binary (arm64 + x86_64)
- MCPB package in `mcpb/che-things-mcp.mcpb`

## Permissions

On first use, macOS will ask for permission to automate Things 3. Grant this permission in:

**System Settings → Privacy & Security → Automation**

## Architecture

```
che-things-mcp/
├── Package.swift           # Swift Package definition
├── Sources/CheThingsMCP/
│   ├── main.swift          # Entry point
│   ├── Server.swift        # MCP Server with 28 tools
│   └── Things/
│       └── ThingsManager.swift  # AppleScript wrapper
├── mcpb/
│   ├── manifest.json       # MCPB metadata
│   ├── icon.png           # Extension icon
│   ├── PRIVACY.md         # Privacy policy
│   └── server/
│       └── CheThingsMCP   # Universal binary
└── scripts/
    └── build-mcpb.sh      # Build script
```

## Privacy

This extension:
- Runs entirely locally on your Mac
- Does not transmit any data externally
- Only accesses Things 3 data through AppleScript
- See [PRIVACY.md](mcpb/PRIVACY.md) for full details

## Version History

| Version | Changes |
|---------|---------|
| v0.2.0 | Added 13 new tools: areas, tags, move operations, UI controls, utility operations, advanced queries |
| v0.1.0 | Initial release with 15 tools |

## Related Projects

- [che-ical-mcp](https://github.com/kiki830621/che-ical-mcp) - MCP server for macOS Calendar & Reminders

## License

MIT

## Author

[Che Cheng](https://github.com/kiki830621)

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.2] - 2026-01-15

### Changed
- **CLI syntax update**: Updated `claude mcp add` commands with correct `--scope user --transport stdio` syntax
- Documentation improvements

## [1.2.1] - 2026-01-15

### Added
- MCP protocol tests and integration tests
- Updated installation guide to recommend `~/bin/` over cloud-synced folders

### Changed
- Documentation improvements for installation

## [1.2.0] - 2026-01-14

### Changed
- **Performance optimization**: Batch property fetching (29x faster)
- **MCP fix**: Fixed event loop blocking - AppleScript now runs on background thread via DispatchQueue

## [1.1.1] - 2026-01-13

### Changed
- Simplified AppleScript syntax: use `list id` instead of `first list whose source type is`

## [1.1.0] - 2026-01-12

### Fixed
- **Complete i18n support**: Fixed all localization issues for built-in lists (Inbox, Today, Upcoming, etc.) using Things3 internal source types

## [1.0.0] - 2026-01-11

### Added
- **First stable release**: 37 tools with full i18n support
- Fixed localization bug for non-English systems

## [0.4.1] - 2026-01-10

### Fixed
- Delete operations failing on localized Things3 (Chinese, Japanese, etc.)

## [0.4.0] - 2026-01-09

### Added
- Auth token support for URL Scheme operations
- 2 new tools: `set_auth_token`, `check_auth_status`

## [0.3.0] - 2026-01-08

### Added
- 7 new tools: batch operations (5) and checklist support (2)
  - `create_todos_batch`
  - `complete_todos_batch`
  - `delete_todos_batch`
  - `move_todos_batch`
  - `update_todos_batch`
  - `add_checklist_items`
  - `set_checklist_items`

### Changed
- Improved error messages with specific IDs
- Added unit tests

## [0.2.0] - 2026-01-07

### Added
- 13 new tools:
  - Areas & Tags: `get_areas`, `get_tags`
  - Move operations: `move_todo`, `move_project`
  - UI controls: `show_todo`, `show_project`, `show_list`, `show_quick_entry`
  - Utility: `empty_trash`, `get_selected_todos`
  - Advanced queries: `get_todos_in_project`, `get_todos_in_area`, `get_projects_in_area`

## [0.1.0] - 2026-01-06

### Added
- Initial release with 15 tools
- List access: `get_inbox`, `get_today`, `get_upcoming`, `get_anytime`, `get_someday`, `get_logbook`, `get_projects`
- Task operations: `add_todo`, `update_todo`, `complete_todo`, `delete_todo`, `search_todos`
- Project operations: `add_project`, `update_project`, `delete_project`

---

## Tool Count by Version

| Version | Total Tools | New Tools |
|---------|-------------|-----------|
| 1.2.2   | 37          | Documentation update |
| 1.2.1   | 37          | Tests and documentation |
| 1.2.0   | 37          | Performance optimization |
| 1.1.1   | 37          | AppleScript simplification |
| 1.1.0   | 37          | i18n fixes |
| 1.0.0   | 37          | First stable release |
| 0.4.1   | 37          | Localization fix |
| 0.4.0   | 37          | +2 (auth token tools) |
| 0.3.0   | 35          | +7 (batch + checklist) |
| 0.2.0   | 28          | +13 (areas, tags, UI, queries) |
| 0.1.0   | 15          | Initial release |

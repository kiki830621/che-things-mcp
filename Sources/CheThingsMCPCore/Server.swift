import Foundation
import MCP

/// MCP Server for Things 3 integration
public class CheThingsMCPServer {
    private let server: Server
    private let transport: StdioTransport
    private let thingsManager = ThingsManager()

    /// All available tools
    private let tools: [Tool]

    public init() async throws {
        // Define all tools
        tools = Self.defineTools()

        // Create server with tools capability
        server = Server(
            name: "che-things-mcp",
            version: "0.3.0",
            capabilities: .init(tools: .init())
        )

        transport = StdioTransport()

        // Register handlers
        await registerHandlers()
    }

    public func run() async throws {
        try await server.start(transport: transport)
        await server.waitUntilCompleted()
    }

    // MARK: - Tool Definitions

    private static func defineTools() -> [Tool] {
        [
            // === List Access Tools (7) ===
            Tool(
                name: "get_inbox",
                description: "Get all to-dos in the Inbox. Returns tasks that haven't been scheduled or assigned to a project.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([:])
                ]),
                annotations: .init(readOnlyHint: true, openWorldHint: false)
            ),
            Tool(
                name: "get_today",
                description: "Get all to-dos scheduled for Today. Returns tasks due today or manually added to Today list.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([:])
                ]),
                annotations: .init(readOnlyHint: true, openWorldHint: false)
            ),
            Tool(
                name: "get_upcoming",
                description: "Get all to-dos in the Upcoming list. Returns tasks scheduled for future dates.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([:])
                ]),
                annotations: .init(readOnlyHint: true, openWorldHint: false)
            ),
            Tool(
                name: "get_anytime",
                description: "Get all to-dos in the Anytime list. Returns tasks available to do anytime.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([:])
                ]),
                annotations: .init(readOnlyHint: true, openWorldHint: false)
            ),
            Tool(
                name: "get_someday",
                description: "Get all to-dos in the Someday list. Returns tasks deferred for the future.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([:])
                ]),
                annotations: .init(readOnlyHint: true, openWorldHint: false)
            ),
            Tool(
                name: "get_logbook",
                description: "Get completed to-dos from the Logbook. Returns recently completed tasks.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([:])
                ]),
                annotations: .init(readOnlyHint: true, openWorldHint: false)
            ),
            Tool(
                name: "get_projects",
                description: "Get all projects. Returns project names, notes, status, and to-do counts.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([:])
                ]),
                annotations: .init(readOnlyHint: true, openWorldHint: false)
            ),

            // === Task Operations (5) ===
            Tool(
                name: "add_todo",
                description: "Create a new to-do in Things 3.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "name": .object([
                            "type": .string("string"),
                            "description": .string("The title of the to-do")
                        ]),
                        "notes": .object([
                            "type": .string("string"),
                            "description": .string("Optional notes for the to-do")
                        ]),
                        "due_date": .object([
                            "type": .string("string"),
                            "description": .string("Optional due date (e.g., '2024-12-25')")
                        ]),
                        "tags": .object([
                            "type": .string("array"),
                            "items": .object(["type": .string("string")]),
                            "description": .string("Optional list of tag names")
                        ]),
                        "list": .object([
                            "type": .string("string"),
                            "description": .string("Target list: 'Inbox', 'Today', 'Anytime', 'Someday'")
                        ]),
                        "project": .object([
                            "type": .string("string"),
                            "description": .string("Optional project name to add the to-do to")
                        ]),
                        "when": .object([
                            "type": .string("string"),
                            "description": .string("Schedule: 'today', 'tomorrow', 'evening', 'anytime', 'someday', or a date string")
                        ])
                    ]),
                    "required": .array([.string("name")])
                ]),
                annotations: .init(readOnlyHint: false, destructiveHint: false, openWorldHint: false)
            ),
            Tool(
                name: "update_todo",
                description: "Update an existing to-do.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "id": .object([
                            "type": .string("string"),
                            "description": .string("The to-do identifier")
                        ]),
                        "name": .object([
                            "type": .string("string"),
                            "description": .string("New title")
                        ]),
                        "notes": .object([
                            "type": .string("string"),
                            "description": .string("New notes")
                        ]),
                        "due_date": .object([
                            "type": .string("string"),
                            "description": .string("New due date")
                        ]),
                        "tags": .object([
                            "type": .string("array"),
                            "items": .object(["type": .string("string")]),
                            "description": .string("New tags (replaces existing)")
                        ]),
                        "when": .object([
                            "type": .string("string"),
                            "description": .string("Reschedule: 'today', 'tomorrow', 'anytime', 'someday', or date")
                        ])
                    ]),
                    "required": .array([.string("id")])
                ]),
                annotations: .init(readOnlyHint: false, destructiveHint: false, openWorldHint: false)
            ),
            Tool(
                name: "complete_todo",
                description: "Mark a to-do as completed or incomplete.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "id": .object([
                            "type": .string("string"),
                            "description": .string("The to-do identifier")
                        ]),
                        "completed": .object([
                            "type": .string("boolean"),
                            "description": .string("true to complete, false to uncomplete. Defaults to true.")
                        ])
                    ]),
                    "required": .array([.string("id")])
                ]),
                annotations: .init(readOnlyHint: false, destructiveHint: false, openWorldHint: false)
            ),
            Tool(
                name: "delete_todo",
                description: "Delete a to-do (moves to Trash).",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "id": .object([
                            "type": .string("string"),
                            "description": .string("The to-do identifier")
                        ])
                    ]),
                    "required": .array([.string("id")])
                ]),
                annotations: .init(readOnlyHint: false, destructiveHint: true, openWorldHint: false)
            ),
            Tool(
                name: "search_todos",
                description: "Search for to-dos by name or notes content.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "query": .object([
                            "type": .string("string"),
                            "description": .string("Search query to match against to-do names and notes")
                        ])
                    ]),
                    "required": .array([.string("query")])
                ]),
                annotations: .init(readOnlyHint: true, openWorldHint: false)
            ),

            // === Project Operations (3) ===
            Tool(
                name: "add_project",
                description: "Create a new project in Things 3.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "name": .object([
                            "type": .string("string"),
                            "description": .string("The name of the project")
                        ]),
                        "notes": .object([
                            "type": .string("string"),
                            "description": .string("Optional project notes")
                        ]),
                        "tags": .object([
                            "type": .string("array"),
                            "items": .object(["type": .string("string")]),
                            "description": .string("Optional list of tag names")
                        ]),
                        "area": .object([
                            "type": .string("string"),
                            "description": .string("Optional area name to add the project to")
                        ]),
                        "when": .object([
                            "type": .string("string"),
                            "description": .string("Schedule: 'today', 'anytime', 'someday', or date")
                        ])
                    ]),
                    "required": .array([.string("name")])
                ]),
                annotations: .init(readOnlyHint: false, destructiveHint: false, openWorldHint: false)
            ),
            Tool(
                name: "update_project",
                description: "Update an existing project.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "id": .object([
                            "type": .string("string"),
                            "description": .string("The project identifier")
                        ]),
                        "name": .object([
                            "type": .string("string"),
                            "description": .string("New name")
                        ]),
                        "notes": .object([
                            "type": .string("string"),
                            "description": .string("New notes")
                        ]),
                        "tags": .object([
                            "type": .string("array"),
                            "items": .object(["type": .string("string")]),
                            "description": .string("New tags (replaces existing)")
                        ])
                    ]),
                    "required": .array([.string("id")])
                ]),
                annotations: .init(readOnlyHint: false, destructiveHint: false, openWorldHint: false)
            ),
            Tool(
                name: "delete_project",
                description: "Delete a project (moves to Trash).",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "id": .object([
                            "type": .string("string"),
                            "description": .string("The project identifier")
                        ])
                    ]),
                    "required": .array([.string("id")])
                ]),
                annotations: .init(readOnlyHint: false, destructiveHint: true, openWorldHint: false)
            ),

            // === Areas & Tags (2) ===
            Tool(
                name: "get_areas",
                description: "Get all areas. Areas are used to organize projects and to-dos by life areas (e.g., Work, Personal).",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([:])
                ]),
                annotations: .init(readOnlyHint: true, openWorldHint: false)
            ),
            Tool(
                name: "get_tags",
                description: "Get all tags. Tags are labels that can be applied to to-dos and projects.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([:])
                ]),
                annotations: .init(readOnlyHint: true, openWorldHint: false)
            ),

            // === Move Operations (2) ===
            Tool(
                name: "move_todo",
                description: "Move a to-do to a different list or project.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "id": .object([
                            "type": .string("string"),
                            "description": .string("The to-do identifier")
                        ]),
                        "to_list": .object([
                            "type": .string("string"),
                            "description": .string("Target list: 'Inbox', 'Today', 'Anytime', 'Someday', 'Trash'")
                        ]),
                        "to_project": .object([
                            "type": .string("string"),
                            "description": .string("Target project name")
                        ])
                    ]),
                    "required": .array([.string("id")])
                ]),
                annotations: .init(readOnlyHint: false, destructiveHint: false, openWorldHint: false)
            ),
            Tool(
                name: "move_project",
                description: "Move a project to a different area.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "id": .object([
                            "type": .string("string"),
                            "description": .string("The project identifier")
                        ]),
                        "to_area": .object([
                            "type": .string("string"),
                            "description": .string("Target area name")
                        ])
                    ]),
                    "required": .array([.string("id"), .string("to_area")])
                ]),
                annotations: .init(readOnlyHint: false, destructiveHint: false, openWorldHint: false)
            ),

            // === UI Operations (4) ===
            Tool(
                name: "show_todo",
                description: "Show a to-do in the Things 3 app (brings it into view).",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "id": .object([
                            "type": .string("string"),
                            "description": .string("The to-do identifier")
                        ])
                    ]),
                    "required": .array([.string("id")])
                ]),
                annotations: .init(readOnlyHint: true, openWorldHint: true)
            ),
            Tool(
                name: "show_project",
                description: "Show a project in the Things 3 app (brings it into view).",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "id": .object([
                            "type": .string("string"),
                            "description": .string("The project identifier")
                        ])
                    ]),
                    "required": .array([.string("id")])
                ]),
                annotations: .init(readOnlyHint: true, openWorldHint: true)
            ),
            Tool(
                name: "show_list",
                description: "Show a list in the Things 3 app (e.g., Inbox, Today, Upcoming).",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "name": .object([
                            "type": .string("string"),
                            "description": .string("The list name: 'Inbox', 'Today', 'Upcoming', 'Anytime', 'Someday', 'Logbook', 'Trash'")
                        ])
                    ]),
                    "required": .array([.string("name")])
                ]),
                annotations: .init(readOnlyHint: true, openWorldHint: true)
            ),
            Tool(
                name: "show_quick_entry",
                description: "Open the Quick Entry panel in Things 3 with optional pre-filled content.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "name": .object([
                            "type": .string("string"),
                            "description": .string("Optional pre-filled to-do name")
                        ]),
                        "notes": .object([
                            "type": .string("string"),
                            "description": .string("Optional pre-filled notes")
                        ])
                    ])
                ]),
                annotations: .init(readOnlyHint: true, openWorldHint: true)
            ),

            // === Utility Operations (2) ===
            Tool(
                name: "empty_trash",
                description: "Permanently delete all items in the Trash. This action cannot be undone.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([:])
                ]),
                annotations: .init(readOnlyHint: false, destructiveHint: true, openWorldHint: false)
            ),
            Tool(
                name: "get_selected_todos",
                description: "Get the currently selected to-dos in the Things 3 app.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([:])
                ]),
                annotations: .init(readOnlyHint: true, openWorldHint: true)
            ),

            // === Advanced Queries (3) ===
            Tool(
                name: "get_todos_in_project",
                description: "Get all to-dos in a specific project.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "project_id": .object([
                            "type": .string("string"),
                            "description": .string("The project identifier")
                        ]),
                        "project_name": .object([
                            "type": .string("string"),
                            "description": .string("The project name (alternative to project_id)")
                        ])
                    ])
                ]),
                annotations: .init(readOnlyHint: true, openWorldHint: false)
            ),
            Tool(
                name: "get_todos_in_area",
                description: "Get all to-dos directly in a specific area (not in projects).",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "area_id": .object([
                            "type": .string("string"),
                            "description": .string("The area identifier")
                        ]),
                        "area_name": .object([
                            "type": .string("string"),
                            "description": .string("The area name (alternative to area_id)")
                        ])
                    ])
                ]),
                annotations: .init(readOnlyHint: true, openWorldHint: false)
            ),
            Tool(
                name: "get_projects_in_area",
                description: "Get all projects in a specific area.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "area_id": .object([
                            "type": .string("string"),
                            "description": .string("The area identifier")
                        ]),
                        "area_name": .object([
                            "type": .string("string"),
                            "description": .string("The area name (alternative to area_id)")
                        ])
                    ])
                ]),
                annotations: .init(readOnlyHint: true, openWorldHint: false)
            ),

            // === Batch Operations (5) ===
            Tool(
                name: "create_todos_batch",
                description: "Create multiple to-dos in a single operation. Returns detailed results for each item including successes and failures.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "items": .object([
                            "type": .string("array"),
                            "description": .string("Array of to-do objects to create. Each object can have: name (required), notes, due_date, tags, list, project, when"),
                            "items": .object([
                                "type": .string("object"),
                                "properties": .object([
                                    "name": .object(["type": .string("string")]),
                                    "notes": .object(["type": .string("string")]),
                                    "due_date": .object(["type": .string("string")]),
                                    "tags": .object(["type": .string("array"), "items": .object(["type": .string("string")])]),
                                    "list": .object(["type": .string("string")]),
                                    "project": .object(["type": .string("string")]),
                                    "when": .object(["type": .string("string")])
                                ]),
                                "required": .array([.string("name")])
                            ])
                        ])
                    ]),
                    "required": .array([.string("items")])
                ]),
                annotations: .init(readOnlyHint: false, destructiveHint: false, openWorldHint: false)
            ),
            Tool(
                name: "complete_todos_batch",
                description: "Mark multiple to-dos as completed or incomplete in a single operation.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "ids": .object([
                            "type": .string("array"),
                            "description": .string("Array of to-do identifiers to complete/uncomplete"),
                            "items": .object(["type": .string("string")])
                        ]),
                        "completed": .object([
                            "type": .string("boolean"),
                            "description": .string("true to mark as completed, false to uncomplete. Defaults to true.")
                        ])
                    ]),
                    "required": .array([.string("ids")])
                ]),
                annotations: .init(readOnlyHint: false, destructiveHint: false, openWorldHint: false)
            ),
            Tool(
                name: "delete_todos_batch",
                description: "Delete multiple to-dos in a single operation (moves to Trash).",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "ids": .object([
                            "type": .string("array"),
                            "description": .string("Array of to-do identifiers to delete"),
                            "items": .object(["type": .string("string")])
                        ])
                    ]),
                    "required": .array([.string("ids")])
                ]),
                annotations: .init(readOnlyHint: false, destructiveHint: true, openWorldHint: false)
            ),
            Tool(
                name: "move_todos_batch",
                description: "Move multiple to-dos to a different list or project in a single operation.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "ids": .object([
                            "type": .string("array"),
                            "description": .string("Array of to-do identifiers to move"),
                            "items": .object(["type": .string("string")])
                        ]),
                        "to_list": .object([
                            "type": .string("string"),
                            "description": .string("Target list: 'Inbox', 'Today', 'Anytime', 'Someday', 'Trash'")
                        ]),
                        "to_project": .object([
                            "type": .string("string"),
                            "description": .string("Target project name")
                        ])
                    ]),
                    "required": .array([.string("ids")])
                ]),
                annotations: .init(readOnlyHint: false, destructiveHint: false, openWorldHint: false)
            ),
            Tool(
                name: "update_todos_batch",
                description: "Update multiple to-dos in a single operation. Each item specifies which fields to update.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "updates": .object([
                            "type": .string("array"),
                            "description": .string("Array of update objects. Each must have 'id' and any fields to update: name, notes, due_date, tags, when"),
                            "items": .object([
                                "type": .string("object"),
                                "properties": .object([
                                    "id": .object(["type": .string("string")]),
                                    "name": .object(["type": .string("string")]),
                                    "notes": .object(["type": .string("string")]),
                                    "due_date": .object(["type": .string("string")]),
                                    "tags": .object(["type": .string("array"), "items": .object(["type": .string("string")])]),
                                    "when": .object(["type": .string("string")])
                                ]),
                                "required": .array([.string("id")])
                            ])
                        ])
                    ]),
                    "required": .array([.string("updates")])
                ]),
                annotations: .init(readOnlyHint: false, destructiveHint: false, openWorldHint: false)
            ),

            // === Checklist Operations (2) ===
            Tool(
                name: "add_checklist_items",
                description: "Add checklist items to an existing to-do. ⚠️ LIMITATION: Due to Things 3 API restrictions, this can only ADD items. It CANNOT read existing checklist items or mark them as complete.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "id": .object([
                            "type": .string("string"),
                            "description": .string("The to-do identifier")
                        ]),
                        "items": .object([
                            "type": .string("array"),
                            "description": .string("Array of checklist item strings to add"),
                            "items": .object(["type": .string("string")])
                        ])
                    ]),
                    "required": .array([.string("id"), .string("items")])
                ]),
                annotations: .init(readOnlyHint: false, destructiveHint: false, openWorldHint: true)
            ),
            Tool(
                name: "set_checklist_items",
                description: "Set (replace) all checklist items for a to-do. ⚠️ WARNING: This will REPLACE all existing checklist items! ⚠️ LIMITATION: Cannot read existing items beforehand.",
                inputSchema: .object([
                    "type": .string("object"),
                    "properties": .object([
                        "id": .object([
                            "type": .string("string"),
                            "description": .string("The to-do identifier")
                        ]),
                        "items": .object([
                            "type": .string("array"),
                            "description": .string("Array of checklist item strings (replaces existing)"),
                            "items": .object(["type": .string("string")])
                        ])
                    ]),
                    "required": .array([.string("id"), .string("items")])
                ]),
                annotations: .init(readOnlyHint: false, destructiveHint: true, openWorldHint: true)
            )
        ]
    }

    // MARK: - Handler Registration

    private func registerHandlers() async {
        await server.withMethodHandler(ListTools.self) { [tools] _ in
            ListTools.Result(tools: tools)
        }

        await server.withMethodHandler(CallTool.self) { [weak self] params in
            guard let self = self else {
                return CallTool.Result(content: [.text("Server error")])
            }
            return await self.executeToolCall(params)
        }
    }

    // MARK: - Tool Execution

    private func executeToolCall(_ params: CallTool.Parameters) async -> CallTool.Result {
        do {
            let result: String
            switch params.name {
            // List Access
            case "get_inbox":
                result = try await handleGetInbox()
            case "get_today":
                result = try await handleGetToday()
            case "get_upcoming":
                result = try await handleGetUpcoming()
            case "get_anytime":
                result = try await handleGetAnytime()
            case "get_someday":
                result = try await handleGetSomeday()
            case "get_logbook":
                result = try await handleGetLogbook()
            case "get_projects":
                result = try await handleGetProjects()

            // Task Operations
            case "add_todo":
                result = try await handleAddTodo(params.arguments)
            case "update_todo":
                result = try await handleUpdateTodo(params.arguments)
            case "complete_todo":
                result = try await handleCompleteTodo(params.arguments)
            case "delete_todo":
                result = try await handleDeleteTodo(params.arguments)
            case "search_todos":
                result = try await handleSearchTodos(params.arguments)

            // Project Operations
            case "add_project":
                result = try await handleAddProject(params.arguments)
            case "update_project":
                result = try await handleUpdateProject(params.arguments)
            case "delete_project":
                result = try await handleDeleteProject(params.arguments)

            // Areas & Tags
            case "get_areas":
                result = try await handleGetAreas()
            case "get_tags":
                result = try await handleGetTags()

            // Move Operations
            case "move_todo":
                result = try await handleMoveTodo(params.arguments)
            case "move_project":
                result = try await handleMoveProject(params.arguments)

            // UI Operations
            case "show_todo":
                result = try await handleShowTodo(params.arguments)
            case "show_project":
                result = try await handleShowProject(params.arguments)
            case "show_list":
                result = try await handleShowList(params.arguments)
            case "show_quick_entry":
                result = try await handleShowQuickEntry(params.arguments)

            // Utility Operations
            case "empty_trash":
                result = try await handleEmptyTrash()
            case "get_selected_todos":
                result = try await handleGetSelectedTodos()

            // Advanced Queries
            case "get_todos_in_project":
                result = try await handleGetTodosInProject(params.arguments)
            case "get_todos_in_area":
                result = try await handleGetTodosInArea(params.arguments)
            case "get_projects_in_area":
                result = try await handleGetProjectsInArea(params.arguments)

            // Batch Operations
            case "create_todos_batch":
                result = try await handleCreateTodosBatch(params.arguments)
            case "complete_todos_batch":
                result = try await handleCompleteTodosBatch(params.arguments)
            case "delete_todos_batch":
                result = try await handleDeleteTodosBatch(params.arguments)
            case "move_todos_batch":
                result = try await handleMoveTodosBatch(params.arguments)
            case "update_todos_batch":
                result = try await handleUpdateTodosBatch(params.arguments)

            // Checklist Operations
            case "add_checklist_items":
                result = try await handleAddChecklistItems(params.arguments)
            case "set_checklist_items":
                result = try await handleSetChecklistItems(params.arguments)

            default:
                return CallTool.Result(content: [.text("Unknown tool: \(params.name)")], isError: true)
            }
            return CallTool.Result(content: [.text(result)])
        } catch {
            return CallTool.Result(content: [.text("Error: \(error.localizedDescription)")], isError: true)
        }
    }

    // MARK: - List Access Handlers

    private func handleGetInbox() async throws -> String {
        let todos = try await thingsManager.getInbox()
        return formatTodosAsJSON(todos)
    }

    private func handleGetToday() async throws -> String {
        let todos = try await thingsManager.getToday()
        return formatTodosAsJSON(todos)
    }

    private func handleGetUpcoming() async throws -> String {
        let todos = try await thingsManager.getUpcoming()
        return formatTodosAsJSON(todos)
    }

    private func handleGetAnytime() async throws -> String {
        let todos = try await thingsManager.getAnytime()
        return formatTodosAsJSON(todos)
    }

    private func handleGetSomeday() async throws -> String {
        let todos = try await thingsManager.getSomeday()
        return formatTodosAsJSON(todos)
    }

    private func handleGetLogbook() async throws -> String {
        let todos = try await thingsManager.getLogbook()
        return formatTodosAsJSON(todos)
    }

    private func handleGetProjects() async throws -> String {
        let projects = try await thingsManager.getProjects()
        return formatProjectsAsJSON(projects)
    }

    // MARK: - Task Operation Handlers

    private func handleAddTodo(_ arguments: [String: Value]?) async throws -> String {
        guard let args = arguments,
              case .string(let name) = args["name"] else {
            throw ThingsError.invalidParameter("name is required")
        }

        var notes: String? = nil
        if case .string(let n) = args["notes"] { notes = n }

        var dueDate: String? = nil
        if case .string(let d) = args["due_date"] { dueDate = d }

        var tags: [String]? = nil
        if case .array(let t) = args["tags"] {
            tags = t.compactMap { if case .string(let s) = $0 { return s } else { return nil } }
        }

        var listName: String? = nil
        if case .string(let l) = args["list"] { listName = l }

        var projectName: String? = nil
        if case .string(let p) = args["project"] { projectName = p }

        var when: String? = nil
        if case .string(let w) = args["when"] { when = w }

        let todo = try await thingsManager.addTodo(
            name: name,
            notes: notes,
            dueDate: dueDate,
            tags: tags,
            listName: listName,
            projectName: projectName,
            when: when
        )

        return """
        {
            "success": true,
            "message": "To-do created successfully",
            "todo": \(formatTodoAsJSON(todo))
        }
        """
    }

    private func handleUpdateTodo(_ arguments: [String: Value]?) async throws -> String {
        guard let args = arguments,
              case .string(let id) = args["id"] else {
            throw ThingsError.invalidParameter("id is required")
        }

        var name: String? = nil
        if case .string(let n) = args["name"] { name = n }

        var notes: String? = nil
        if case .string(let n) = args["notes"] { notes = n }

        var dueDate: String? = nil
        if case .string(let d) = args["due_date"] { dueDate = d }

        var tags: [String]? = nil
        if case .array(let t) = args["tags"] {
            tags = t.compactMap { if case .string(let s) = $0 { return s } else { return nil } }
        }

        var when: String? = nil
        if case .string(let w) = args["when"] { when = w }

        try await thingsManager.updateTodo(id: id, name: name, notes: notes, dueDate: dueDate, tags: tags, when: when)

        return """
        {
            "success": true,
            "message": "To-do updated successfully"
        }
        """
    }

    private func handleCompleteTodo(_ arguments: [String: Value]?) async throws -> String {
        guard let args = arguments,
              case .string(let id) = args["id"] else {
            throw ThingsError.invalidParameter("id is required")
        }

        var completed = true
        if case .bool(let c) = args["completed"] { completed = c }

        try await thingsManager.completeTodo(id: id, completed: completed)

        return """
        {
            "success": true,
            "message": "To-do marked as \(completed ? "completed" : "incomplete")"
        }
        """
    }

    private func handleDeleteTodo(_ arguments: [String: Value]?) async throws -> String {
        guard let args = arguments,
              case .string(let id) = args["id"] else {
            throw ThingsError.invalidParameter("id is required")
        }

        try await thingsManager.deleteTodo(id: id)

        return """
        {
            "success": true,
            "message": "To-do moved to Trash"
        }
        """
    }

    private func handleSearchTodos(_ arguments: [String: Value]?) async throws -> String {
        guard let args = arguments,
              case .string(let query) = args["query"] else {
            throw ThingsError.invalidParameter("query is required")
        }

        let todos = try await thingsManager.searchTodos(query: query)
        return formatTodosAsJSON(todos)
    }

    // MARK: - Project Operation Handlers

    private func handleAddProject(_ arguments: [String: Value]?) async throws -> String {
        guard let args = arguments,
              case .string(let name) = args["name"] else {
            throw ThingsError.invalidParameter("name is required")
        }

        var notes: String? = nil
        if case .string(let n) = args["notes"] { notes = n }

        var tags: [String]? = nil
        if case .array(let t) = args["tags"] {
            tags = t.compactMap { if case .string(let s) = $0 { return s } else { return nil } }
        }

        var areaName: String? = nil
        if case .string(let a) = args["area"] { areaName = a }

        var when: String? = nil
        if case .string(let w) = args["when"] { when = w }

        let project = try await thingsManager.addProject(
            name: name,
            notes: notes,
            tags: tags,
            areaName: areaName,
            when: when
        )

        return """
        {
            "success": true,
            "message": "Project created successfully",
            "project": \(formatProjectAsJSON(project))
        }
        """
    }

    private func handleUpdateProject(_ arguments: [String: Value]?) async throws -> String {
        guard let args = arguments,
              case .string(let id) = args["id"] else {
            throw ThingsError.invalidParameter("id is required")
        }

        var name: String? = nil
        if case .string(let n) = args["name"] { name = n }

        var notes: String? = nil
        if case .string(let n) = args["notes"] { notes = n }

        var tags: [String]? = nil
        if case .array(let t) = args["tags"] {
            tags = t.compactMap { if case .string(let s) = $0 { return s } else { return nil } }
        }

        try await thingsManager.updateProject(id: id, name: name, notes: notes, tags: tags)

        return """
        {
            "success": true,
            "message": "Project updated successfully"
        }
        """
    }

    private func handleDeleteProject(_ arguments: [String: Value]?) async throws -> String {
        guard let args = arguments,
              case .string(let id) = args["id"] else {
            throw ThingsError.invalidParameter("id is required")
        }

        try await thingsManager.deleteProject(id: id)

        return """
        {
            "success": true,
            "message": "Project moved to Trash"
        }
        """
    }

    // MARK: - Areas & Tags Handlers

    private func handleGetAreas() async throws -> String {
        let areas = try await thingsManager.getAreas()
        return formatAreasAsJSON(areas)
    }

    private func handleGetTags() async throws -> String {
        let tags = try await thingsManager.getTags()
        return formatTagsAsJSON(tags)
    }

    // MARK: - Move Operation Handlers

    private func handleMoveTodo(_ arguments: [String: Value]?) async throws -> String {
        guard let args = arguments,
              case .string(let id) = args["id"] else {
            throw ThingsError.invalidParameter("id is required")
        }

        var toList: String? = nil
        if case .string(let l) = args["to_list"] { toList = l }

        var toProject: String? = nil
        if case .string(let p) = args["to_project"] { toProject = p }

        try await thingsManager.moveTodo(id: id, toList: toList, toProject: toProject)

        let destination = toProject ?? toList ?? "unknown"
        return """
        {
            "success": true,
            "message": "To-do moved to \(destination)"
        }
        """
    }

    private func handleMoveProject(_ arguments: [String: Value]?) async throws -> String {
        guard let args = arguments,
              case .string(let id) = args["id"],
              case .string(let toArea) = args["to_area"] else {
            throw ThingsError.invalidParameter("id and to_area are required")
        }

        try await thingsManager.moveProject(id: id, toArea: toArea)

        return """
        {
            "success": true,
            "message": "Project moved to area '\(toArea)'"
        }
        """
    }

    // MARK: - UI Operation Handlers

    private func handleShowTodo(_ arguments: [String: Value]?) async throws -> String {
        guard let args = arguments,
              case .string(let id) = args["id"] else {
            throw ThingsError.invalidParameter("id is required")
        }

        try await thingsManager.showTodo(id: id)

        return """
        {
            "success": true,
            "message": "To-do is now visible in Things 3"
        }
        """
    }

    private func handleShowProject(_ arguments: [String: Value]?) async throws -> String {
        guard let args = arguments,
              case .string(let id) = args["id"] else {
            throw ThingsError.invalidParameter("id is required")
        }

        try await thingsManager.showProject(id: id)

        return """
        {
            "success": true,
            "message": "Project is now visible in Things 3"
        }
        """
    }

    private func handleShowList(_ arguments: [String: Value]?) async throws -> String {
        guard let args = arguments,
              case .string(let name) = args["name"] else {
            throw ThingsError.invalidParameter("name is required")
        }

        try await thingsManager.showList(name: name)

        return """
        {
            "success": true,
            "message": "'\(name)' list is now visible in Things 3"
        }
        """
    }

    private func handleShowQuickEntry(_ arguments: [String: Value]?) async throws -> String {
        let args = arguments ?? [:]

        var name: String? = nil
        if case .string(let n) = args["name"] { name = n }

        var notes: String? = nil
        if case .string(let n) = args["notes"] { notes = n }

        try await thingsManager.showQuickEntry(name: name, notes: notes)

        return """
        {
            "success": true,
            "message": "Quick Entry panel opened"
        }
        """
    }

    // MARK: - Utility Operation Handlers

    private func handleEmptyTrash() async throws -> String {
        try await thingsManager.emptyTrash()

        return """
        {
            "success": true,
            "message": "Trash has been emptied"
        }
        """
    }

    private func handleGetSelectedTodos() async throws -> String {
        let todos = try await thingsManager.getSelectedTodos()
        return formatTodosAsJSON(todos)
    }

    // MARK: - Advanced Query Handlers

    private func handleGetTodosInProject(_ arguments: [String: Value]?) async throws -> String {
        let args = arguments ?? [:]

        var projectId: String? = nil
        if case .string(let id) = args["project_id"] { projectId = id }

        var projectName: String? = nil
        if case .string(let name) = args["project_name"] { projectName = name }

        let todos = try await thingsManager.getTodosInProject(projectId: projectId, projectName: projectName)
        return formatTodosAsJSON(todos)
    }

    private func handleGetTodosInArea(_ arguments: [String: Value]?) async throws -> String {
        let args = arguments ?? [:]

        var areaId: String? = nil
        if case .string(let id) = args["area_id"] { areaId = id }

        var areaName: String? = nil
        if case .string(let name) = args["area_name"] { areaName = name }

        let todos = try await thingsManager.getTodosInArea(areaId: areaId, areaName: areaName)
        return formatTodosAsJSON(todos)
    }

    private func handleGetProjectsInArea(_ arguments: [String: Value]?) async throws -> String {
        let args = arguments ?? [:]

        var areaId: String? = nil
        if case .string(let id) = args["area_id"] { areaId = id }

        var areaName: String? = nil
        if case .string(let name) = args["area_name"] { areaName = name }

        let projects = try await thingsManager.getProjectsInArea(areaId: areaId, areaName: areaName)
        return formatProjectsAsJSON(projects)
    }

    // MARK: - Batch Operation Handlers

    private func handleCreateTodosBatch(_ arguments: [String: Value]?) async throws -> String {
        guard let args = arguments,
              case .array(let itemsValue) = args["items"] else {
            throw ThingsError.invalidParameter("items array is required")
        }

        // Convert Value array to [[String: Any]]
        let items: [[String: Any]] = itemsValue.compactMap { value -> [String: Any]? in
            guard case .object(let obj) = value else { return nil }
            var dict: [String: Any] = [:]
            for (key, val) in obj {
                switch val {
                case .string(let s): dict[key] = s
                case .array(let arr):
                    dict[key] = arr.compactMap { if case .string(let s) = $0 { return s } else { return nil } }
                case .bool(let b): dict[key] = b
                case .int(let i): dict[key] = i
                case .double(let d): dict[key] = d
                default: break
                }
            }
            return dict
        }

        let result = await thingsManager.createTodosBatch(items: items)
        return formatBatchResultAsJSON(result)
    }

    private func handleCompleteTodosBatch(_ arguments: [String: Value]?) async throws -> String {
        guard let args = arguments,
              case .array(let idsValue) = args["ids"] else {
            throw ThingsError.invalidParameter("ids array is required")
        }

        let ids = idsValue.compactMap { if case .string(let s) = $0 { return s } else { return nil } }

        var completed = true
        if case .bool(let c) = args["completed"] { completed = c }

        let result = await thingsManager.completeTodosBatch(ids: ids, completed: completed)
        return formatBatchResultAsJSON(result)
    }

    private func handleDeleteTodosBatch(_ arguments: [String: Value]?) async throws -> String {
        guard let args = arguments,
              case .array(let idsValue) = args["ids"] else {
            throw ThingsError.invalidParameter("ids array is required")
        }

        let ids = idsValue.compactMap { if case .string(let s) = $0 { return s } else { return nil } }

        let result = await thingsManager.deleteTodosBatch(ids: ids)
        return formatBatchResultAsJSON(result)
    }

    private func handleMoveTodosBatch(_ arguments: [String: Value]?) async throws -> String {
        guard let args = arguments,
              case .array(let idsValue) = args["ids"] else {
            throw ThingsError.invalidParameter("ids array is required")
        }

        let ids = idsValue.compactMap { if case .string(let s) = $0 { return s } else { return nil } }

        var toList: String? = nil
        if case .string(let l) = args["to_list"] { toList = l }

        var toProject: String? = nil
        if case .string(let p) = args["to_project"] { toProject = p }

        let result = await thingsManager.moveTodosBatch(ids: ids, toList: toList, toProject: toProject)
        return formatBatchResultAsJSON(result)
    }

    private func handleUpdateTodosBatch(_ arguments: [String: Value]?) async throws -> String {
        guard let args = arguments,
              case .array(let updatesValue) = args["updates"] else {
            throw ThingsError.invalidParameter("updates array is required")
        }

        // Convert Value array to [[String: Any]]
        let updates: [[String: Any]] = updatesValue.compactMap { value -> [String: Any]? in
            guard case .object(let obj) = value else { return nil }
            var dict: [String: Any] = [:]
            for (key, val) in obj {
                switch val {
                case .string(let s): dict[key] = s
                case .array(let arr):
                    dict[key] = arr.compactMap { if case .string(let s) = $0 { return s } else { return nil } }
                case .bool(let b): dict[key] = b
                case .int(let i): dict[key] = i
                case .double(let d): dict[key] = d
                default: break
                }
            }
            return dict
        }

        let result = await thingsManager.updateTodosBatch(updates: updates)
        return formatBatchResultAsJSON(result)
    }

    // MARK: - Checklist Operation Handlers

    private func handleAddChecklistItems(_ arguments: [String: Value]?) async throws -> String {
        guard let args = arguments,
              case .string(let id) = args["id"],
              case .array(let itemsValue) = args["items"] else {
            throw ThingsError.invalidParameter("id and items are required")
        }

        let items = itemsValue.compactMap { if case .string(let s) = $0 { return s } else { return nil } }

        try await thingsManager.addChecklistItems(todoId: id, items: items)

        return """
        {
            "success": true,
            "message": "Added \(items.count) checklist item(s) to to-do",
            "note": "Due to API limitations, checklist items cannot be read back. Open Things 3 to verify."
        }
        """
    }

    private func handleSetChecklistItems(_ arguments: [String: Value]?) async throws -> String {
        guard let args = arguments,
              case .string(let id) = args["id"],
              case .array(let itemsValue) = args["items"] else {
            throw ThingsError.invalidParameter("id and items are required")
        }

        let items = itemsValue.compactMap { if case .string(let s) = $0 { return s } else { return nil } }

        try await thingsManager.setChecklistItems(todoId: id, items: items)

        return """
        {
            "success": true,
            "message": "Set \(items.count) checklist item(s) for to-do (replaced existing)",
            "warning": "All previous checklist items have been replaced",
            "note": "Due to API limitations, checklist items cannot be read back. Open Things 3 to verify."
        }
        """
    }

    // MARK: - JSON Formatting Helpers

    private func formatTodosAsJSON(_ todos: [Todo]) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let data = try? encoder.encode(todos),
              let json = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return json
    }

    private func formatTodoAsJSON(_ todo: Todo) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let data = try? encoder.encode(todo),
              let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return json
    }

    private func formatProjectsAsJSON(_ projects: [Project]) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let data = try? encoder.encode(projects),
              let json = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return json
    }

    private func formatProjectAsJSON(_ project: Project) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let data = try? encoder.encode(project),
              let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return json
    }

    private func formatAreasAsJSON(_ areas: [Area]) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let data = try? encoder.encode(areas),
              let json = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return json
    }

    private func formatTagsAsJSON(_ tags: [Tag]) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let data = try? encoder.encode(tags),
              let json = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return json
    }

    private func formatBatchResultAsJSON(_ result: ThingsManager.BatchResult) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let data = try? encoder.encode(result),
              let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return json
    }
}

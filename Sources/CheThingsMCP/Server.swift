import Foundation
import MCP

/// MCP Server for Things 3 integration
class CheThingsMCPServer {
    private let server: Server
    private let transport: StdioTransport
    private let thingsManager = ThingsManager()

    /// All available tools
    private let tools: [Tool]

    init() async throws {
        // Define all tools
        tools = Self.defineTools()

        // Create server with tools capability
        server = Server(
            name: "che-things-mcp",
            version: "0.1.0",
            capabilities: .init(tools: .init())
        )

        transport = StdioTransport()

        // Register handlers
        await registerHandlers()
    }

    func run() async throws {
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
}

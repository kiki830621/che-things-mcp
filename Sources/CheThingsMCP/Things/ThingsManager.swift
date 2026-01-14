import Foundation

// MARK: - Data Models

struct Todo: Codable {
    let id: String
    let name: String
    let notes: String?
    let status: String  // "open", "completed", "canceled"
    let tagNames: [String]
    let dueDate: String?
    let scheduledDate: String?
    let completionDate: String?
    let projectName: String?
    let areaName: String?
}

struct Project: Codable {
    let id: String
    let name: String
    let notes: String?
    let status: String
    let tagNames: [String]
    let areaName: String?
    let todoCount: Int
}

struct Area: Codable {
    let id: String
    let name: String
    let tagNames: [String]
}

struct Tag: Codable {
    let id: String
    let name: String
}

// MARK: - Errors

enum ThingsError: Error, LocalizedError {
    case scriptError(String)
    case notFound(String)
    case invalidParameter(String)
    case thingsNotInstalled

    var errorDescription: String? {
        switch self {
        case .scriptError(let message):
            return "AppleScript error: \(message)"
        case .notFound(let item):
            return "Not found: \(item)"
        case .invalidParameter(let message):
            return "Invalid parameter: \(message)"
        case .thingsNotInstalled:
            return "Things 3 is not installed. Please install it from the Mac App Store."
        }
    }
}

// MARK: - ThingsManager Actor

actor ThingsManager {

    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    // MARK: - AppleScript Execution

    private func executeAppleScript(_ script: String) throws -> String {
        var error: NSDictionary?
        guard let appleScript = NSAppleScript(source: script) else {
            throw ThingsError.scriptError("Failed to create AppleScript")
        }

        let result = appleScript.executeAndReturnError(&error)

        if let error = error {
            let errorMessage = error[NSAppleScript.errorMessage] as? String ?? "Unknown error"
            if errorMessage.contains("Application isn't running") || errorMessage.contains("Can't get application") {
                throw ThingsError.thingsNotInstalled
            }
            throw ThingsError.scriptError(errorMessage)
        }

        return result.stringValue ?? ""
    }

    private func executeAppleScriptReturningList(_ script: String) throws -> [String] {
        var error: NSDictionary?
        guard let appleScript = NSAppleScript(source: script) else {
            throw ThingsError.scriptError("Failed to create AppleScript")
        }

        let result = appleScript.executeAndReturnError(&error)

        if let error = error {
            let errorMessage = error[NSAppleScript.errorMessage] as? String ?? "Unknown error"
            throw ThingsError.scriptError(errorMessage)
        }

        // Parse list result
        var items: [String] = []
        let count = result.numberOfItems
        for i in 1...count {
            if let item = result.atIndex(i)?.stringValue {
                items.append(item)
            }
        }
        return items
    }

    // MARK: - List Access (Read Operations)

    func getTodos(from listName: String) async throws -> [Todo] {
        let script = """
        tell application "Things3"
            set output to ""
            set todoItems to to dos of list "\(listName)"
            repeat with t in todoItems
                set todoId to id of t
                set todoName to name of t
                set todoNotes to notes of t
                set todoStatus to status of t
                set todoTags to tag names of t

                -- Handle dates
                set todoDueDate to ""
                try
                    set todoDueDate to due date of t as string
                end try

                set todoScheduledDate to ""
                try
                    set todoScheduledDate to activation date of t as string
                end try

                set todoCompletionDate to ""
                try
                    set todoCompletionDate to completion date of t as string
                end try

                -- Handle project/area
                set todoProject to ""
                try
                    set todoProject to name of project of t
                end try

                set todoArea to ""
                try
                    set todoArea to name of area of t
                end try

                set output to output & todoId & "|||" & todoName & "|||" & todoNotes & "|||" & todoStatus & "|||" & todoTags & "|||" & todoDueDate & "|||" & todoScheduledDate & "|||" & todoCompletionDate & "|||" & todoProject & "|||" & todoArea & "###"
            end repeat
            return output
        end tell
        """

        let result = try executeAppleScript(script)
        return parseTodosFromOutput(result)
    }

    func getInbox() async throws -> [Todo] {
        return try await getTodos(from: "Inbox")
    }

    func getToday() async throws -> [Todo] {
        return try await getTodos(from: "Today")
    }

    func getUpcoming() async throws -> [Todo] {
        return try await getTodos(from: "Upcoming")
    }

    func getAnytime() async throws -> [Todo] {
        return try await getTodos(from: "Anytime")
    }

    func getSomeday() async throws -> [Todo] {
        return try await getTodos(from: "Someday")
    }

    func getLogbook() async throws -> [Todo] {
        return try await getTodos(from: "Logbook")
    }

    // MARK: - Projects

    func getProjects() async throws -> [Project] {
        let script = """
        tell application "Things3"
            set output to ""
            repeat with p in projects
                set projId to id of p
                set projName to name of p
                set projNotes to notes of p
                set projStatus to status of p
                set projTags to tag names of p

                set projArea to ""
                try
                    set projArea to name of area of p
                end try

                set projTodoCount to count of to dos of p

                set output to output & projId & "|||" & projName & "|||" & projNotes & "|||" & projStatus & "|||" & projTags & "|||" & projArea & "|||" & projTodoCount & "###"
            end repeat
            return output
        end tell
        """

        let result = try executeAppleScript(script)
        return parseProjectsFromOutput(result)
    }

    // MARK: - Search

    func searchTodos(query: String) async throws -> [Todo] {
        let script = """
        tell application "Things3"
            set output to ""
            set searchResults to to dos whose name contains "\(escapeForAppleScript(query))" or notes contains "\(escapeForAppleScript(query))"
            repeat with t in searchResults
                set todoId to id of t
                set todoName to name of t
                set todoNotes to notes of t
                set todoStatus to status of t
                set todoTags to tag names of t

                set todoDueDate to ""
                try
                    set todoDueDate to due date of t as string
                end try

                set todoScheduledDate to ""
                try
                    set todoScheduledDate to activation date of t as string
                end try

                set todoCompletionDate to ""
                try
                    set todoCompletionDate to completion date of t as string
                end try

                set todoProject to ""
                try
                    set todoProject to name of project of t
                end try

                set todoArea to ""
                try
                    set todoArea to name of area of t
                end try

                set output to output & todoId & "|||" & todoName & "|||" & todoNotes & "|||" & todoStatus & "|||" & todoTags & "|||" & todoDueDate & "|||" & todoScheduledDate & "|||" & todoCompletionDate & "|||" & todoProject & "|||" & todoArea & "###"
            end repeat
            return output
        end tell
        """

        let result = try executeAppleScript(script)
        return parseTodosFromOutput(result)
    }

    // MARK: - Create Operations

    func addTodo(
        name: String,
        notes: String? = nil,
        dueDate: String? = nil,
        tags: [String]? = nil,
        listName: String? = nil,
        projectName: String? = nil,
        when: String? = nil  // "today", "tomorrow", "evening", "anytime", "someday", or date string
    ) async throws -> Todo {
        var properties = "name:\"\(escapeForAppleScript(name))\""

        if let notes = notes {
            properties += ", notes:\"\(escapeForAppleScript(notes))\""
        }

        if let tags = tags, !tags.isEmpty {
            properties += ", tag names:\"\(tags.joined(separator: ", "))\""
        }

        // Determine where to create the todo
        var location = ""
        if let projectName = projectName {
            location = " in project \"\(escapeForAppleScript(projectName))\""
        } else if let listName = listName {
            location = " in list \"\(listName)\""
        }

        let script = """
        tell application "Things3"
            set newTodo to make new to do with properties {\(properties)}\(location)
            \(when != nil ? "schedule newTodo for \(getWhenClause(when!))" : "")
            \(dueDate != nil ? "set due date of newTodo to date \"\(dueDate!)\"" : "")
            return id of newTodo
        end tell
        """

        let todoId = try executeAppleScript(script)

        // Fetch and return the created todo
        return Todo(
            id: todoId.trimmingCharacters(in: .whitespacesAndNewlines),
            name: name,
            notes: notes,
            status: "open",
            tagNames: tags ?? [],
            dueDate: dueDate,
            scheduledDate: nil,
            completionDate: nil,
            projectName: projectName,
            areaName: nil
        )
    }

    func addProject(
        name: String,
        notes: String? = nil,
        tags: [String]? = nil,
        areaName: String? = nil,
        when: String? = nil
    ) async throws -> Project {
        var properties = "name:\"\(escapeForAppleScript(name))\""

        if let notes = notes {
            properties += ", notes:\"\(escapeForAppleScript(notes))\""
        }

        if let tags = tags, !tags.isEmpty {
            properties += ", tag names:\"\(tags.joined(separator: ", "))\""
        }

        var location = ""
        if let areaName = areaName {
            location = " in area \"\(escapeForAppleScript(areaName))\""
        }

        let script = """
        tell application "Things3"
            set newProject to make new project with properties {\(properties)}\(location)
            \(when != nil ? "schedule newProject for \(getWhenClause(when!))" : "")
            return id of newProject
        end tell
        """

        let projectId = try executeAppleScript(script)

        return Project(
            id: projectId.trimmingCharacters(in: .whitespacesAndNewlines),
            name: name,
            notes: notes,
            status: "open",
            tagNames: tags ?? [],
            areaName: areaName,
            todoCount: 0
        )
    }

    // MARK: - Update Operations

    func updateTodo(
        id: String,
        name: String? = nil,
        notes: String? = nil,
        dueDate: String? = nil,
        tags: [String]? = nil,
        when: String? = nil
    ) async throws {
        var updates: [String] = []

        if let name = name {
            updates.append("set name of targetTodo to \"\(escapeForAppleScript(name))\"")
        }
        if let notes = notes {
            updates.append("set notes of targetTodo to \"\(escapeForAppleScript(notes))\"")
        }
        if let tags = tags {
            updates.append("set tag names of targetTodo to \"\(tags.joined(separator: ", "))\"")
        }
        if let dueDate = dueDate {
            updates.append("set due date of targetTodo to date \"\(dueDate)\"")
        }
        if let when = when {
            updates.append("schedule targetTodo for \(getWhenClause(when))")
        }

        guard !updates.isEmpty else {
            throw ThingsError.invalidParameter("No updates specified")
        }

        let script = """
        tell application "Things3"
            set targetTodo to to do id "\(id)"
            \(updates.joined(separator: "\n            "))
        end tell
        """

        _ = try executeAppleScript(script)
    }

    func updateProject(
        id: String,
        name: String? = nil,
        notes: String? = nil,
        tags: [String]? = nil
    ) async throws {
        var updates: [String] = []

        if let name = name {
            updates.append("set name of targetProject to \"\(escapeForAppleScript(name))\"")
        }
        if let notes = notes {
            updates.append("set notes of targetProject to \"\(escapeForAppleScript(notes))\"")
        }
        if let tags = tags {
            updates.append("set tag names of targetProject to \"\(tags.joined(separator: ", "))\"")
        }

        guard !updates.isEmpty else {
            throw ThingsError.invalidParameter("No updates specified")
        }

        let script = """
        tell application "Things3"
            set targetProject to project id "\(id)"
            \(updates.joined(separator: "\n            "))
        end tell
        """

        _ = try executeAppleScript(script)
    }

    // MARK: - Complete/Delete Operations

    func completeTodo(id: String, completed: Bool = true) async throws {
        let status = completed ? "completed" : "open"
        let script = """
        tell application "Things3"
            set status of to do id "\(id)" to \(status)
        end tell
        """
        _ = try executeAppleScript(script)
    }

    func deleteTodo(id: String) async throws {
        let script = """
        tell application "Things3"
            move to do id "\(id)" to list "Trash"
        end tell
        """
        _ = try executeAppleScript(script)
    }

    func deleteProject(id: String) async throws {
        let script = """
        tell application "Things3"
            move project id "\(id)" to list "Trash"
        end tell
        """
        _ = try executeAppleScript(script)
    }

    // MARK: - Helper Methods

    private func escapeForAppleScript(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }

    private func getWhenClause(_ when: String) -> String {
        switch when.lowercased() {
        case "today":
            return "date (current date)"
        case "tomorrow":
            return "date ((current date) + 1 * days)"
        case "evening":
            return "date \"today 6:00 PM\""
        case "anytime":
            return "missing value"
        case "someday":
            return "\"someday\""
        default:
            // Assume it's a date string
            return "date \"\(when)\""
        }
    }

    private func parseTodosFromOutput(_ output: String) -> [Todo] {
        guard !output.isEmpty else { return [] }

        let todoStrings = output.components(separatedBy: "###").filter { !$0.isEmpty }
        return todoStrings.compactMap { todoString -> Todo? in
            let parts = todoString.components(separatedBy: "|||")
            guard parts.count >= 10 else { return nil }

            return Todo(
                id: parts[0],
                name: parts[1],
                notes: parts[2].isEmpty ? nil : parts[2],
                status: parts[3],
                tagNames: parts[4].isEmpty ? [] : parts[4].components(separatedBy: ", "),
                dueDate: parts[5].isEmpty ? nil : parts[5],
                scheduledDate: parts[6].isEmpty ? nil : parts[6],
                completionDate: parts[7].isEmpty ? nil : parts[7],
                projectName: parts[8].isEmpty ? nil : parts[8],
                areaName: parts[9].isEmpty ? nil : parts[9]
            )
        }
    }

    private func parseProjectsFromOutput(_ output: String) -> [Project] {
        guard !output.isEmpty else { return [] }

        let projectStrings = output.components(separatedBy: "###").filter { !$0.isEmpty }
        return projectStrings.compactMap { projectString -> Project? in
            let parts = projectString.components(separatedBy: "|||")
            guard parts.count >= 7 else { return nil }

            return Project(
                id: parts[0],
                name: parts[1],
                notes: parts[2].isEmpty ? nil : parts[2],
                status: parts[3],
                tagNames: parts[4].isEmpty ? [] : parts[4].components(separatedBy: ", "),
                areaName: parts[5].isEmpty ? nil : parts[5],
                todoCount: Int(parts[6]) ?? 0
            )
        }
    }
}

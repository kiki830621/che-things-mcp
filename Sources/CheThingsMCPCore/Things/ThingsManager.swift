import Foundation
import AppKit

// MARK: - Data Models

public struct Todo: Codable {
    public let id: String
    public let name: String
    public let notes: String?
    public let status: String  // "open", "completed", "canceled"
    public let tagNames: [String]
    public let dueDate: String?
    public let scheduledDate: String?
    public let completionDate: String?
    public let projectName: String?
    public let areaName: String?

    public init(id: String, name: String, notes: String?, status: String, tagNames: [String], dueDate: String?, scheduledDate: String?, completionDate: String?, projectName: String?, areaName: String?) {
        self.id = id
        self.name = name
        self.notes = notes
        self.status = status
        self.tagNames = tagNames
        self.dueDate = dueDate
        self.scheduledDate = scheduledDate
        self.completionDate = completionDate
        self.projectName = projectName
        self.areaName = areaName
    }
}

public struct Project: Codable {
    public let id: String
    public let name: String
    public let notes: String?
    public let status: String
    public let tagNames: [String]
    public let areaName: String?
    public let todoCount: Int

    public init(id: String, name: String, notes: String?, status: String, tagNames: [String], areaName: String?, todoCount: Int) {
        self.id = id
        self.name = name
        self.notes = notes
        self.status = status
        self.tagNames = tagNames
        self.areaName = areaName
        self.todoCount = todoCount
    }
}

public struct Area: Codable {
    public let id: String
    public let name: String
    public let tagNames: [String]

    public init(id: String, name: String, tagNames: [String]) {
        self.id = id
        self.name = name
        self.tagNames = tagNames
    }
}

public struct Tag: Codable {
    public let id: String
    public let name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

// MARK: - Errors

public enum ThingsError: Error, LocalizedError {
    case scriptError(String)
    case notFound(String)
    case todoNotFound(id: String)
    case projectNotFound(id: String)
    case areaNotFound(id: String)
    case tagNotFound(name: String)
    case invalidParameter(String)
    case thingsNotInstalled
    case urlSchemeError(String)

    public var errorDescription: String? {
        switch self {
        case .scriptError(let message):
            return "AppleScript error: \(message)"
        case .notFound(let item):
            return "Not found: \(item)"
        case .todoNotFound(let id):
            return "To-do not found with ID: \(id)"
        case .projectNotFound(let id):
            return "Project not found with ID: \(id)"
        case .areaNotFound(let id):
            return "Area not found with ID: \(id)"
        case .tagNotFound(let name):
            return "Tag not found: \(name)"
        case .invalidParameter(let message):
            return "Invalid parameter: \(message)"
        case .thingsNotInstalled:
            return "Things 3 is not installed. Please install it from the Mac App Store."
        case .urlSchemeError(let message):
            return "URL Scheme error: \(message)"
        }
    }
}

// MARK: - ThingsManager Actor

public actor ThingsManager {

    public init() {}

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

    public func getTodos(from listName: String) async throws -> [Todo] {
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

    public func getInbox() async throws -> [Todo] {
        return try await getTodos(from: "Inbox")
    }

    public func getToday() async throws -> [Todo] {
        return try await getTodos(from: "Today")
    }

    public func getUpcoming() async throws -> [Todo] {
        return try await getTodos(from: "Upcoming")
    }

    public func getAnytime() async throws -> [Todo] {
        return try await getTodos(from: "Anytime")
    }

    public func getSomeday() async throws -> [Todo] {
        return try await getTodos(from: "Someday")
    }

    public func getLogbook() async throws -> [Todo] {
        return try await getTodos(from: "Logbook")
    }

    // MARK: - Projects

    public func getProjects() async throws -> [Project] {
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

    public func searchTodos(query: String) async throws -> [Todo] {
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

    public func addTodo(
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

    public func addProject(
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

    public func updateTodo(
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

    public func updateProject(
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

    public func completeTodo(id: String, completed: Bool = true) async throws {
        let status = completed ? "completed" : "open"
        let script = """
        tell application "Things3"
            set status of to do id "\(id)" to \(status)
        end tell
        """
        _ = try executeAppleScript(script)
    }

    public func deleteTodo(id: String) async throws {
        let script = """
        tell application "Things3"
            move to do id "\(id)" to list "Trash"
        end tell
        """
        _ = try executeAppleScript(script)
    }

    public func deleteProject(id: String) async throws {
        let script = """
        tell application "Things3"
            move project id "\(id)" to list "Trash"
        end tell
        """
        _ = try executeAppleScript(script)
    }

    // MARK: - Areas

    public func getAreas() async throws -> [Area] {
        let script = """
        tell application "Things3"
            set output to ""
            repeat with a in areas
                set areaId to id of a
                set areaName to name of a
                set areaTags to tag names of a
                set output to output & areaId & "|||" & areaName & "|||" & areaTags & "###"
            end repeat
            return output
        end tell
        """

        let result = try executeAppleScript(script)
        return parseAreasFromOutput(result)
    }

    // MARK: - Tags

    public func getTags() async throws -> [Tag] {
        let script = """
        tell application "Things3"
            set output to ""
            repeat with t in tags
                set tagId to id of t
                set tagName to name of t
                set output to output & tagId & "|||" & tagName & "###"
            end repeat
            return output
        end tell
        """

        let result = try executeAppleScript(script)
        return parseTagsFromOutput(result)
    }

    // MARK: - Move Operations

    public func moveTodo(id: String, toList: String? = nil, toProject: String? = nil) async throws {
        var moveCommand = ""

        if let projectName = toProject {
            moveCommand = "move to do id \"\(id)\" to project \"\(escapeForAppleScript(projectName))\""
        } else if let listName = toList {
            moveCommand = "move to do id \"\(id)\" to list \"\(listName)\""
        } else {
            throw ThingsError.invalidParameter("Either toList or toProject must be specified")
        }

        let script = """
        tell application "Things3"
            \(moveCommand)
        end tell
        """
        _ = try executeAppleScript(script)
    }

    public func moveProject(id: String, toArea: String) async throws {
        let script = """
        tell application "Things3"
            move project id "\(id)" to area "\(escapeForAppleScript(toArea))"
        end tell
        """
        _ = try executeAppleScript(script)
    }

    // MARK: - UI Operations

    public func showTodo(id: String) async throws {
        let script = """
        tell application "Things3"
            show to do id "\(id)"
        end tell
        """
        _ = try executeAppleScript(script)
    }

    public func showProject(id: String) async throws {
        let script = """
        tell application "Things3"
            show project id "\(id)"
        end tell
        """
        _ = try executeAppleScript(script)
    }

    public func showList(name: String) async throws {
        let script = """
        tell application "Things3"
            show list "\(name)"
        end tell
        """
        _ = try executeAppleScript(script)
    }

    public func showQuickEntry(
        name: String? = nil,
        notes: String? = nil,
        when: String? = nil,
        listName: String? = nil
    ) async throws {
        var properties: [String] = []

        if let name = name {
            properties.append("name:\"\(escapeForAppleScript(name))\"")
        }
        if let notes = notes {
            properties.append("notes:\"\(escapeForAppleScript(notes))\"")
        }

        var showCommand = "show quick entry panel"
        if !properties.isEmpty {
            showCommand += " with properties {\(properties.joined(separator: ", "))}"
        }

        let script = """
        tell application "Things3"
            \(showCommand)
        end tell
        """
        _ = try executeAppleScript(script)
    }

    // MARK: - Utility Operations

    public func emptyTrash() async throws {
        let script = """
        tell application "Things3"
            empty trash
        end tell
        """
        _ = try executeAppleScript(script)
    }

    public func getSelectedTodos() async throws -> [Todo] {
        let script = """
        tell application "Things3"
            set output to ""
            set selectedItems to selected to dos
            repeat with t in selectedItems
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

    // MARK: - Advanced Queries

    public func getTodosInProject(projectId: String? = nil, projectName: String? = nil) async throws -> [Todo] {
        var projectRef = ""
        if let id = projectId {
            projectRef = "project id \"\(id)\""
        } else if let name = projectName {
            projectRef = "project \"\(escapeForAppleScript(name))\""
        } else {
            throw ThingsError.invalidParameter("Either projectId or projectName must be specified")
        }

        let script = """
        tell application "Things3"
            set output to ""
            set todoItems to to dos of \(projectRef)
            repeat with t in todoItems
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

    public func getTodosInArea(areaId: String? = nil, areaName: String? = nil) async throws -> [Todo] {
        var areaRef = ""
        if let id = areaId {
            areaRef = "area id \"\(id)\""
        } else if let name = areaName {
            areaRef = "area \"\(escapeForAppleScript(name))\""
        } else {
            throw ThingsError.invalidParameter("Either areaId or areaName must be specified")
        }

        let script = """
        tell application "Things3"
            set output to ""
            set todoItems to to dos of \(areaRef)
            repeat with t in todoItems
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

    public func getProjectsInArea(areaId: String? = nil, areaName: String? = nil) async throws -> [Project] {
        var areaRef = ""
        if let id = areaId {
            areaRef = "area id \"\(id)\""
        } else if let name = areaName {
            areaRef = "area \"\(escapeForAppleScript(name))\""
        } else {
            throw ThingsError.invalidParameter("Either areaId or areaName must be specified")
        }

        let script = """
        tell application "Things3"
            set output to ""
            repeat with p in projects of \(areaRef)
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

    private func parseAreasFromOutput(_ output: String) -> [Area] {
        guard !output.isEmpty else { return [] }

        let areaStrings = output.components(separatedBy: "###").filter { !$0.isEmpty }
        return areaStrings.compactMap { areaString -> Area? in
            let parts = areaString.components(separatedBy: "|||")
            guard parts.count >= 3 else { return nil }

            return Area(
                id: parts[0],
                name: parts[1],
                tagNames: parts[2].isEmpty ? [] : parts[2].components(separatedBy: ", ")
            )
        }
    }

    private func parseTagsFromOutput(_ output: String) -> [Tag] {
        guard !output.isEmpty else { return [] }

        let tagStrings = output.components(separatedBy: "###").filter { !$0.isEmpty }
        return tagStrings.compactMap { tagString -> Tag? in
            let parts = tagString.components(separatedBy: "|||")
            guard parts.count >= 2 else { return nil }

            return Tag(
                id: parts[0],
                name: parts[1]
            )
        }
    }

    // MARK: - Batch Operations

    public struct BatchResult: Codable {
        public let total: Int
        public let succeeded: Int
        public let failed: Int
        public let results: [BatchItemResult]

        public init(total: Int, succeeded: Int, failed: Int, results: [BatchItemResult]) {
            self.total = total
            self.succeeded = succeeded
            self.failed = failed
            self.results = results
        }
    }

    public struct BatchItemResult: Codable {
        public let index: Int
        public let success: Bool
        public let id: String?
        public let error: String?

        public init(index: Int, success: Bool, id: String?, error: String?) {
            self.index = index
            self.success = success
            self.id = id
            self.error = error
        }
    }

    public func createTodosBatch(
        items: [[String: Any]]
    ) async -> BatchResult {
        var results: [BatchItemResult] = []
        var succeeded = 0
        var failed = 0

        for (index, item) in items.enumerated() {
            do {
                let name = item["name"] as? String ?? ""
                guard !name.isEmpty else {
                    throw ThingsError.invalidParameter("name is required at index \(index)")
                }

                let todo = try await addTodo(
                    name: name,
                    notes: item["notes"] as? String,
                    dueDate: item["due_date"] as? String,
                    tags: item["tags"] as? [String],
                    listName: item["list"] as? String,
                    projectName: item["project"] as? String,
                    when: item["when"] as? String
                )
                results.append(BatchItemResult(index: index, success: true, id: todo.id, error: nil))
                succeeded += 1
            } catch {
                results.append(BatchItemResult(index: index, success: false, id: nil, error: error.localizedDescription))
                failed += 1
            }
        }

        return BatchResult(total: items.count, succeeded: succeeded, failed: failed, results: results)
    }

    public func completeTodosBatch(ids: [String], completed: Bool = true) async -> BatchResult {
        var results: [BatchItemResult] = []
        var succeeded = 0
        var failed = 0

        for (index, id) in ids.enumerated() {
            do {
                try await completeTodo(id: id, completed: completed)
                results.append(BatchItemResult(index: index, success: true, id: id, error: nil))
                succeeded += 1
            } catch {
                results.append(BatchItemResult(index: index, success: false, id: id, error: error.localizedDescription))
                failed += 1
            }
        }

        return BatchResult(total: ids.count, succeeded: succeeded, failed: failed, results: results)
    }

    public func deleteTodosBatch(ids: [String]) async -> BatchResult {
        var results: [BatchItemResult] = []
        var succeeded = 0
        var failed = 0

        for (index, id) in ids.enumerated() {
            do {
                try await deleteTodo(id: id)
                results.append(BatchItemResult(index: index, success: true, id: id, error: nil))
                succeeded += 1
            } catch {
                results.append(BatchItemResult(index: index, success: false, id: id, error: error.localizedDescription))
                failed += 1
            }
        }

        return BatchResult(total: ids.count, succeeded: succeeded, failed: failed, results: results)
    }

    public func moveTodosBatch(ids: [String], toList: String? = nil, toProject: String? = nil) async -> BatchResult {
        var results: [BatchItemResult] = []
        var succeeded = 0
        var failed = 0

        for (index, id) in ids.enumerated() {
            do {
                try await moveTodo(id: id, toList: toList, toProject: toProject)
                results.append(BatchItemResult(index: index, success: true, id: id, error: nil))
                succeeded += 1
            } catch {
                results.append(BatchItemResult(index: index, success: false, id: id, error: error.localizedDescription))
                failed += 1
            }
        }

        return BatchResult(total: ids.count, succeeded: succeeded, failed: failed, results: results)
    }

    public func updateTodosBatch(updates: [[String: Any]]) async -> BatchResult {
        var results: [BatchItemResult] = []
        var succeeded = 0
        var failed = 0

        for (index, update) in updates.enumerated() {
            do {
                guard let id = update["id"] as? String else {
                    throw ThingsError.invalidParameter("id is required at index \(index)")
                }

                try await updateTodo(
                    id: id,
                    name: update["name"] as? String,
                    notes: update["notes"] as? String,
                    dueDate: update["due_date"] as? String,
                    tags: update["tags"] as? [String],
                    when: update["when"] as? String
                )
                results.append(BatchItemResult(index: index, success: true, id: id, error: nil))
                succeeded += 1
            } catch {
                let id = update["id"] as? String
                results.append(BatchItemResult(index: index, success: false, id: id, error: error.localizedDescription))
                failed += 1
            }
        }

        return BatchResult(total: updates.count, succeeded: succeeded, failed: failed, results: results)
    }

    // MARK: - Checklist Operations (via URL Scheme)

    /// Add checklist items to an existing to-do (appends to existing checklist)
    /// - Note: Due to Things 3 API limitations, this can only ADD items. It cannot read or mark items as complete.
    public func addChecklistItems(todoId: String, items: [String]) throws {
        guard !items.isEmpty else {
            throw ThingsError.invalidParameter("items array cannot be empty")
        }

        let itemsString = items.joined(separator: "\n")
        guard let encodedItems = itemsString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw ThingsError.urlSchemeError("Failed to encode checklist items")
        }

        let urlString = "things:///update?id=\(todoId)&append-checklist-items=\(encodedItems)"
        guard let url = URL(string: urlString) else {
            throw ThingsError.urlSchemeError("Failed to create URL")
        }

        NSWorkspace.shared.open(url)
    }

    /// Set (replace) all checklist items for a to-do
    /// - Warning: This will REPLACE all existing checklist items!
    public func setChecklistItems(todoId: String, items: [String]) throws {
        let itemsString = items.joined(separator: "\n")
        guard let encodedItems = itemsString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw ThingsError.urlSchemeError("Failed to encode checklist items")
        }

        let urlString = "things:///update?id=\(todoId)&checklist-items=\(encodedItems)"
        guard let url = URL(string: urlString) else {
            throw ThingsError.urlSchemeError("Failed to create URL")
        }

        NSWorkspace.shared.open(url)
    }
}

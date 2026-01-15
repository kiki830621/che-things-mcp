import XCTest
@testable import CheThingsMCPCore

final class DataModelTests: XCTestCase {

    // MARK: - Todo Tests

    func testTodoInitialization() {
        let todo = Todo(
            id: "ABC123",
            name: "Test Task",
            notes: "Some notes",
            status: "open",
            tagNames: ["Work", "Important"],
            dueDate: "2024-12-25",
            scheduledDate: "2024-12-20",
            completionDate: nil,
            projectName: "My Project",
            areaName: "Work"
        )

        XCTAssertEqual(todo.id, "ABC123")
        XCTAssertEqual(todo.name, "Test Task")
        XCTAssertEqual(todo.notes, "Some notes")
        XCTAssertEqual(todo.status, "open")
        XCTAssertEqual(todo.tagNames, ["Work", "Important"])
        XCTAssertEqual(todo.dueDate, "2024-12-25")
        XCTAssertEqual(todo.scheduledDate, "2024-12-20")
        XCTAssertNil(todo.completionDate)
        XCTAssertEqual(todo.projectName, "My Project")
        XCTAssertEqual(todo.areaName, "Work")
    }

    func testTodoCodable() throws {
        let todo = Todo(
            id: "TEST001",
            name: "Codable Test",
            notes: nil,
            status: "completed",
            tagNames: [],
            dueDate: nil,
            scheduledDate: nil,
            completionDate: "2024-12-15",
            projectName: nil,
            areaName: nil
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(todo)

        let decoder = JSONDecoder()
        let decodedTodo = try decoder.decode(Todo.self, from: data)

        XCTAssertEqual(todo.id, decodedTodo.id)
        XCTAssertEqual(todo.name, decodedTodo.name)
        XCTAssertEqual(todo.status, decodedTodo.status)
    }

    // MARK: - Project Tests

    func testProjectInitialization() {
        let project = Project(
            id: "PROJ001",
            name: "Test Project",
            notes: "Project notes",
            status: "open",
            tagNames: ["Development"],
            areaName: "Work",
            todoCount: 5
        )

        XCTAssertEqual(project.id, "PROJ001")
        XCTAssertEqual(project.name, "Test Project")
        XCTAssertEqual(project.notes, "Project notes")
        XCTAssertEqual(project.status, "open")
        XCTAssertEqual(project.tagNames, ["Development"])
        XCTAssertEqual(project.areaName, "Work")
        XCTAssertEqual(project.todoCount, 5)
    }

    func testProjectCodable() throws {
        let project = Project(
            id: "PROJ002",
            name: "Codable Project",
            notes: nil,
            status: "completed",
            tagNames: [],
            areaName: nil,
            todoCount: 0
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(project)

        let decoder = JSONDecoder()
        let decodedProject = try decoder.decode(Project.self, from: data)

        XCTAssertEqual(project.id, decodedProject.id)
        XCTAssertEqual(project.name, decodedProject.name)
        XCTAssertEqual(project.todoCount, decodedProject.todoCount)
    }

    // MARK: - Area Tests

    func testAreaInitialization() {
        let area = Area(
            id: "AREA001",
            name: "Work",
            tagNames: ["Important"]
        )

        XCTAssertEqual(area.id, "AREA001")
        XCTAssertEqual(area.name, "Work")
        XCTAssertEqual(area.tagNames, ["Important"])
    }

    func testAreaCodable() throws {
        let area = Area(
            id: "AREA002",
            name: "Personal",
            tagNames: []
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(area)

        let decoder = JSONDecoder()
        let decodedArea = try decoder.decode(Area.self, from: data)

        XCTAssertEqual(area.id, decodedArea.id)
        XCTAssertEqual(area.name, decodedArea.name)
    }

    // MARK: - Tag Tests

    func testTagInitialization() {
        let tag = Tag(
            id: "TAG001",
            name: "Important"
        )

        XCTAssertEqual(tag.id, "TAG001")
        XCTAssertEqual(tag.name, "Important")
    }

    func testTagCodable() throws {
        let tag = Tag(
            id: "TAG002",
            name: "Work"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(tag)

        let decoder = JSONDecoder()
        let decodedTag = try decoder.decode(Tag.self, from: data)

        XCTAssertEqual(tag.id, decodedTag.id)
        XCTAssertEqual(tag.name, decodedTag.name)
    }
}

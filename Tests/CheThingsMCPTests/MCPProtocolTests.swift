import XCTest
@testable import CheThingsMCPCore
import MCP

/// MCP 協議層測試
/// 測試 Tool 定義、inputSchema 格式、required 參數等
final class MCPProtocolTests: XCTestCase {

    // MARK: - Tool Count Tests

    func testToolCount() async throws {
        // v1.5.0: 48 個工具
        let tools = getTools()
        XCTAssertEqual(tools.count, 48, "Should have exactly 48 tools")
    }

    // MARK: - List Access Tools (7)

    func testListAccessToolsExist() async throws {
        let tools = getTools()
        let listAccessTools = ["get_inbox", "get_today", "get_upcoming", "get_anytime", "get_someday", "get_logbook", "get_projects"]

        for toolName in listAccessTools {
            XCTAssertTrue(tools.contains { $0.name == toolName }, "Tool '\(toolName)' should exist")
        }
    }

    func testListAccessToolsAreReadOnly() async throws {
        let tools = getTools()
        let listAccessTools = ["get_inbox", "get_today", "get_upcoming", "get_anytime", "get_someday", "get_logbook", "get_projects"]

        for toolName in listAccessTools {
            guard let tool = tools.first(where: { $0.name == toolName }) else {
                XCTFail("Tool '\(toolName)' not found")
                continue
            }
            XCTAssertEqual(tool.annotations.readOnlyHint, true, "Tool '\(toolName)' should be read-only")
        }
    }

    func testListAccessToolsHaveNoRequiredParams() async throws {
        let tools = getTools()
        let listAccessTools = ["get_inbox", "get_today", "get_upcoming", "get_anytime", "get_someday", "get_logbook", "get_projects"]

        for toolName in listAccessTools {
            guard let tool = tools.first(where: { $0.name == toolName }) else {
                XCTFail("Tool '\(toolName)' not found")
                continue
            }
            // These tools should have empty properties
            if case .object(let schema) = tool.inputSchema,
               case .object(let props) = schema["properties"] {
                XCTAssertTrue(props.isEmpty, "Tool '\(toolName)' should have no properties")
            }
        }
    }

    // MARK: - Task Operations (5)

    func testTaskOperationToolsExist() async throws {
        let tools = getTools()
        let taskTools = ["add_todo", "update_todo", "complete_todo", "delete_todo", "search_todos"]

        for toolName in taskTools {
            XCTAssertTrue(tools.contains { $0.name == toolName }, "Tool '\(toolName)' should exist")
        }
    }

    func testAddTodoRequiredParams() async throws {
        let tools = getTools()
        guard let tool = tools.first(where: { $0.name == "add_todo" }) else {
            XCTFail("add_todo tool not found")
            return
        }

        if case .object(let schema) = tool.inputSchema,
           case .array(let required) = schema["required"] {
            let requiredStrings = required.compactMap { if case .string(let s) = $0 { return s } else { return nil } }
            XCTAssertTrue(requiredStrings.contains("name"), "add_todo should require 'name' parameter")
        } else {
            XCTFail("add_todo should have required array")
        }
    }

    func testUpdateTodoRequiredParams() async throws {
        let tools = getTools()
        guard let tool = tools.first(where: { $0.name == "update_todo" }) else {
            XCTFail("update_todo tool not found")
            return
        }

        if case .object(let schema) = tool.inputSchema,
           case .array(let required) = schema["required"] {
            let requiredStrings = required.compactMap { if case .string(let s) = $0 { return s } else { return nil } }
            XCTAssertTrue(requiredStrings.contains("id"), "update_todo should require 'id' parameter")
        } else {
            XCTFail("update_todo should have required array")
        }
    }

    func testDeleteTodoIsDestructive() async throws {
        let tools = getTools()
        guard let tool = tools.first(where: { $0.name == "delete_todo" }) else {
            XCTFail("delete_todo tool not found")
            return
        }
        XCTAssertEqual(tool.annotations.destructiveHint, true, "delete_todo should be destructive")
    }

    func testSearchTodosIsReadOnly() async throws {
        let tools = getTools()
        guard let tool = tools.first(where: { $0.name == "search_todos" }) else {
            XCTFail("search_todos tool not found")
            return
        }
        XCTAssertEqual(tool.annotations.readOnlyHint, true, "search_todos should be read-only")
    }

    // MARK: - Project Operations (3)

    func testProjectOperationToolsExist() async throws {
        let tools = getTools()
        let projectTools = ["add_project", "update_project", "delete_project"]

        for toolName in projectTools {
            XCTAssertTrue(tools.contains { $0.name == toolName }, "Tool '\(toolName)' should exist")
        }
    }

    func testDeleteProjectIsDestructive() async throws {
        let tools = getTools()
        guard let tool = tools.first(where: { $0.name == "delete_project" }) else {
            XCTFail("delete_project tool not found")
            return
        }
        XCTAssertEqual(tool.annotations.destructiveHint, true, "delete_project should be destructive")
    }

    // MARK: - Areas & Tags (8)

    func testAreasAndTagsToolsExist() async throws {
        let tools = getTools()
        let areaTagTools = ["get_areas", "add_area", "update_area", "delete_area", "get_tags", "add_tag", "update_tag", "delete_tag"]
        for toolName in areaTagTools {
            XCTAssertTrue(tools.contains { $0.name == toolName }, "Tool '\(toolName)' should exist")
        }
    }

    // MARK: - Move Operations (2)

    func testMoveOperationToolsExist() async throws {
        let tools = getTools()
        XCTAssertTrue(tools.contains { $0.name == "move_todo" }, "move_todo should exist")
        XCTAssertTrue(tools.contains { $0.name == "move_project" }, "move_project should exist")
    }

    func testMoveProjectRequiredParams() async throws {
        let tools = getTools()
        guard let tool = tools.first(where: { $0.name == "move_project" }) else {
            XCTFail("move_project tool not found")
            return
        }

        if case .object(let schema) = tool.inputSchema,
           case .array(let required) = schema["required"] {
            let requiredStrings = required.compactMap { if case .string(let s) = $0 { return s } else { return nil } }
            XCTAssertTrue(requiredStrings.contains("id"), "move_project should require 'id'")
            XCTAssertTrue(requiredStrings.contains("to_area"), "move_project should require 'to_area'")
        } else {
            XCTFail("move_project should have required array")
        }
    }

    // MARK: - UI Operations (4)

    func testUIOperationToolsExist() async throws {
        let tools = getTools()
        let uiTools = ["show_todo", "show_project", "show_list", "show_quick_entry"]

        for toolName in uiTools {
            XCTAssertTrue(tools.contains { $0.name == toolName }, "Tool '\(toolName)' should exist")
        }
    }

    func testUIOperationsHaveOpenWorldHint() async throws {
        let tools = getTools()
        let uiTools = ["show_todo", "show_project", "show_list", "show_quick_entry"]

        for toolName in uiTools {
            guard let tool = tools.first(where: { $0.name == toolName }) else {
                XCTFail("Tool '\(toolName)' not found")
                continue
            }
            XCTAssertEqual(tool.annotations.openWorldHint, true, "Tool '\(toolName)' should have openWorldHint=true")
        }
    }

    // MARK: - Utility Operations (2)

    func testUtilityOperationToolsExist() async throws {
        let tools = getTools()
        XCTAssertTrue(tools.contains { $0.name == "empty_trash" }, "empty_trash should exist")
        XCTAssertTrue(tools.contains { $0.name == "get_selected_todos" }, "get_selected_todos should exist")
    }

    func testEmptyTrashIsDestructive() async throws {
        let tools = getTools()
        guard let tool = tools.first(where: { $0.name == "empty_trash" }) else {
            XCTFail("empty_trash tool not found")
            return
        }
        XCTAssertEqual(tool.annotations.destructiveHint, true, "empty_trash should be destructive")
    }

    // MARK: - Advanced Queries (3)

    func testAdvancedQueryToolsExist() async throws {
        let tools = getTools()
        let queryTools = ["get_todos_in_project", "get_todos_in_area", "get_projects_in_area"]

        for toolName in queryTools {
            XCTAssertTrue(tools.contains { $0.name == toolName }, "Tool '\(toolName)' should exist")
        }
    }

    // MARK: - Batch Operations (5)

    func testBatchOperationToolsExist() async throws {
        let tools = getTools()
        let batchTools = ["create_todos_batch", "complete_todos_batch", "delete_todos_batch", "move_todos_batch", "update_todos_batch"]

        for toolName in batchTools {
            XCTAssertTrue(tools.contains { $0.name == toolName }, "Tool '\(toolName)' should exist")
        }
    }

    func testDeleteTodosBatchIsDestructive() async throws {
        let tools = getTools()
        guard let tool = tools.first(where: { $0.name == "delete_todos_batch" }) else {
            XCTFail("delete_todos_batch tool not found")
            return
        }
        XCTAssertEqual(tool.annotations.destructiveHint, true, "delete_todos_batch should be destructive")
    }

    func testBatchOperationsHaveItemsOrIdsParam() async throws {
        let tools = getTools()

        // create_todos_batch should have 'items' param
        if let tool = tools.first(where: { $0.name == "create_todos_batch" }),
           case .object(let schema) = tool.inputSchema,
           case .array(let required) = schema["required"] {
            let requiredStrings = required.compactMap { if case .string(let s) = $0 { return s } else { return nil } }
            XCTAssertTrue(requiredStrings.contains("items"), "create_todos_batch should require 'items'")
        }

        // complete_todos_batch should have 'ids' param
        if let tool = tools.first(where: { $0.name == "complete_todos_batch" }),
           case .object(let schema) = tool.inputSchema,
           case .array(let required) = schema["required"] {
            let requiredStrings = required.compactMap { if case .string(let s) = $0 { return s } else { return nil } }
            XCTAssertTrue(requiredStrings.contains("ids"), "complete_todos_batch should require 'ids'")
        }
    }

    // MARK: - Checklist Operations (2)

    func testChecklistOperationToolsExist() async throws {
        let tools = getTools()
        XCTAssertTrue(tools.contains { $0.name == "add_checklist_items" }, "add_checklist_items should exist")
        XCTAssertTrue(tools.contains { $0.name == "set_checklist_items" }, "set_checklist_items should exist")
    }

    func testSetChecklistItemsIsDestructive() async throws {
        let tools = getTools()
        guard let tool = tools.first(where: { $0.name == "set_checklist_items" }) else {
            XCTFail("set_checklist_items tool not found")
            return
        }
        XCTAssertEqual(tool.annotations.destructiveHint, true, "set_checklist_items should be destructive (replaces existing)")
    }

    func testChecklistOperationsHaveOpenWorldHint() async throws {
        let tools = getTools()
        let checklistTools = ["add_checklist_items", "set_checklist_items"]

        for toolName in checklistTools {
            guard let tool = tools.first(where: { $0.name == toolName }) else {
                XCTFail("Tool '\(toolName)' not found")
                continue
            }
            XCTAssertEqual(tool.annotations.openWorldHint, true, "Tool '\(toolName)' should have openWorldHint=true (uses URL Scheme)")
        }
    }

    // MARK: - Auth Token Tools (2)

    func testAuthTokenToolsExist() async throws {
        let tools = getTools()
        XCTAssertTrue(tools.contains { $0.name == "set_auth_token" }, "set_auth_token should exist")
        XCTAssertTrue(tools.contains { $0.name == "check_auth_status" }, "check_auth_status should exist")
    }

    func testCheckAuthStatusIsReadOnly() async throws {
        let tools = getTools()
        guard let tool = tools.first(where: { $0.name == "check_auth_status" }) else {
            XCTFail("check_auth_status tool not found")
            return
        }
        XCTAssertEqual(tool.annotations.readOnlyHint, true, "check_auth_status should be read-only")
    }

    // MARK: - InputSchema Validation

    func testAllToolsHaveValidInputSchema() async throws {
        let tools = getTools()

        for tool in tools {
            // Every tool should have an inputSchema
            guard case .object(let schema) = tool.inputSchema else {
                XCTFail("Tool '\(tool.name)' should have object inputSchema")
                continue
            }

            // Should have 'type' = 'object'
            if case .string(let typeValue) = schema["type"] {
                XCTAssertEqual(typeValue, "object", "Tool '\(tool.name)' inputSchema type should be 'object'")
            } else {
                XCTFail("Tool '\(tool.name)' should have type field")
            }

            // Should have 'properties' object
            guard case .object(_) = schema["properties"] else {
                XCTFail("Tool '\(tool.name)' should have properties object")
                continue
            }
        }
    }

    func testAllToolsHaveDescription() async throws {
        let tools = getTools()

        for tool in tools {
            let desc = tool.description ?? ""
            XCTAssertFalse(desc.isEmpty, "Tool '\(tool.name)' should have a description")
        }
    }

    // MARK: - Tool Categories

    func testToolCategories() async throws {
        let tools = getTools()

        // Count by category (v1.5.0)
        let listAccessCount = ["get_inbox", "get_today", "get_upcoming", "get_anytime", "get_someday", "get_logbook", "get_projects"].filter { name in tools.contains { $0.name == name } }.count
        let taskOpCount = ["add_todo", "update_todo", "complete_todo", "delete_todo", "search_todos"].filter { name in tools.contains { $0.name == name } }.count
        let projectOpCount = ["add_project", "update_project", "delete_project"].filter { name in tools.contains { $0.name == name } }.count
        let areasTagsCount = ["get_areas", "add_area", "update_area", "delete_area", "get_tags", "add_tag", "update_tag", "delete_tag"].filter { name in tools.contains { $0.name == name } }.count
        let moveOpCount = ["move_todo", "move_project"].filter { name in tools.contains { $0.name == name } }.count
        let uiOpCount = ["show_todo", "show_project", "show_list", "show_quick_entry"].filter { name in tools.contains { $0.name == name } }.count
        let cancelOpCount = ["cancel_todo", "cancel_project"].filter { name in tools.contains { $0.name == name } }.count
        let editOpCount = ["edit_todo", "edit_project"].filter { name in tools.contains { $0.name == name } }.count
        let utilityOpCount = ["empty_trash", "log_completed_now", "get_selected_todos"].filter { name in tools.contains { $0.name == name } }.count
        let advancedQueryCount = ["get_todos_in_project", "get_todos_in_area", "get_projects_in_area"].filter { name in tools.contains { $0.name == name } }.count
        let batchOpCount = ["create_todos_batch", "complete_todos_batch", "delete_todos_batch", "move_todos_batch", "update_todos_batch"].filter { name in tools.contains { $0.name == name } }.count
        let checklistOpCount = ["add_checklist_items", "set_checklist_items"].filter { name in tools.contains { $0.name == name } }.count
        let authTokenCount = ["set_auth_token", "check_auth_status"].filter { name in tools.contains { $0.name == name } }.count

        // Verify counts
        XCTAssertEqual(listAccessCount, 7, "Should have 7 list access tools")
        XCTAssertEqual(taskOpCount, 5, "Should have 5 task operation tools")
        XCTAssertEqual(projectOpCount, 3, "Should have 3 project operation tools")
        XCTAssertEqual(areasTagsCount, 8, "Should have 8 areas & tags tools")
        XCTAssertEqual(moveOpCount, 2, "Should have 2 move operation tools")
        XCTAssertEqual(uiOpCount, 4, "Should have 4 UI operation tools")
        XCTAssertEqual(cancelOpCount, 2, "Should have 2 cancel operation tools")
        XCTAssertEqual(editOpCount, 2, "Should have 2 edit operation tools")
        XCTAssertEqual(utilityOpCount, 3, "Should have 3 utility operation tools")
        XCTAssertEqual(advancedQueryCount, 3, "Should have 3 advanced query tools")
        XCTAssertEqual(batchOpCount, 5, "Should have 5 batch operation tools")
        XCTAssertEqual(checklistOpCount, 2, "Should have 2 checklist operation tools")
        XCTAssertEqual(authTokenCount, 2, "Should have 2 auth token tools")

        // Total should be 48 (v1.5.0)
        let total = listAccessCount + taskOpCount + projectOpCount + areasTagsCount + moveOpCount + uiOpCount + cancelOpCount + editOpCount + utilityOpCount + advancedQueryCount + batchOpCount + checklistOpCount + authTokenCount
        XCTAssertEqual(total, 48, "Total should be 48 tools")
    }

    // MARK: - Helper

    private func getTools() -> [Tool] {
        // Access the static method to get tool definitions
        // This tests the tool definitions without needing to create a server instance
        return CheThingsMCPServer.defineTools()
    }
}

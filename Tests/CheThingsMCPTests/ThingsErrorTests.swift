import XCTest
@testable import CheThingsMCPCore

final class ThingsErrorTests: XCTestCase {

    // MARK: - Error Description Tests

    func testScriptErrorDescription() {
        let error = ThingsError.scriptError("Test script failed")
        XCTAssertEqual(error.errorDescription, "AppleScript error: Test script failed")
    }

    func testNotFoundErrorDescription() {
        let error = ThingsError.notFound("item")
        XCTAssertEqual(error.errorDescription, "Not found: item")
    }

    func testTodoNotFoundErrorDescription() {
        let error = ThingsError.todoNotFound(id: "ABC123")
        XCTAssertEqual(error.errorDescription, "To-do not found with ID: ABC123")
    }

    func testProjectNotFoundErrorDescription() {
        let error = ThingsError.projectNotFound(id: "XYZ789")
        XCTAssertEqual(error.errorDescription, "Project not found with ID: XYZ789")
    }

    func testAreaNotFoundErrorDescription() {
        let error = ThingsError.areaNotFound(id: "AREA001")
        XCTAssertEqual(error.errorDescription, "Area not found with ID: AREA001")
    }

    func testTagNotFoundErrorDescription() {
        let error = ThingsError.tagNotFound(name: "Work")
        XCTAssertEqual(error.errorDescription, "Tag not found: Work")
    }

    func testInvalidParameterErrorDescription() {
        let error = ThingsError.invalidParameter("name is required")
        XCTAssertEqual(error.errorDescription, "Invalid parameter: name is required")
    }

    func testThingsNotInstalledErrorDescription() {
        let error = ThingsError.thingsNotInstalled
        XCTAssertEqual(error.errorDescription, "Things 3 is not installed. Please install it from the Mac App Store.")
    }

    func testUrlSchemeErrorDescription() {
        let error = ThingsError.urlSchemeError("Failed to encode")
        XCTAssertEqual(error.errorDescription, "URL Scheme error: Failed to encode")
    }

    // MARK: - Error Type Tests

    func testErrorConformsToLocalizedError() {
        let error = ThingsError.scriptError("test")
        XCTAssertTrue(error is LocalizedError)
    }

    func testErrorConformsToError() {
        let error = ThingsError.scriptError("test")
        XCTAssertTrue(error is Error)
    }
}

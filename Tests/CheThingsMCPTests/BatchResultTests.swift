import XCTest
@testable import CheThingsMCPCore

final class BatchResultTests: XCTestCase {

    // MARK: - BatchItemResult Tests

    func testBatchItemResultSuccess() {
        let result = ThingsManager.BatchItemResult(
            index: 0,
            success: true,
            id: "ABC123",
            error: nil
        )

        XCTAssertEqual(result.index, 0)
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.id, "ABC123")
        XCTAssertNil(result.error)
    }

    func testBatchItemResultFailure() {
        let result = ThingsManager.BatchItemResult(
            index: 1,
            success: false,
            id: nil,
            error: "To-do not found"
        )

        XCTAssertEqual(result.index, 1)
        XCTAssertFalse(result.success)
        XCTAssertNil(result.id)
        XCTAssertEqual(result.error, "To-do not found")
    }

    func testBatchItemResultCodable() throws {
        let result = ThingsManager.BatchItemResult(
            index: 2,
            success: true,
            id: "XYZ789",
            error: nil
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(result)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ThingsManager.BatchItemResult.self, from: data)

        XCTAssertEqual(result.index, decoded.index)
        XCTAssertEqual(result.success, decoded.success)
        XCTAssertEqual(result.id, decoded.id)
    }

    // MARK: - BatchResult Tests

    func testBatchResultAllSuccess() {
        let items = [
            ThingsManager.BatchItemResult(index: 0, success: true, id: "A", error: nil),
            ThingsManager.BatchItemResult(index: 1, success: true, id: "B", error: nil),
            ThingsManager.BatchItemResult(index: 2, success: true, id: "C", error: nil)
        ]

        let result = ThingsManager.BatchResult(
            total: 3,
            succeeded: 3,
            failed: 0,
            results: items
        )

        XCTAssertEqual(result.total, 3)
        XCTAssertEqual(result.succeeded, 3)
        XCTAssertEqual(result.failed, 0)
        XCTAssertEqual(result.results.count, 3)
    }

    func testBatchResultPartialSuccess() {
        let items = [
            ThingsManager.BatchItemResult(index: 0, success: true, id: "A", error: nil),
            ThingsManager.BatchItemResult(index: 1, success: false, id: nil, error: "Not found"),
            ThingsManager.BatchItemResult(index: 2, success: true, id: "C", error: nil)
        ]

        let result = ThingsManager.BatchResult(
            total: 3,
            succeeded: 2,
            failed: 1,
            results: items
        )

        XCTAssertEqual(result.total, 3)
        XCTAssertEqual(result.succeeded, 2)
        XCTAssertEqual(result.failed, 1)
    }

    func testBatchResultAllFailure() {
        let items = [
            ThingsManager.BatchItemResult(index: 0, success: false, id: nil, error: "Error 1"),
            ThingsManager.BatchItemResult(index: 1, success: false, id: nil, error: "Error 2")
        ]

        let result = ThingsManager.BatchResult(
            total: 2,
            succeeded: 0,
            failed: 2,
            results: items
        )

        XCTAssertEqual(result.total, 2)
        XCTAssertEqual(result.succeeded, 0)
        XCTAssertEqual(result.failed, 2)
    }

    func testBatchResultCodable() throws {
        let items = [
            ThingsManager.BatchItemResult(index: 0, success: true, id: "TEST", error: nil)
        ]

        let result = ThingsManager.BatchResult(
            total: 1,
            succeeded: 1,
            failed: 0,
            results: items
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(result)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ThingsManager.BatchResult.self, from: data)

        XCTAssertEqual(result.total, decoded.total)
        XCTAssertEqual(result.succeeded, decoded.succeeded)
        XCTAssertEqual(result.failed, decoded.failed)
        XCTAssertEqual(result.results.count, decoded.results.count)
    }

    func testBatchResultJSONFormat() throws {
        let items = [
            ThingsManager.BatchItemResult(index: 0, success: true, id: "ABC", error: nil)
        ]

        let result = ThingsManager.BatchResult(
            total: 1,
            succeeded: 1,
            failed: 0,
            results: items
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(result)
        let json = String(data: data, encoding: .utf8)!

        // Verify JSON contains expected keys
        XCTAssertTrue(json.contains("\"total\":1"))
        XCTAssertTrue(json.contains("\"succeeded\":1"))
        XCTAssertTrue(json.contains("\"failed\":0"))
        XCTAssertTrue(json.contains("\"results\""))
    }
}

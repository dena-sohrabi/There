//  ThereUITests.swift
//  ThereUITests
//
//  Created by Dena Sohrabi on 9/2/24.
//

import XCTest

final class ThereUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    override func tearDownWithError() throws {
        // Terminate the app after each test
        app.terminate()
    }

    func printAccessibleElements() {
        let allElements = app.descendants(matching: .any)
        for element in allElements.allElementsBoundByIndex {
            print("Element: \(element.debugDescription)")
        }
    }

    @MainActor
    func testUIElementsExistence() throws {
        // Print all accessible elements
        print("Printing all accessible elements:")
        printAccessibleElements()

        // Check for specific element types
        print("\nSearching for specific element types:")
        let searchFields = app.searchFields.allElementsBoundByIndex
        print("Search Fields: \(searchFields.map { $0.debugDescription })")

        let textFields = app.textFields.allElementsBoundByIndex
        print("Text Fields: \(textFields.map { $0.debugDescription })")

        let buttons = app.buttons.allElementsBoundByIndex
        print("Buttons: \(buttons.map { $0.debugDescription })")

        let tables = app.tables.allElementsBoundByIndex
        print("Tables: \(tables.map { $0.debugDescription })")

        // Try to find any input field
        let possibleInputFields = app.descendants(matching: .any).matching(NSPredicate(format: "type == 'XCUIElementTypeTextField' OR type == 'XCUIElementTypeSearchField'"))
        print("\nPossible Input Fields:")
        for field in possibleInputFields.allElementsBoundByIndex {
            print(field.debugDescription)
        }

        // Assert that we found at least one possible input field
        XCTAssertTrue(possibleInputFields.count > 0, "No input fields found in the app")
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

//
//  PersistentUITests.swift
//  PersistentUITests
//
//  Created by Bennett Quaritsch on 22.08.22.
//

import XCTest

final class PersistentUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

        func testExample() throws {
            
            let app = XCUIApplication()
            setupSnapshot(app)
            app.launch()
            
            snapshot("List")
            
            app.scrollViews.otherElements.buttons["Workout, 4"].tap()
            
            snapshot("Detail")

            app.navigationBars.firstMatch.buttons["DetailMenu"].tap()

            let collectionViewsQuery = app.collectionViews
            collectionViewsQuery.buttons["MenuEditButton"].tap()
            
            snapshot("Add_Habit")
            
            app.navigationBars["Workout"].buttons["CloseButton"].tap()
            
            app.buttons["GraphsButton"].tap()
            
            app.navigationBars["Graphs"].buttons["CloseButton"].tap()
            app.navigationBars["_TtGC7SwiftUI19UIHosting"].buttons["All Habits"].tap()
            app.buttons["SettingsButton"].tap()
            
            app.buttons["Settings.InterfaceDesign.AccentTheme"].tap()
            app/*@START_MENU_TOKEN@*/.switches["Waves"]/*[[".cells.switches[\"Waves\"]",".switches[\"Waves\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            app.navigationBars["Settings.InterfaceDesign.AccentTheme"].buttons["Settings.Navigation"].tap()
            
            app.buttons["ListCellColorPicker"].tap()
            app.buttons["MutedOption"].tap()
            
            app.buttons["SettingsCloseButton"].tap()
            
            snapshot("Customized_List")
            
            app.buttons["SettingsButton"].tap()
            
            app.buttons["Settings.InterfaceDesign.AccentTheme"].tap()
            app.switches["Persistent"].tap()
            app.switches["Dark Mode"].tap()
            app.navigationBars["Settings.InterfaceDesign.AccentTheme"].buttons["Settings.Navigation"].tap()
            
            app.buttons["ListCellColorPicker"].tap()
            app.buttons["ColorfulOption"].tap()
            
            app.buttons["SettingsCloseButton"].tap()
            
            app.scrollViews.otherElements.buttons["Workout, 4"].tap()
            
            app.buttons["GraphsButton"].tap()
            
            snapshot("Graphs_Dark_Mode")
            
            app.navigationBars["Graphs"].buttons["CloseButton"].tap()
            app.navigationBars["_TtGC7SwiftUI19UIHosting"].buttons["All Habits"].tap()
            
        
            app.buttons["SettingsButton"].tap()
            
            app.buttons["Settings.InterfaceDesign.AccentTheme"].tap()
            app.switches["Automatic"].tap()
        
        
        snapshot("0Launch")

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

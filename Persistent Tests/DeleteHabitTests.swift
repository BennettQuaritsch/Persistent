//
//  DeleteHabitTests.swift
//  Persistent Tests
//
//  Created by Bennett Quaritsch on 30.12.21.
//

import XCTest
@testable import Persistent

class DeleteHabitTests: XCTestCase {
    var appViewModel: AppViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        appViewModel = AppViewModel()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        appViewModel = nil
    }

    func testDeleteAlertOutput() {
        let context = PersistenceController().container.viewContext
        let habit = HabitItem(context: context)
        
        appViewModel.habitToDelete = habit
        
        XCTAssertTrue(appViewModel.deleteActionSheet)
    }
    
    func testDeleteAlertHabitNilOutput() {
        appViewModel.habitToDelete = nil
        
        XCTAssertFalse(appViewModel.deleteActionSheet)
    }

}

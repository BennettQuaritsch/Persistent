//
//  WatchHabitDetailViewModel.swift
//  PersistentWatch WatchKit Extension
//
//  Created by Bennett Quaritsch on 06.01.22.
//

import Foundation
import SwiftUI

class WatchHabitDetailViewModel: ObservableObject {
    @Published var habit: HabitItem
    
    init(habit: HabitItem) {
        self.habit = habit
    }
}

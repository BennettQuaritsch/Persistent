//
//  ListMenuButton.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 15.07.22.
//

import SwiftUI

struct ListMenuButton: View {
    @Environment(\.parentSizeClass) var parentSizeClass
    
    @ObservedObject var viewModel: ListViewModel
    
    @Binding var filterOption: ListFilterSelectionEnum
    let tags: [HabitTag]
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \HabitItem.habitName, ascending: true)],
        animation: .easeInOut)
    var allHabits: FetchedResults<HabitItem>
    
    @ViewBuilder func predicateButton(filter: ListFilterSelectionEnum, text: String, imageName: String? = nil) -> some View {
        Button {
            withAnimation(.easeInOut) {
                filterOption = filter
            }
        } label: {
            Text("\(text) (\(filterCount(filter)))")
        }
    }
    
    var sortingNameOptionImage: String {
        switch viewModel.sortingOption {
        case .nameAscending:
            return "arrow.up"
        case .nameDescending:
            return "arrow.down"
        default:
            return "abc"
        }
    }
    
    var sortingPercentageOptionImage: String {
        switch viewModel.sortingOption {
        case .percentageDoneAscending:
            return "arrow.up"
        case .percentageDoneDescending:
            return "arrow.down"
        default:
            return "percent"
        }
    }
    
    func filterCount(_ filterOption: ListFilterSelectionEnum) -> Int {
        switch filterOption {
        case .daily:
            return allHabits
                .filter {$0.resetIntervalEnum == .daily}
                .count
        case .weekly:
            return allHabits
                .filter {$0.resetIntervalEnum == .weekly}
                .count
        case .monthly:
            return allHabits
                .filter {$0.resetIntervalEnum == .monthly}
                .count
        case.tag(let tag):
            return tag
                .containingHabits?.count ?? 0
        default:
            return allHabits.count
        }
    }
    
    var body: some View {
        Menu() {
            Menu {
                Button {
                    withAnimation {
                        if viewModel.sortingOption == .nameAscending {
                            viewModel.sortingOption = .nameDescending
                        } else {
                            viewModel.sortingOption = .nameAscending
                        }
                    }
                } label: {
                    Label("Name", systemImage: sortingNameOptionImage)
                }
                
                Button {
                    withAnimation {
                        if viewModel.sortingOption == .percentageDoneAscending {
                            viewModel.sortingOption = .percentageDoneDescending
                        } else {
                            viewModel.sortingOption = .percentageDoneAscending
                        }
                    }
                } label: {
                    Label("Percentage Done", systemImage: sortingPercentageOptionImage)
                }
            } label: {
                Label("Sorting", systemImage: "line.3.horizontal")
            }
            
            if parentSizeClass == .compact {
                Divider()
                
                predicateButton(filter: .all, text: "All Habits", imageName: "checkmark.circle")
                
                Menu {
                    predicateButton(filter: .daily, text: "Daily Habits")
                    
                    predicateButton(filter: .weekly, text: "Weekly Habits")
                    
                    predicateButton(filter: .monthly, text: "Monthly Habits")
                } label: {
                    Label("Intervals", systemImage: "timer")
                }
                
                Menu {
                    ForEach(tags) { tag in
                        predicateButton(filter: .tag(tag), text: tag.wrappedName)
                    }
                } label: {
                    Label("Tags", systemImage: "bookmark")
                }
            }
            
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .contentShape(Rectangle())
        }
        .menuOrder(.fixed)
    }
}

struct ListMenuButton_Previews: PreviewProvider {
    static var previews: some View {
        ListMenuButton(viewModel: ListViewModel(), filterOption: .constant(.all), tags: [])
            .environment(\.parentSizeClass, .compact)
            .previewDevice("iPhone 13")
    }
}

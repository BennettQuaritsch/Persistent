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
//            Text("\(text) (\(filterCount(filter)))")
            Text("\(text)")
        }
    }
    
//    func filterCount(_ filterOption: ListFilterSelectionEnum) -> Int {
//        switch filterOption {
//        case .daily:
//            return allHabits
//                .filter {$0.resetIntervalEnum == .daily && !$0.habitArchived}
//                .count
//        case .weekly:
//            return allHabits
//                .filter {$0.resetIntervalEnum == .weekly && !$0.habitArchived}
//                .count
//        case .monthly:
//            return allHabits
//                .filter {$0.resetIntervalEnum == .monthly && !$0.habitArchived}
//                .count
//        case.tag(let tag):
//            return tag
//                .containingHabits?
//                .filter { $0. }
//                .count ?? 0
//        default:
//            return allHabits.count
//        }
//    }
    
    var body: some View {
        Menu() {
            Menu {
                Menu {
                    Button {
                        withAnimation {
                            viewModel.sortingOption = .nameAscending
                        }
                    } label: {
                        Label("ListView.FilterButton.Ascending", systemImage: "arrow.up")
                    }
                    
                    Button {
                        withAnimation {
                            viewModel.sortingOption = .nameDescending
                        }
                    } label: {
                        Label("ListView.FilterButton.Descending", systemImage: "arrow.down")
                    }
                } label: {
                    Label("ListView.FilterButton.Name", systemImage: "abc")
                }
                
                Menu {
                    Button {
                        withAnimation {
                            viewModel.sortingOption = .percentageDoneAscending
                        }
                    } label: {
                        Label("ListView.FilterButton.Ascending", systemImage: "arrow.up")
                    }
                    
                    Button {
                        withAnimation {
                            viewModel.sortingOption = .percentageDoneDescending
                        }
                    } label: {
                        Label("ListView.FilterButton.Descending", systemImage: "arrow.down")
                    }
                } label: {
                    Label("ListView.FilterButton.PercentageDone", systemImage: "percent")
                }
            } label: {
                Label("ListView.FilterButton.Sorting", systemImage: "line.3.horizontal")
            }
            
            if parentSizeClass == .compact {
                Divider()
                
                predicateButton(filter: .all, text: ListFilterSelectionEnum.all.name, imageName: "checkmark.circle")
                
                Menu {
                    predicateButton(filter: .daily, text: ListFilterSelectionEnum.daily.name)
                    
                    predicateButton(filter: .weekly, text: ListFilterSelectionEnum.weekly.name)
                    
                    predicateButton(filter: .monthly, text: ListFilterSelectionEnum.monthly.name)
                } label: {
                    Label("ListView.FilterButton.Intervals", systemImage: "timer")
                }
                
                Menu {
                    ForEach(tags) { tag in
                        predicateButton(filter: .tag(tag), text: tag.wrappedName)
                    }
                } label: {
                    Label("ListView.FilterButton.Tags", systemImage: "bookmark")
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

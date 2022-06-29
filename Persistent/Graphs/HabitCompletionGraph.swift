//
//  HabitCompletionGraph.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 20.09.21.
//

import SwiftUI
import CoreData

struct HabitCompletionGraph: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.parentSizeClass) var parentSizeClass
    
    @ObservedObject var viewModel: HabitBarChartViewModel
    
    let headerActivated: Bool
    let backgroundColor: Color
    
    init(viewModel: HabitBarChartViewModel, headerActivated: Bool = true, backgroundColor: Color = .systemBackground) {
        self.viewModel = viewModel
        
        self.headerActivated = headerActivated
        
        self.backgroundColor = backgroundColor
    }
    
//    @Binding var graphPickerSelection: HabitBarChartViewModel.GraphPickerSelectionEnum
    
    var spacing: Double {
        if viewModel.graphPickerSelection == .smallView {
            return parentSizeClass == .regular ? 20 : 10
        } else {
            return parentSizeClass == .regular ? 10 : 5
        }
    }
    
    @ViewBuilder var headerView: some View {
        HStack {
            Button {
                viewModel.changeSelectedInterval(negative: true)
            } label: {
                Label("Backward", systemImage: "chevron.left")
                    .labelStyle(.iconOnly)
                    .padding(8)
                    .background(Color.systemBackground, in: Circle())
            }
            
            Spacer()
                .layoutPriority(-1)
            
            HStack {
                switch viewModel.habit.resetIntervalEnum {
                case .daily:
                    switch viewModel.graphPickerSelection {
                    case .smallView:
                        if let first = viewModel.shownDates.first?.formatted(.dateTime.week(.twoDigits)), let last = viewModel.shownDates.last?.formatted(.dateTime.week(.twoDigits)), first != last {
                            Text("\(viewModel.shownDates.first!.formatted(.dateTime.year())) - \(first)")
                            
                            Spacer()
                            
                            Text("\(viewModel.shownDates.last!.formatted(.dateTime.year())) - \(last)")
                        } else {
                            if let first = viewModel.shownDates.first {
                                Text("\(first.formatted(.dateTime.year())) - \(first.formatted(.dateTime.week(.twoDigits)))")
                            }
                        }
                    case .mediumView:
                        if let first = viewModel.shownDates.first?.formatted(.dateTime.week(.twoDigits)), let last = viewModel.shownDates.last?.formatted(.dateTime.week(.twoDigits)), first != last {
                            Text("\(viewModel.shownDates.first!.formatted(.dateTime.year())) - \(first)")
                            
                            Spacer()
                            
                            Text("\(viewModel.shownDates.last!.formatted(.dateTime.year())) - \(last)")
                        }
                    }
                case .weekly:
                    switch viewModel.graphPickerSelection {
                    case .smallView:
                        if let first = viewModel.shownDates.first?.formatted(.dateTime.year()), let last = viewModel.shownDates.last?.formatted(.dateTime.year()), first != last {
                            Text("\(first)")
                            
                            Spacer()
                            
                            Text("\(last)")
                        } else {
                            Text("\((viewModel.shownDates.first ?? Date()).formatted(.dateTime.year()))")
                        }
                    case .mediumView:
                        if let first = viewModel.shownDates.first?.formatted(.dateTime.year()), let last = viewModel.shownDates.last?.formatted(.dateTime.year()), first != last {
                            Text("\(first)")
                            
                            Spacer()
                            
                            Text("\(last)")
                        } else {
                            Text("\((viewModel.shownDates.first ?? Date()).formatted(.dateTime.year()))")
                        }
                    }
                case .monthly:
                    if let first = viewModel.shownDates.first?.formatted(.dateTime.month().year()), let last = viewModel.shownDates.last?.formatted(.dateTime.month().year()) {
                        Text(first)
                        
                        Spacer()
                        
                        Text(last)
                    }
                }
            }
            .layoutPriority(2)
            
            Spacer()
                .layoutPriority(-1)
            
            Button {
                viewModel.changeSelectedInterval()
            } label: {
                Label("Forward", systemImage: "chevron.right")
                    .labelStyle(.iconOnly)
                    .padding(8)
                    .background(Color.systemBackground, in: Circle())
            }
        }
        .font(.headline)
        .padding(.top, 8)
    }
    
    @ViewBuilder var footerView: some View {
        switch viewModel.graphPickerSelection {
        case .smallView:
            HStack {
                switch viewModel.habit.resetIntervalEnum {
                case .daily:
                    ForEach(viewModel.shownDates, id: \.self) { date in
                        Text(date.formatted(.dateTime.weekday(.short)))
                            .font(.headline)
                    }
                    .frame(minWidth: 10, maxWidth: .infinity)
                case .weekly:
                    ForEach(viewModel.shownDates, id: \.self) { date in
                        Text(date.formatted(.dateTime.week(.defaultDigits)))
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                case .monthly:
                    ForEach(viewModel.shownDates, id: \.self) { date in
                        Text(date.formatted(.dateTime.month(.abbreviated)))
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        case .mediumView:
            HStack {
                switch viewModel.habit.resetIntervalEnum {
                case .daily:
                    Text((viewModel.shownDates.first ?? Date()).formatted(.dateTime.day(.twoDigits)))
                        .font(.headline)
                    
                    Spacer()
                    
                    Text((viewModel.shownDates.last ?? Date()).formatted(.dateTime.day(.twoDigits)))
                        .font(.headline)
                case .weekly:
                    if let first = viewModel.shownDates.first {
                        Text("Week \(first.formatted(.dateTime.week(.defaultDigits)))")
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    if let last = viewModel.shownDates.last {
                        Text("Week \(last.formatted(.dateTime.week(.defaultDigits)))")
                            .font(.headline)
                    }
                case .monthly:
                    ForEach(viewModel.shownDates, id: \.self) { date in
                        Text(date.formatted(.dateTime.month(.narrow)))
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 5)
        }
    }
    
    var body: some View {
        VStack {
            if headerActivated {
                headerView
            }
            
            GeometryReader { geo in
                HStack(alignment: .bottom, spacing: spacing) {
                    ForEach(viewModel.data.indices, id: \.self) { index in
                        
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: parentSizeClass == .regular ? 20 : 10, style: .continuous)
                                .foregroundColor(backgroundColor)
                            
                            RoundedRectangle(cornerRadius: parentSizeClass == .regular ? 20 : 10, style: .continuous)
                                .foregroundColor(viewModel.habit.iconColor)
                                .frame(height: CGFloat(viewModel.data[index]) / CGFloat(viewModel.maxValue) * geo.size.height)
                        }
                        .overlay(alignment: .bottom) {
                            if viewModel.graphPickerSelection == .smallView {
                                if viewModel.valuesShown {
                                    Text("\(NumberFormatter.stringFormattedForHabitTypeShort(value: viewModel.data[index], habit: viewModel.habit))")
                                        .minimumScaleFactor(0.7)
                                        .foregroundStyle(.secondary)
                                        .padding(.bottom, 5)
                                }
                            }
                        }
                            
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
                .onTapGesture {
                    viewModel.valuesShown.toggle()
                }
            }
        
            footerView
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.loadHabits()
            }
        }
        
        
    }
}

struct HabitCompletionGraph_Previews: PreviewProvider {
    static var previews: some View {
        return HabitCompletionGraph(viewModel: HabitBarChartViewModel(habit: HabitItem.testHabit))
            .aspectRatio(1.5/1, contentMode: .fit)
            .previewLayout(.sizeThatFits)
    }
}

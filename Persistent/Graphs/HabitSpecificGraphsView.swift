//
//  HabitSpecificGraphsView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 08.10.21.
//

import SwiftUI

struct HabitSpecificGraphsView: View {
    @ObservedObject var habit: HabitItem
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.purchaseInfo) var purchaseInfo
    @Environment(\.parentSizeClass) var parentSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.colorScheme) var colorScheme
    
    // Models
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var appViewModel: AppViewModel
    @EnvironmentObject private var storeManager: StoreManager
    
    
    @StateObject var chartModel: ChartModel = ChartModel()
    
    @State private var buyPremiumViewSelected: Bool = false
    
    func formatDoubleNumberTwoDigits(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        guard let string = formatter.string(from: value as NSNumber) else { return "" }
        return string
    }
    
    func formatDoubleNumberNoDigits(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        guard let string = formatter.string(from: value as NSNumber) else { return "" }
        return string
    }
    
    struct HorizontalTextView: View {
        let color: Color
        
        let leadingText: LocalizedStringKey
        let trailingText: LocalizedStringKey
        
        var body: some View {
            let textViewLeading = Text(leadingText)
                .font(.system(.title, design: .rounded, weight: .heavy))
                .foregroundColor(color)
            
            let textViewTrailing = Text(trailingText)
                .font(.system(.title3, design: .rounded, weight: .semibold))
            
            Text("\(textViewLeading)\u{200B}\(textViewTrailing)")
        }
    }
    
    struct StatisticsBoxView: View {
        let color: Color
        
        let labelString: LocalizedStringKey
        
        let leadingText: LocalizedStringKey
        let trailingText: LocalizedStringKey
        
        let bottomText: LocalizedStringKey
        
        var body: some View {
            GroupBox {
                HStack {
                    VStack(alignment: .leading) {
                        HorizontalTextView(
                            color: color,
                            leadingText: leadingText,
                            trailingText: trailingText
                        )
                        
                        Text(bottomText)
                            .font(.system(.callout, design: .rounded, weight: .light))
                    }
                    
                    Spacer()
                }
            } label: {
                Text(labelString)
                    .font(.system(.title3, design: .rounded, weight: .bold))
            }
        }
    }
    
    @State private var showPremiumView: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                GroupBox {
                    RoundedBarChartView(
                        chartModel: chartModel,
                        habit: habit
                    )
                }
                .overlay {
                    if !purchaseInfo.wrappedValue {
                        Button("Statistics.PremiumNeeded") {
                            showPremiumView = true
                        }
                        .font(.headline)
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    }
                }
                
//                    ZStack {
//                        GroupBox {
//                            RoundedBarChartView(
//                                chartModel: chartModel,
//                                habit: habit
//                            )
//                        }
//
//
//                        if !purchaseInfo.wrappedValue {
//                            NavigationLink("Premium", value: HabitSpecificGraphsNavigationEnum.premium)
//                                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
//                                .navigationDestination(for: HabitSpecificGraphsNavigationEnum.self) { nav in
//                                    switch nav {
//                                    case .premium:
//                                        BuyPremiumView()
//                                    }
//                                }
//                        }
//                    }
                .frame(height: parentSizeClass == .regular ? 350 : 250)
                
                Grid {
                    GridRow {
                        StatisticsBoxView(
                            color: habit.iconColor,
                            labelString: "Statistics.BoxView.AbsolutGoal.Header",
                            leadingText: "\(chartModel.getSuccessfulCompletions(for: habit))",
                            trailingText: "Statistics.BoxView.AbsolutGoal.Trailing",
                            bottomText: "Statistics.BoxView.AbsolutGoal.Bottom"
                        )
                        .overlay {
                            if !purchaseInfo.wrappedValue {
                                VStack {
                                    
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        
                        StatisticsBoxView(
                            color: habit.iconColor,
                            labelString: "Statistics.BoxView.PercentageGoal.Header",
                            leadingText: "\(formatDoubleNumberNoDigits(chartModel.getPercentageDone(for: habit)))",
                            trailingText: "Statistics.BoxView.PercentageGoal.Trailing",
                            bottomText: "Statistics.BoxView.PercentageGoal.Bottom"
                        )
                        .overlay {
                            if !purchaseInfo.wrappedValue {
                                VStack {
                                    
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }
                
                Spacer()
            }
            
            // Ohne gibt es eine weirde Insert Transition
            .transition(.move(edge: .top))
            .padding()
            .navigationTitle("DetailView.Statistics.Header")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text("General.Buttons.Close")
                    }
                    .accessibilityIdentifier("CloseButton")
                }
            }
            .sheet(isPresented: $showPremiumView) {
                NavigationStack {
                    BuyPremiumView()
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button(role: .cancel) {
                                    showPremiumView = false
                                } label: {
                                    Text("General.Buttons.Close")
                                }
                            }
                        }
                }
                    .accentColor(userSettings.accentColor)
                    .environmentObject(userSettings)
                    .environmentObject(appViewModel)
                    .environmentObject(storeManager)
                    .environment(\.horizontalSizeClass, horizontalSizeClass)
                    .environment(\.purchaseInfo, purchaseInfo)
                    .preferredColorScheme(colorScheme)
            }
        }
    }
}

extension HabitSpecificGraphsView {
    enum HabitSpecificGraphsNavigationEnum: Hashable {
        case premium
    }
}

struct HabitSpecificGraphsView_Previews: PreviewProvider {
    static var previews: some View {
        HabitSpecificGraphsView(habit: HabitItem.testHabit)
            .environment(\.purchaseInfo, .constant(true))
    }
}

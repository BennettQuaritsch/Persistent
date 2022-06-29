//
//  CalendarPageViewController.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 29.10.21.
//

import SwiftUI
import UIKit

class CalendarViewController: UIViewController {
    private var pageController: UIPageViewController?
    private var currentIndex: Int = 0
    private var currentSwiftUIView: UIHostingController<CalendarView>?
    
    //CalendarView
    @Binding var toggle: Bool
    @Binding var habitDate: Date
    var date: Date
    var habit: HabitItem
    
    var monthNameLabel: UILabel!
    var leftButton: UIButton!
    var rightButton: UIButton!
    
    init(date: Date, habit: HabitItem, toggle: Binding<Bool>, habitDate: Binding<Date>) {
        self._toggle = toggle
        self._habitDate = habitDate
        self.habit = habit
        self.date = date
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        setupPageController()
        
        monthNameLabel = UILabel()
        monthNameLabel.translatesAutoresizingMaskIntoConstraints = false
        monthNameLabel.textAlignment = .center
        let font = UIFont.preferredFont(forTextStyle: .title2)
//        let boldFont = font.fontDescriptor.withSymbolicTraits(.traitBold)
//        monthNameLabel.font = UIFont(descriptor: boldFont!, size: font.pointSize)
        monthNameLabel.font = UIFont.systemFont(ofSize: font.pointSize, weight: .semibold)
        monthNameLabel.text = getMonthName(date: date)
        
        
        // Button config
        let config = UIImage.SymbolConfiguration(pointSize: 40)
        
        let image = UIImage(systemName: "chevron.backward.circle.fill", withConfiguration: config)
        leftButton = UIButton()
        leftButton.setImage(image, for: .normal)
        leftButton.frame = CGRect(origin: .zero, size: CGSize(width: 44, height: 44))
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        let leftAction = UIAction(handler: { _ in self.previousButton()})
        leftButton.addAction(leftAction, for: .primaryActionTriggered)

        let imageRight = UIImage(systemName: "chevron.forward.circle.fill", withConfiguration: config)
        rightButton = UIButton()
        rightButton.setImage(imageRight, for: .normal)
        rightButton.frame = CGRect(origin: .zero, size: CGSize(width: 44, height: 44))
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        let rightAction = UIAction(handler: { _ in self.nextButton()})
        rightButton.addAction(rightAction, for: .primaryActionTriggered)
        
        // Allgemeines Entfernen der Autorezising Masks - ohne geht nicht
        pageController?.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Add Subviews
        view.addSubview(monthNameLabel)
        view.addSubview(leftButton)
        view.addSubview(rightButton)
        
        NSLayoutConstraint.activate([
            monthNameLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 10),
            monthNameLabel.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            
            leftButton.centerYAnchor.constraint(equalTo: monthNameLabel.layoutMarginsGuide.centerYAnchor),
            leftButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 25),

            rightButton.centerYAnchor.constraint(equalTo: monthNameLabel.layoutMarginsGuide.centerYAnchor),
            rightButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -25),

            pageController!.view.topAnchor.constraint(equalTo: rightButton.layoutMarginsGuide.bottomAnchor, constant: 10),
            pageController!.view.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            pageController!.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageController!.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // more constraints to be added here!
        ])
    }
    
    private func setupPageController() {
        self.pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageController?.dataSource = self
        self.pageController?.delegate = self
        self.pageController?.view.backgroundColor = .clear
        //self.pageController?.view.frame = CGRect(x: 0,y: 0,width: self.view.frame.width,height: self.view.frame.height)
        self.addChild(self.pageController!)
        self.view.addSubview(self.pageController!.view)
                
        let initialVC = UIHostingController(rootView: CalendarView(toggle: $toggle, habit: habit, date: getMonth(currentIndex), habitDate: $habitDate))
        currentSwiftUIView = initialVC
                
        self.pageController?.setViewControllers([initialVC], direction: .forward, animated: true, completion: nil)
                
        self.pageController?.didMove(toParent: self)
    }
    
    func getMonth(_ index: Int) -> Date {
        var date = Date()
        
        let cal = Calendar.defaultCalendar as NSCalendar
        
        date = cal.date(byAdding: [.month], value: index, to: date, options: [])!
        
        return date
    }
    
    func nextButton() {
        guard let controller = pageController?.viewControllers?.first as? UIHostingController<CalendarView> else { return }
        
        let currentDate = controller.rootView.date
        
        let addedDate = Calendar.defaultCalendar.date(byAdding: .month, value: 1, to: currentDate, wrappingComponents: false)!
        
        let swiftUIView = UIHostingController(rootView: CalendarView(toggle: $toggle, habit: habit, date: addedDate, habitDate: $habitDate))
        
        self.monthNameLabel.text = getMonthName(date: addedDate)
        
        self.pageController?.setViewControllers([swiftUIView], direction: .forward, animated: true, completion: nil)
    }
    
    func previousButton() {
        guard let controller = pageController?.viewControllers?.first as? UIHostingController<CalendarView> else { return }
        
        let currentDate = controller.rootView.date
        
        let addedDate = Calendar.defaultCalendar.date(byAdding: .month, value: -1, to: currentDate, wrappingComponents: false)!
        
        let swiftUIView = UIHostingController(rootView: CalendarView(toggle: $toggle, habit: habit, date: addedDate, habitDate: $habitDate))
        
        self.monthNameLabel.text = getMonthName(date: addedDate)
        
        self.pageController?.setViewControllers([swiftUIView], direction: .reverse, animated: true, completion: nil)
    }
}

extension CalendarViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        currentIndex -= 1
        
        guard let controller = viewController as? UIHostingController<CalendarView> else { return nil }
        
        let currentDate = controller.rootView.date
//        self.monthNameLabel.text = getMonthName(date: currentDate)
        
        //Calendar.current.date(byAdding: [DateCom], to: <#T##Date#>, wrappingComponents: <#T##Bool#>)
        
        let date = Calendar.defaultCalendar.date(byAdding: .month, value: -1, to: currentDate, wrappingComponents: false)!
        
        print("\(currentIndex): \(date)")
        
        let swiftUIView = UIHostingController(rootView: CalendarView(toggle: $toggle, habit: habit, date: date, habitDate: $habitDate))
        currentSwiftUIView = swiftUIView
        
        //guard currentIndex == 0 else { return nil }
        
        //currentIndex -= 1
        
        return swiftUIView
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        currentIndex += 1
        
        guard let controller = viewController as? UIHostingController<CalendarView> else { return nil }
        
        let currentDate = controller.rootView.date
//        self.monthNameLabel.text = getMonthName(date: currentDate)
        
        let date = Calendar.defaultCalendar.date(byAdding: .month, value: 1, to: currentDate, wrappingComponents: false)!
        
        print("\(currentIndex): \(date)")
        
        let swiftUIView = UIHostingController(rootView: CalendarView(toggle: $toggle, habit: habit, date: date, habitDate: $habitDate))
        currentSwiftUIView = swiftUIView
        
        
        
        //guard currentIndex == 2 else { return nil }
        
        //currentIndex += 1
        
        return swiftUIView
    }
    
    /// Label Namen ändern, nachdem die Page gewechselt wurde
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let controller = pageViewController.viewControllers?.first as? UIHostingController<CalendarView> else { return }
        
        let currentDate = controller.rootView.date
        self.monthNameLabel.text = getMonthName(date: currentDate)
    }
    
    func getMonthName(date: Date) -> String {
        return "\(date.formatted(.dateTime.month(.wide))) \(date.formatted(.dateTime.year()))"
    }
}

struct PageViewRepresentable: UIViewControllerRepresentable {
    @Binding var toggle: Bool
    @Binding var habitDate: Date
    var date: Date
    var habit: HabitItem
    
    func makeUIViewController(context: Context) -> CalendarViewController {
        return CalendarViewController(date: date, habit: habit, toggle: $toggle, habitDate: $habitDate)
    }
    
    func updateUIViewController(_ uiViewController: CalendarViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = CalendarViewController
    
    
}

struct CalendarPageViewController: View {
    @Binding var toggle: Bool
    @Binding var habitDate: Date
    var date: Date
    var habit: HabitItem
    
    var body: some View {
        NavigationView {
            VStack {
                PageViewRepresentable(toggle: $toggle, habitDate: $habitDate, date: Date(), habit: habit)
                
                Spacer()
            }
            #if os(iOS)
            .navigationTitle("Calendar")
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        toggle = false
                    } label: {
                        Text("Close")
                    }
                }
            }
        }
    }
}

struct CalendarPageViewController_Previews: PreviewProvider {
    static var previews: some View {
        return CalendarPageViewController(toggle: .constant(true), habitDate: .constant(Date()), date: Date(), habit: HabitItem.testHabit)
    }
}

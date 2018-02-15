//
//  JBDatePickerWeekView.swift
//  JBDatePicker
//
//  Created by Joost van Breukelen on 13-10-16.
//  Copyright © 2016 Joost van Breukelen. All rights reserved.
//

import UIKit

final class JBDatePickerWeekView: UIStackView {

    // MARK: - Properties
    private weak var datePickerView: JBDatePickerView!
    private weak var monthView: JBDatePickerMonthView!
    private var index: Int!
    private var dayViews: [JBDatePickerDayView]!
    

    // MARK: - Initialization
    init(datePickerView: JBDatePickerView, monthView: JBDatePickerMonthView, index: Int) {
        
        self.datePickerView = datePickerView
        self.monthView = monthView
        self.index = index
        super.init(frame: .zero)
        
        self.axis = .horizontal
        self.distribution = .fillEqually
        
        //self.backgroundColor = randomColor()
        createDayViews()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Create dayView
    
    ///fills the weekView stack with dayviews
    private func createDayViews() {
        
        dayViews = [JBDatePickerDayView]()
        
        for i in 0..<7 {

            //guard statement to prevent index getting out or range (some months need only 5 (index 4) weeks, index goes up to 5)
            guard index < monthView.monthInfo.weekDayInfo.count else { return }

            let dayInfo = monthView.monthInfo.weekDayInfo[index][i]
            let dayView = JBDatePickerDayView(datePickerView: datePickerView, monthView: monthView, weekView: self, index: i, dayInfo: dayInfo!)
            dayViews.append(dayView)
            addArrangedSubview(dayView)
        }
        
    }
        
}

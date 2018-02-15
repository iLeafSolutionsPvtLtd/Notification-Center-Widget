//
//  JBDate.swift
//  JBDatePicker
//
//  Created by Joost van Breukelen on 22-10-16.
//  Copyright © 2016 Joost van Breukelen. All rights reserved.
//

import UIKit


/**
 This class defines a day in the week of a certain month and provides
 information on whether or not the day falls in the month itself or not.
 If not, the day belongs to the previous or next month.
 */
final class JBDay {
    
    var dayValue: Int
    var monthValue: Int
    var yearValue: Int
    var isInMonth: Bool
    
    init(dayValue: Int, monthValue: Int, yearValue: Int, isInMonth: Bool) {
        self.dayValue = dayValue
        self.monthValue = monthValue
        self.yearValue = yearValue
        self .isInMonth = isInMonth
    }
    
    var date: Date? {
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.day, .month, .year], from: Date())
        comps.year = yearValue
        comps.month = monthValue
        comps.day = dayValue
        return Calendar.current.date(from: comps)
    }
}

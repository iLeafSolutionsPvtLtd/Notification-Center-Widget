//
//  JBDatePickerManager.swift
//  JBDatePicker
//
//  Created by Joost van Breukelen on 12-10-16.
//  Copyright © 2016 Joost van Breukelen. All rights reserved.
//

import UIKit

final class JBDatePickerManager {
    
    // MARK: - Properties
    private var components: DateComponents
    private unowned let datePickerView: JBDatePickerView
    private var calendar: Calendar = .current
    private var currentDate: Date = Date()
    private var startdayOfWeek: Int

    
    
    // MARK: - Initialization
    
    init(datePickerView: JBDatePickerView) {
        self.datePickerView = datePickerView
        self.components = calendar.dateComponents([.month, .day], from: currentDate)
        startdayOfWeek = (datePickerView.delegate?.firstWeekDay.rawValue)!
        
        //let user preference prevail about default
        calendar.firstWeekday = startdayOfWeek
        
    }
    
    
    // MARK: - Date information
    
    /**
     Gets the startdate and the enddate of the month of a certain date and also the amount of weeks
     for that month and all the days with their weekViewIndex and value
     
     - Parameter date: the Date object of the month that we want the info about
     - Returns: a tuple holding the startdate, the enddate, the number of weeks and 
     an array holding dictionaries with the weekDayIndex as key and a JBDay object as value.
     The JBDay object holds the value (like 17) and a bool that determines that the day involved
     is included in the month or not.
     */
    func getMonthInfoForDate(_ date: Date) -> (monthStartDay: Date, monthEndDay: Date, numberOfWeeksInMonth: Int, weekDayInfo: [[Int:JBDay]]) {
        
        var components = calendar.dateComponents([.year, .month, .weekOfMonth], from: date)
        
        //first day of the month
        components.day = 1
        let monthValue = components.month!
        let yearValue = components.year!
        let monthStartDay = calendar.date(from: components)!
        
        //last day of the month
        components.month! += 1
        let nextMonthValue = components.month!
        let nextYearValue = components.year!
        components.day! -= 1
        let monthEndDay = calendar.date(from: components)!
        
        //reset components
        components = calendar.dateComponents([.year, .month, .weekOfMonth], from: date)
        
        //last day of the previous month. We have to substract two because we went up to get the next month
        components.month! -= 1
        let previousMonthEndDay = calendar.date(from: components)!
        let previousMonthValue = components.month!
        let previousYearValue = components.year!
        
        //count of weeks in month
        var numberOfWeeksInMonth: Int = calendar.range(of: .weekOfMonth, in: .month, for: date)!.count
        
        //get dates that fall within the month
        let datesInRange = calendar.range(of: .day, in: .month, for: date)
        var monthDatesArray = [Int]()
        for value in 1..<datesInRange!.upperBound {
            monthDatesArray.append(value)
        }

        //find weekday index of first- and lastDay of month in their week.
        let firstDayIndexInWeekView = indexForDate(calendar.dateComponents([.weekday], from: monthStartDay).weekday!)
        let lastDayIndexInWeekView = indexForDate(calendar.dateComponents([.weekday], from: monthEndDay).weekday!)
        
        //get dates that fall within next month
        var nextMonthDatesArray = [Int]()
        let numberOfDaysInNextMonth = 6 - lastDayIndexInWeekView
        if numberOfDaysInNextMonth > 0 {
            for value in 1...numberOfDaysInNextMonth {
                nextMonthDatesArray.append(value)
            }
        }
        
        //get dates that fall within previous month
        var previousMonthDatesArray = [Int]()
        let datesInRangeOfPreviousMonth = calendar.range(of: .day, in: .month, for: previousMonthEndDay)
        let numberOfDaysInPreviousMonth = 7 - (7 - firstDayIndexInWeekView)
        let subRangeLowerBound = (datesInRangeOfPreviousMonth?.upperBound)! - numberOfDaysInPreviousMonth
        let upperBound = (datesInRangeOfPreviousMonth?.upperBound)!

        if subRangeLowerBound < upperBound {
            for value in subRangeLowerBound..<upperBound {
                previousMonthDatesArray.append(value)
            }
        }

        
        //if the total amount of dates is larger then the amount of weeks * 7, give an extra week
        if monthDatesArray.count + previousMonthDatesArray.count + nextMonthDatesArray.count > numberOfWeeksInMonth * 7 {
            numberOfWeeksInMonth += 1
        }
        
        //create array of dictionaries that we well return in the end
        var weeksInMonthInformationToReturn = [[Int:JBDay]]()
        
        //this value holds 0 to the number of days in a month
        var dayOfMonthIndex: Int = 0

        for weekIndex in 0..<numberOfWeeksInMonth {
            
            //this value holds 0 to 6 (the index of the day in the week)
            var dayOfWeekIndex: Int = 0
            
            switch weekIndex {
            case 0:
                
                var weekInformationToReturn = [Int:JBDay]()
                
                //get the last days of the previous month
                for i in 0..<previousMonthDatesArray.count {
                    let dayInPreviousMonthValue = previousMonthDatesArray[i]
                    let dayInPreviousMonth = JBDay(dayValue: dayInPreviousMonthValue, monthValue: previousMonthValue, yearValue: previousYearValue, isInMonth: false)
                    weekInformationToReturn[i] = dayInPreviousMonth
                }
                
                //get the first days of the month
                let amountOfFirstDays = 7 - firstDayIndexInWeekView
                guard amountOfFirstDays >= 1 else {continue}
                
                dayOfWeekIndex = firstDayIndexInWeekView
                
                for _ in 0..<amountOfFirstDays {
                    
                    let dayInFirstWeekOfMonth = monthDatesArray[dayOfMonthIndex]
                    let dayInWeek = JBDay(dayValue: dayInFirstWeekOfMonth, monthValue: monthValue, yearValue: yearValue, isInMonth: true)
                    weekInformationToReturn[dayOfWeekIndex] = dayInWeek
                    dayOfWeekIndex += 1
                    dayOfMonthIndex += 1
                }
                
                weeksInMonthInformationToReturn.append(weekInformationToReturn)
                
            case numberOfWeeksInMonth - 1:
                
                var weekInformationToReturn = [Int:JBDay]()
                
                //get the last days of the month
                let amountOfLastDays = 7 - (6 - lastDayIndexInWeekView)
                guard dayOfMonthIndex < monthDatesArray.count else {
                    
                    //remove unnecessary week line
                    numberOfWeeksInMonth -= 1
                    continue
                }
                
                for _ in 0..<amountOfLastDays {
                    
                    let dayInLastWeekOfMonth = monthDatesArray[dayOfMonthIndex]
                    let dayInWeek = JBDay(dayValue: dayInLastWeekOfMonth, monthValue: monthValue, yearValue: yearValue, isInMonth: true)
                    weekInformationToReturn[dayOfWeekIndex] = dayInWeek
                    dayOfWeekIndex += 1
                    dayOfMonthIndex += 1
                }
                
                //get the first days of the next month
                for i in 0..<nextMonthDatesArray.count {
                    let dayInNextMontValue = nextMonthDatesArray[i]
                    let dayInNextMonth = JBDay(dayValue: dayInNextMontValue, monthValue: nextMonthValue, yearValue: nextYearValue, isInMonth: false)
                    weekInformationToReturn[dayOfWeekIndex + i] = dayInNextMonth
                }
                
                weeksInMonthInformationToReturn.append(weekInformationToReturn)
                
            default:
                
                //this is the default case (the 'middle weeks')
                guard dayOfMonthIndex < monthDatesArray.count else {continue}
                var weekInformationToReturn = [Int:JBDay]()
                
                for _ in 0...6 {
                    
                    let dayInWeekOfMonth = monthDatesArray[dayOfMonthIndex]
                    let dayInWeek = JBDay(dayValue: dayInWeekOfMonth, monthValue: monthValue, yearValue: yearValue, isInMonth: true)
                    weekInformationToReturn[dayOfWeekIndex] = dayInWeek
                    dayOfWeekIndex += 1
                    dayOfMonthIndex += 1
                    
                }
                
                weeksInMonthInformationToReturn.append(weekInformationToReturn)
            }
            
            
        }

        return (monthStartDay, monthEndDay, numberOfWeeksInMonth, weeksInMonthInformationToReturn)
        
    }
    
    // MARK: - Helpers
    
    private func basicComponentsForDate(_ date: Date) -> DateComponents {
        
        return calendar.dateComponents([.year, .month, .weekOfMonth, .day], from: date)
        
    }
    
    /**
     This is a correctionFactor. A day that falls on a thursday will always have weekday 5. Sunday is 1, Saterday is 7. However, in the weekView, this will be indexnumber 4 when week starts at sunday, and indexnumber 3 when week starts on a monday. If the week was to start on a thursday, the correctionfactor will be 5. Because this day will get index 0 in the weekView in that case. 
     The function basically returns this dictionary: [-6:1, -5:2, -4:3, -3:4, -2:5, -1:6, 0:0, 1:1, 2:2, 3:3, 4:4, 5:5, 6:6]
     */
    private func indexForDate(_ weekDay: Int) -> Int {
        
        let basicIndex = weekDay - startdayOfWeek
        
        if basicIndex < 0 {
            return basicIndex + 7
        }
        else{
            return basicIndex
        }
    
    }
    
    
    
}




//
//  JBDatePickerViewDelegate.swift
//  JBDatePicker
//
//  Created by Joost van Breukelen on 17-10-16.
//  Copyright © 2016 Joost van Breukelen. All rights reserved.
//

import UIKit

public protocol JBDatePickerViewDelegate: class {
    
    /**
     Is called when the user selected a day
     - parameter dayView: the dayView the user selected
     - note:
     Implementing this method is mandatory
     */
    func didSelectDay(_ dayView: JBDatePickerDayView)
    
    /**
     Is called when the user swiped (or manually moved) to another month
     - parameter monthView: the monthView that is now 'on screen'
     - note:
     Implementing this method is optional.
     */
    func didPresentOtherMonth(_ monthView: JBDatePickerMonthView)
    
    /**
     Is called to check if any particular date is selectable by the picker
     - parameter date: the date to check if allowed
     - note:
     Implementing this method is optional.
     */
    func shouldAllowSelectionOfDay(_ date: Date?) -> Bool

    /**
     Is called when setting up the calendar view as an override point for customization of weekday labels
     - parameter calendar: calendar instance used by the calendar view
     - note:
     Implementing this method is optional.
     */
    func weekdaySymbols(for calendar: Calendar) -> [String]

    /**
     Sets the day that determines which month is shown on initial load
     - note:
     Implementing this variable is optional. It's default is set the current date.
     */
    var dateToShow: Date {get}
 
    
    /**
     Sets the first day of the week. 
     - note:
     Implementing this variable is optional. It's default is set to the locale.
     */
    var firstWeekDay: JBWeekDay {get}
    
    
    /**
     Determines if a month should also show the dates of the previous and next month
     - note:
     Implementing this variable is optional. It's default is set to true.
     */
    var shouldShowMonthOutDates: Bool {get}
    
    /**
     Determines if the weekday symbols and the month description should follow available localizations
     - note:
     Implementing this variable is optional. It's default is set to false. This means that the weekday symbols
     and the month description will be in the same language as the device language. If you want it to conform to the
     localization of your app, return true here. If you return true and your app is not localized, the weekday symbols and 
     the month description will be in the development language.
     */
    var shouldLocalize: Bool {get}
    
    
    // MARK: - General appearance properties
    
    /**
     Determines the height ratio of the weekDaysView compared to the total height
     
     - note:
     Implementing this variable is optional. It's default is set to 0.1 (10%).
     
     */
    var weekDaysViewHeightRatio: CGFloat {get}
    
    /**
     Determines the shape that is used to indicate a selected date. Possiblilities are:
     .circle, .square, .roundedRect
     
     - note: 
     Implementing this variable is optional. It's default is set to .circle.
     
     */
    var selectionShape: JBSelectionShape { get }
    
    /**
     font of the date labels. Defaults to systemfont with a medium size.
     
     - Note: you can use any UIFont name you want, as long as it is available. If it's not available, JBDatePicker will
     use the systemfont instead. If you want to use the systemfont but customize it's size, use an empty string as the
     fontname.
     
     ## Usage Example: ##
     ````
     //set custom font
     var fontForDayLabel: JBFont {
        return JBFont(name: "AvenirNext-MediumItalic", size: .medium)
     }
     
     //set system font with custom size
     var fontForDayLabel: JBFont {
        return JBFont(name: "", size: .large)
     }
     
     ````
     */
    var fontForDayLabel: JBFont { get }
    
    
    // MARK: - Text Color appearance properties
    
    ///color of any date label text that falls within the presented month
    var colorForDayLabelInMonth: UIColor { get }
    
    ///color of any date label text that falls out of the presented month and is part of the next or previous (but not presented) month
    var colorForDayLabelOutOfMonth: UIColor { get }
    
    ///color of any date label text that occurs outside the allowed selectable days (day earlier than earliest selectable or later than last selectable)
    var colorForUnavaibleDay: UIColor { get }
    
    ///color of the 'today' date label text
    var colorForCurrentDay: UIColor { get }
    
    ///color of any label text that is selected
    var colorForSelelectedDayLabel: UIColor { get }
    
    
    // MARK: - WeekdaysView appearance properties
    
    ///color of the bar which shows the 'mon' to 'sun' labels. Defaults to green. 
    var colorForWeekDaysViewBackground: UIColor { get }
    
    ///color of the labels in the WeekdaysView bar that say 'mon' to 'sun'. Defaults to white.
    var colorForWeekDaysViewText: UIColor { get }
    
    
    /**
    font of the labels in the WeekdaysView bar that say 'mon' to 'sun'. Defaults to systemfont with 
     a medium size.
     
     - Note: you can use any UIFont name you want, as long as it is available. If it's not available, JBDatePicker will
     use the systemfont instead. If you want to use the systemfont but customize it's size, use an empty string as the 
     fontname. 
     
     ## Usage Example: ##
     ````
     //set custom font
     var fontForWeekDaysViewText: JBFont {
        return JBFont(name: "AvenirNext-MediumItalic", size: .medium)
     }
     
     //set system font with custom size
     var fontForWeekDaysViewText: JBFont {
        return JBFont(name: "", size: .large)
     }
     
     ````
     */
    var fontForWeekDaysViewText: JBFont { get }
    
    
    // MARK: - Selection Color appearance properties
    
    ///color of the selection circle for dates that aren't today
    var colorForSelectionCircleForOtherDate: UIColor { get }
    
    ///color of the selection circle for today
    var colorForSelectionCircleForToday: UIColor { get }
    
    ///color of the semi selected selection circle (that shows on a long press)
    var colorForSemiSelectedSelectionCircle: UIColor { get }
    
}

/**
 This protocol extension is used to make some of the delegate methods and variables optional by giving them a default implementation or value.
 */
public extension JBDatePickerViewDelegate {
    
    public func didPresentOtherMonth(_ monthView: JBDatePickerMonthView) {}
    public func shouldAllowSelectionOfDay(_ date: Date?) -> Bool { return true }
    public func weekdaySymbols(for calendar: Calendar) -> [String] { return calendar.shortStandaloneWeekdaySymbols }
    
    // MARK: - General defaults
    
    public var dateToShow: Date { return Date()}
    public var firstWeekDay: JBWeekDay {
        
        if let calendarValue = JBWeekDay(rawValue: Calendar.current.firstWeekday){
            return calendarValue
        }
        else {
            return .monday
        }
    }
    
    public var shouldShowMonthOutDates: Bool { return true }
    public var shouldLocalize: Bool { return false }
    public var weekDaysViewHeightRatio: CGFloat { return 0.1 }
    public var selectionShape: JBSelectionShape { return .circle }
    public var fontForDayLabel: JBFont { return JBFont() }
    
    // MARK: - Color defaults
    
    public var colorForDayLabelInMonth: UIColor { return .darkGray }
    public var colorForDayLabelOutOfMonth: UIColor { return .lightGray }
    public var colorForUnavaibleDay: UIColor { return .lightGray }
    public var colorForCurrentDay: UIColor { return .red }
    public var colorForSelelectedDayLabel: UIColor { return .white }
    public var colorForWeekDaysViewBackground: UIColor { return  UIColor(red: 81.0/255.0, green: 182.0/255.0, blue: 185.0/255.0, alpha: 1.0) }
    public var colorForWeekDaysViewText: UIColor { return .white }
    public var fontForWeekDaysViewText: JBFont { return JBFont() }
    public var colorForSelectionCircleForOtherDate: UIColor { return  UIColor(red: 81.0/255.0, green: 182.0/255.0, blue: 185.0/255.0, alpha: 1.0) }
    public var colorForSelectionCircleForToday: UIColor { return UIColor(red: 255.0/255.0, green: 98.0/255.0, blue: 89.0/255.0, alpha: 1.0) }
    public var colorForSemiSelectedSelectionCircle: UIColor { return UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0) }
}

//
//  JBDatePickerEnums.swift
//  JBDatePicker
//
//  Created by Joost van Breukelen on 09-10-16.
//  Copyright © 2016 Joost van Breukelen. All rights reserved.
//

import UIKit

enum MonthViewIdentifier: Int { case previous, presented, next }
enum JBScrollDirection { case none, toNext, toPrevious }

//In a calendar, day, week, weekday, month, and year numbers are generally 1-based. So Sunday is 1. 
public enum JBWeekDay: Int { case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday }
public enum JBSelectionShape { case circle, square, roundedRect }
public enum JBFontSize { case verySmall, small, medium, large, veryLarge }

//only for debugging
func randomColor() -> UIColor{
    
    let red = CGFloat(randomInt(min: 0, max: 255)) / 255
    let green = CGFloat(randomInt(min: 0, max: 255)) / 255
    let blue = CGFloat(randomInt(min: 0, max: 255)) / 255
    let randomColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
    
    return randomColor
}

func randomInt(min: Int, max:Int) -> Int {
    return min + Int(arc4random_uniform(UInt32(max - min + 1)))
}

func randomFloat(min: Int, max:Int) -> Int {
    return min + Int(arc4random_uniform(UInt32(max - min + 1)))
}

//
//  JBDateExtension.swift
//  JBDatePicker
//
//  Created by Joost van Breukelen on 17-10-16.
//  Copyright © 2016 Joost van Breukelen. All rights reserved.
//

import UIKit

extension Date {
    
    func stripped() -> Date?{
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        let strippedDate = calendar.date(from: components)
        
        return strippedDate
        
    }
}

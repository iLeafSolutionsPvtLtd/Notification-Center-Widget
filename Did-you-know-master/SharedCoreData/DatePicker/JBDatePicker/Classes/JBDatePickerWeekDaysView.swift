//
//  JBDatePickerWeekDaysView.swift
//  JBDatePicker
//
//  Created by Joost van Breukelen on 24-10-16.
//  Copyright © 2016 Joost van Breukelen. All rights reserved.
//

import UIKit

public final class JBDatePickerWeekDaysView: UIStackView {

    // MARK: - Properties
    private weak var datePickerView: JBDatePickerView!
    private var firstWeekDay: JBWeekDay!
    private var weekdayNameSymbols = [String]()
    private var weekdayLabels = [UILabel]()
    private var weekdayLabelTextColor: UIColor!
    
    
    // MARK: - Initialization
    public init(datePickerView: JBDatePickerView) {
        self.datePickerView = datePickerView
        super.init(frame: .zero)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        guard datePickerView != nil else {return}
        
        //stackView setup
        self.axis = .horizontal
        self.distribution = .fillEqually
        self.translatesAutoresizingMaskIntoConstraints = false
        
        //get preferences
        firstWeekDay = datePickerView.delegate?.firstWeekDay
        
        //setup appearance
        self.weekdayLabelTextColor = datePickerView.delegate?.colorForWeekDaysViewText
        
        //get weekday name symbols
        var cal = Calendar.current
        if let preferredLanguage = Bundle.main.preferredLocalizations.first {
            if datePickerView.delegate?.shouldLocalize == true {
                cal.locale = Locale(identifier: preferredLanguage)
            }
        }
        weekdayNameSymbols = datePickerView.delegate?.weekdaySymbols(for: cal) ?? cal.shortStandaloneWeekdaySymbols
        
        //adjust order of weekDayNameSymbols if needed
        let firstWeekdayIndex = firstWeekDay.rawValue - 1
        if firstWeekdayIndex >= 0 {
            
            //create new array order by slicing according to firstweekday
            let sliceOne = weekdayNameSymbols[firstWeekdayIndex...6]
            let sliceTwo = weekdayNameSymbols[0..<firstWeekdayIndex]
            weekdayNameSymbols = Array(sliceOne + sliceTwo)
        }
        
        //create and place labels. Setup constraints
        for i in 0...6 {
            
            //this containerView is used to prevent visible stretching of the weekDaylabel while turning the device
            let labelContainerView = UIView()
            labelContainerView.backgroundColor = datePickerView.delegate?.colorForWeekDaysViewBackground
            self.addArrangedSubview(labelContainerView)
            
            let weekDayLabel = UILabel()
            weekDayLabel.textAlignment = .center
            weekDayLabel.text = weekdayNameSymbols[i].uppercased()
            weekDayLabel.textColor = weekdayLabelTextColor
            weekDayLabel.translatesAutoresizingMaskIntoConstraints = false
            weekdayLabels.append(weekDayLabel)
            labelContainerView.addSubview(weekDayLabel)
            
            weekDayLabel.centerXAnchor.constraint(equalTo: labelContainerView.centerXAnchor).isActive = true
            weekDayLabel.centerYAnchor.constraint(equalTo: labelContainerView.centerYAnchor).isActive = true

        }
        
    }
    
    
    public override func layoutSubviews() {
        updateLayout()
    }
    
    func updateLayout() {
        
        //get preferred font
        guard let preferredFont = datePickerView.delegate?.fontForWeekDaysViewText else { return }
        
        //get preferred size
        let preferredSize = preferredFont.fontSize
        let sizeOfFont: CGFloat
        
        //calculate fontsize to be used
        switch preferredSize {
            case .verySmall: sizeOfFont = min(frame.size.width, frame.size.height) / 4
            case .small: sizeOfFont = min(frame.size.width, frame.size.height) / 3.5
            case .medium: sizeOfFont = min(frame.size.width, frame.size.height) / 3
            case .large: sizeOfFont = min(frame.size.width, frame.size.height) / 2
            case .veryLarge: sizeOfFont = min(frame.size.width, frame.size.height) / 1.5
        }

        //get font to be used
        let fontToUse: UIFont
        switch preferredFont.fontName.isEmpty {
        case true:
            fontToUse = UIFont.systemFont(ofSize: sizeOfFont )
        case false:
            if let customFont = UIFont(name: preferredFont.fontName, size: sizeOfFont) {
                fontToUse = customFont
            }
            else {
                 print("custom font '\(preferredFont.fontName)' for weekdaysView not available. JBDatePicker will use system font instead")
                 fontToUse = UIFont.systemFont(ofSize: sizeOfFont)
            }
        }

        //set text and font on labels 
        for (index, label) in weekdayLabels.enumerated() {
            
            let labelText = weekdayNameSymbols[index]
            label.attributedText =  NSMutableAttributedString(string: labelText, attributes:[NSFontAttributeName:fontToUse])
        }
    }
    
    


}

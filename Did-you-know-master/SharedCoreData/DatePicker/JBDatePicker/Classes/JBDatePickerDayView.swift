//
//  JBDatePickerDayView.swift
//  JBDatePicker
//
//  Created by Joost van Breukelen on 13-10-16.
//  Copyright © 2016 Joost van Breukelen. All rights reserved.
//

import UIKit

public final class JBDatePickerDayView: UIView {

    // MARK: - Properties
    private var index: Int!
    private var dayInfo: JBDay!
    weak private var weekView: JBDatePickerWeekView!
    weak private var monthView: JBDatePickerMonthView!
    weak var datePickerView: JBDatePickerView!
    public var date: Date?

    var isToday: Bool {
        return date == Date().stripped()
    }
    
    private var textLabel: UILabel!
    private weak var selectionView: JBDatePickerSelectionView?
    
    private let longPressArea: CGFloat = 40
    private var longPressAreaMaxX: CGFloat { return bounds.width + longPressArea }
    private var longPressAreaMaxY: CGFloat { return bounds.height + longPressArea }
    private var longPressAreaMin: CGFloat { return -longPressArea }
    
    
    // MARK: - Initialization
    
    init(datePickerView: JBDatePickerView, monthView: JBDatePickerMonthView, weekView: JBDatePickerWeekView, index: Int, dayInfo: JBDay) {
        
        self.datePickerView = datePickerView
        self.monthView = monthView
        self.weekView = weekView
        self.index = index
        self.dayInfo = dayInfo
        
        if let size = datePickerView.dayViewSize {
            
            let frame = CGRect(x: size.width * CGFloat(index), y: 0, width: size.width, height: size.height)
            super.init(frame: frame)

        }
        else{
            super.init(frame: .zero)
        }
        
        //backgroundColor = randomColor()
        self.date = dayInfo.date
        labelSetup()
        
        if dayInfo.isInMonth {
            
            //set default color
            textLabel.textColor = datePickerView.delegate?.colorForDayLabelInMonth
            
                //check date is selectable, if not selectable, set colour and don't add gestures
                guard datePickerView.dateIsSelectable(date: date) else {
                    self.textLabel.textColor = datePickerView.delegate?.colorForUnavaibleDay
                    return
                }

        }
        else{
            
            if let shouldShow = datePickerView.delegate?.shouldShowMonthOutDates {
                if shouldShow {
                    textLabel.textColor = datePickerView.delegate?.colorForDayLabelOutOfMonth
                    
                    //check date is selectable, if not selectable, don't add gestures
                    guard datePickerView.dateIsSelectable(date: date) else {return}
                }
                else{
                    self.isUserInteractionEnabled = false
                    self.textLabel.isHidden = true
                }
            }
        }

        
        //highlight current day. Must come before selection of selected date, because it would override the text color set by select()
        if isToday {
            self.textLabel.textColor = datePickerView.delegate?.colorForCurrentDay
        }

        //select selected day
        if date == datePickerView.dateToPresent.stripped() {
            guard self.dayInfo.isInMonth else { return }
            datePickerView.selectedDateView = self
            //self.backgroundColor = randomColor()
        }

        //add tapgesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dayViewTapped))
        self.addGestureRecognizer(tapGesture)
        
        //add longPress gesture recognizer
        let pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(dayViewPressed(_:)))
        self.addGestureRecognizer(pressGesture)

    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Label setup
    
    private func labelSetup() {
        
        textLabel = UILabel()
        textLabel.textAlignment = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false 
        self.addSubview(textLabel)
        
        textLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        textLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

    }
    
    private func setupLabelFont() {
        
        //get preferred font
        guard let preferredFont = datePickerView.delegate?.fontForDayLabel else { return }
        
        //get preferred size
        let preferredSize = preferredFont.fontSize
        let sizeOfFont: CGFloat
        
        //calculate fontsize to be used
        switch preferredSize {
        case .verySmall: sizeOfFont = min(frame.size.width, frame.size.height) / 3.5
        case .small: sizeOfFont = min(frame.size.width, frame.size.height) / 3
        case .medium: sizeOfFont = min(frame.size.width, frame.size.height) / 2.5
        case .large: sizeOfFont = min(frame.size.width, frame.size.height) / 2
        case .veryLarge: sizeOfFont = min(frame.size.width, frame.size.height) / 1.5
        }
        
        //get font to be used
        let fontToUse: UIFont
        switch preferredFont.fontName.isEmpty {
        case true:
            fontToUse = UIFont.systemFont(ofSize: sizeOfFont)
        case false:
            if let customFont = UIFont(name: preferredFont.fontName, size: sizeOfFont) {
                fontToUse = customFont
            }
            else {
                print("custom font '\(preferredFont.fontName)' for dayLabel not available. JBDatePicker will use system font instead")
                fontToUse = UIFont.systemFont(ofSize: sizeOfFont)
            }
        }
        
        textLabel.attributedText = NSMutableAttributedString(string: String(dayInfo.dayValue), attributes:[NSFontAttributeName: fontToUse])
        
    }
    
    public override func layoutSubviews() {
        
        textLabel.frame = bounds
        setupLabelFont()
    }
    
    
    // MARK: - Touch handling
    
    @objc public func dayViewTapped() {
        datePickerView.didTapDayView(dayView: self)
    }
    
    @objc public func dayViewPressed(_ gesture: UILongPressGestureRecognizer) {
        
        //if selectedDateView exists and is self, return. Long pressing shouldn't do anything on selected day. 
        if let selectedDate = datePickerView.selectedDateView {
            guard selectedDate != self else { return }
        }
        
        let location = gesture.location(in: self)
        
        switch gesture.state {
        case .began:
            semiSelect(animated: true)
        case .ended:
            if let selView = selectionView {
                selView.removeFromSuperview()
            }
            datePickerView.didTapDayView(dayView: self)
        
        case .changed:
            
            if !(longPressAreaMin...longPressAreaMaxX).contains(location.x) || !(longPressAreaMin...longPressAreaMaxY).contains(location.y) {
 
                semiDeselect(animated: true)
                
                //this will cancel the longpress gesture (and enable it again for the next time)
                gesture.isEnabled = false
                gesture.isEnabled = true
            }

        default:
            break
        }
    }
    
    // MARK: - Reloading
    
    public func reloadContent() {
        textLabel.frame = bounds
        setupLabelFont()
        
        //reload selectionView
        if let selView = selectionView {

            selView.frame = textLabel.frame
            selView.setNeedsDisplay()
        }

    }
    
    
    // MARK: - Selection & Deselection
    
    func select() {

        let selView = JBDatePickerSelectionView(dayView: self, frame: self.bounds, isSemiSelected: false)
        insertSubview(selView, at: 0)

        selView.translatesAutoresizingMaskIntoConstraints = false
        
        //pin selectionView horizontally and make it's width equal to the height of the datePickerview. This way it stays centered while rotating the device.
        selView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        selView.widthAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        //pint it to the left and right
        selView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        selView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        selectionView = selView
        
        //set textcolor to selected state
        textLabel.textColor = datePickerView.delegate?.colorForSelelectedDayLabel
    }
    
    func deselect() {

        if let selectionView = selectionView {
            selectionView.removeFromSuperview()
        }
        
        //set textcolor to default color
        switch  isToday {
        case true:
            textLabel.textColor = datePickerView.delegate?.colorForCurrentDay
        case false:
            textLabel.textColor = dayInfo.isInMonth ? datePickerView.delegate?.colorForDayLabelInMonth : datePickerView.delegate?.colorForDayLabelOutOfMonth
        }
    }
    
    /**
     creates and shows a selection circle with a semi selected color
     
     - Parameter animated: if true, this will fade in the circle
     
     */
    private func semiSelect(animated: Bool) {
        
        if let selectionView = selectionView {
            if animated {
                insertCircleViewAnimated(selectionView: selectionView)
            }
            else{
                insertSubview(selectionView, at: 0)
            }
        }
        else {
            let selView = JBDatePickerSelectionView(dayView: self, frame: self.bounds, isSemiSelected: true)
                if animated {
                    insertCircleViewAnimated(selectionView: selView)
                }
                else{
                    insertSubview(selView, at: 0)
                }
            selectionView = selView
        }
    }
    
    /**
     removes semi selected selection circle and removes circle from superview
     
     - Parameter animated: if true, this will fade the circle out before removal
     
     */
    private func semiDeselect(animated: Bool) {
        
        switch animated {
        case true:
            removeCircleViewAnimated()
        case false:
            selectionView?.removeFromSuperview()
        }
    }
    
    ///just a helper that inserts the selection circle animated
    private func insertCircleViewAnimated(selectionView: JBDatePickerSelectionView) {
        
        selectionView.alpha = 0.0
        insertSubview(selectionView, at: 0)
        
        UIView.animate(withDuration: 0.2, animations: {
            
            selectionView.alpha = 1.0
        
        })
    }
    
    ///just a helper that removes the selection circle animated
    private func removeCircleViewAnimated() {
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.selectionView?.alpha = 0.0
            
            }, completion: {_ in
                self.selectionView?.removeFromSuperview()
        })
    }
    

}

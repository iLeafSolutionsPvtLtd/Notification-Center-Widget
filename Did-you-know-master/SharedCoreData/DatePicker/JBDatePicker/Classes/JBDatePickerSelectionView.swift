//
//  JBDatePickerSelectionView.swift
//  JBDatePicker
//
//  Created by Joost van Breukelen on 19-10-16.
//  Copyright © 2016 Joost van Breukelen. All rights reserved.
//

import UIKit

class JBDatePickerSelectionView: UIView {
    
    // MARK: - Computed properties
    
    private let padding: CGFloat = 10
    
    private var radius: CGFloat {
        
        return (min(frame.height, frame.width) - padding) / 2
    }
    
    
    private var circlePath: CGPath {
        let arcCenter = CGPoint(x: frame.width / 2, y: frame.height / 2)
        let startAngle = CGFloat(0)
        let endAngle = CGFloat.pi * 2.0 
        let clockwise = true
        let path = UIBezierPath(arcCenter: arcCenter, radius: radius,
                                startAngle: startAngle, endAngle: endAngle, clockwise: clockwise).cgPath
        
        return path

    }
    
    private var squarePath: CGPath {
        
        let pathSize = radius * 2
        let center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        let startPoint = CGPoint(x: center.x - radius, y: center.y - radius)
        let path = UIBezierPath(rect: CGRect(x: startPoint.x, y: startPoint.y, width: pathSize, height: pathSize))
        
        return path.cgPath
    }
    
    private var roundedRectPath: CGPath {
        
        let pathSize = radius * 2
        let cornerRadiusForShape = radius / 2
        let center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        let startPoint = CGPoint(x: center.x - radius, y: center.y - radius)
        let path = UIBezierPath(roundedRect: CGRect(x: startPoint.x, y: startPoint.y, width: pathSize, height: pathSize), cornerRadius: cornerRadiusForShape)
        
        return path.cgPath
    }
    
    private var fillColor: UIColor {
        
        switch isSemiSelected {
        case true:
            return (dayView.datePickerView.delegate?.colorForSemiSelectedSelectionCircle)!
        case false:
            switch dayView.isToday {
            case true:
                return (dayView.datePickerView.delegate?.colorForSelectionCircleForToday)!
            case false:
                return (dayView.datePickerView.delegate?.colorForSelectionCircleForOtherDate)!
            }
        }
    }
    
    private var selectionPath: CGPath {
        
        guard let delegate = dayView.datePickerView.delegate else { return circlePath }
        
        switch delegate.selectionShape {
        case .circle:
            return circlePath
        case .square:
            return squarePath
        case .roundedRect:
            return roundedRectPath
        }
    }
    
    // MARK: - Stored properties
    
    private unowned let dayView: JBDatePickerDayView
    var isSemiSelected: Bool

    // MARK: - Initialization
    
    init(dayView: JBDatePickerDayView, frame: CGRect, isSemiSelected: Bool) {
        self.dayView = dayView
        self.isSemiSelected = isSemiSelected
        super.init(frame: frame)
        backgroundColor = .clear
        shapeLayer().fillColor = fillColor.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    private func shapeLayer() -> CAShapeLayer {
        return layer as! CAShapeLayer
    }
    
    // MARK: - Drawing
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shapeLayer().path = selectionPath
    }
    


}

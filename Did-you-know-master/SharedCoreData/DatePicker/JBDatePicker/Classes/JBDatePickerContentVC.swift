//
//  JBDatePickerContentVC.swift
//  JBDatePicker
//
//  Created by Joost van Breukelen on 09-10-16.
//  Copyright © 2016 Joost van Breukelen. All rights reserved.
//

import UIKit

class JBDatePickerContentVC: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Properties
    unowned let datePickerView: JBDatePickerView
    let scrollView: UIScrollView
    var presentedMonthView: MonthView
    var scrollDirection: JBScrollDirection = .none
    private var monthViews = [MonthViewIdentifier : MonthView]()
    
    ///flag that helps us preventing presentation while another presentation is still going on 
    private var isPresenting = false
    
    private var currentPage = 1
    private var pageChanged: Bool {
        get {
            return currentPage == 1 ? false : true
        }
    }
    
    private var scrollViewBounds: CGRect {
        return scrollView.bounds 
    }
    
    
    // MARK: - Initialization

    init(datePickerView: JBDatePickerView, frame: CGRect, presentedDate: Date) {
        
        self.datePickerView = datePickerView
        self.scrollView = UIScrollView(frame: frame)
        
        //create the current Monthview for the current date and fill it with weekviews. 
        presentedMonthView = MonthView(datePickerView: datePickerView, date: presentedDate, isPresented: true)
        presentedMonthView.createWeekViews()
        
        super.init(nibName: nil, bundle: nil)
        
        //setup scrollView. Give it a contentsize of 3 times the width because it will hold 3 monthViews
        scrollView.contentSize = CGSize(width: frame.width * 3, height: frame.height)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.layer.masksToBounds = true
        scrollView.isPagingEnabled = true 
        scrollView.delegate = self
        
        addInitialMonthViews(for: presentedMonthView.date)
    }
    
   required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Adding of MonthViews
    
    /**
     Fills the scrollView of the contentController
     with the initial three monthViews
     
     - Parameter date: the Date object to pass
     
     */
    private func addInitialMonthViews(for date: Date) {
        
        //add the three monthViews to the scrollview
        addMonthView(presentedMonthView, withIdentifier: .presented)
        addMonthView(getPreviousMonthView(for: date), withIdentifier: .previous)
        addMonthView(getNextMonthView(for: date), withIdentifier: .next)
        
    }

    
    /**
     Adds the given monthView to the contentControllers scrollView and updates
     the given monthViews frame origin to place it in the correct position.
     
     - Parameter monthView: the MonthView to be added
     - Parameter identifier: can be .previous, .presented or .next
     
     */
    private func addMonthView(_ monthView: MonthView, withIdentifier identifier: MonthViewIdentifier) {
        
        monthView.frame.origin = CGPoint(x: scrollView.bounds.width * CGFloat(identifier.rawValue), y: 0)
        monthViews[identifier] = monthView
        scrollView.addSubview(monthView)
        
    }
    
    ///returns the previous monthView for a given date
    private func getPreviousMonthView(for date: Date) -> MonthView {
        
        let cal = Calendar.current
        var comps = cal.dateComponents([.month, .year], from: date)
        comps.month! -= 1
        let firstDateOfPreviousMonth = cal.date(from: comps)!
        let previousMonthView = MonthView(datePickerView: datePickerView, date: firstDateOfPreviousMonth, isPresented: false)
        
        //this is what gives new new monthView it's initial frame
        previousMonthView.frame = scrollView.frame
        previousMonthView.createWeekViews()
        
        return previousMonthView
    }
    
    ///returns the next monthView for a given date
    private func getNextMonthView(for date: Date) -> MonthView {
        
        let cal = Calendar.current
        var comps = cal.dateComponents([.month, .year], from: date)
        comps.month! += 1
        let firstDateOfNextMonth = cal.date(from: comps)!
        let nextMonthView = MonthView(datePickerView: datePickerView, date: firstDateOfNextMonth, isPresented: false)
        
        //this is what gives new new monthView it's initial frame
        nextMonthView.frame = scrollView.frame
        nextMonthView.createWeekViews()
        
        return nextMonthView
    }
    
    // MARK: - Reloading and replacing of MonthViews
    
    /**
     Updates the frame of the scrollView and reloads the monthViews present
     When called, scrolls to presented monthView
     
     - Parameter frame: the frame to update to
     - Note: is only called on initial load of datePicker
     
     */
    func updateScrollViewFrame(_ frame: CGRect) {
        
        if frame != .zero {
            scrollView.frame = frame
            scrollView.contentSize = CGSize(width: frame.size.width * 3, height: frame.size.height)
        }
        
        let monthViewFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        for monthView in monthViews.values {
            
            monthView.reloadSubViewsWithFrame(monthViewFrame)
        }
        
        reloadMonthViews()
        
        if let presentedMonthView = monthViews[.presented] {
            
            //scroll to presented month
            scrollView.scrollRectToVisible(presentedMonthView.frame, animated: false)
        }
    }
    
    
    /**
     For each monthView this method updates the origin, then removes the monthView from the scrollView
     and adds them again.
     */
    private func reloadMonthViews() {
        
        for (identifier, monthView) in monthViews {
            
            monthView.frame.origin.x = CGFloat(identifier.rawValue) * scrollView.frame.width
            
            //this will not deinitialize, because there's still a reference to this monthView object
            monthView.removeFromSuperview()
            scrollView.addSubview(monthView)
        }
    }
    
    /**
     Replaces the identifier of a monthView with another identifier, so it's gets another role. The presented monthView will, for example, become the next monthView. The frame origin of the monthView involved will also be adjusted and scrolled into position if needed.
     
     - Parameter monthView: the monthView involved
     - Parameter identifier: the new identifier that the monthView will get
     - Parameter shouldScrollToPosition: a boolean that determines if the monthView's frame should scroll into position or not
     
     */
    private func replaceMonthViewIdentifier(_ monthView: MonthView, with identifier: MonthViewIdentifier, shouldScrollToPosition: Bool) {
        
        //adjust frame to the frame that comes with the new identifier (the new role)
        var monthViewFrame = monthView.frame
        monthViewFrame.origin.x = monthViewFrame.width * CGFloat(identifier.rawValue)
        monthView.frame = monthViewFrame
        
        //update the monthViews dictionary
        monthViews[identifier] = monthView
        
        //scroll the new 'presented' monthView into the presented position.
        //this will also cause the currentPage to be set to 1 again by the didScroll delegate method
        if shouldScrollToPosition {
            scrollView.scrollRectToVisible(monthViewFrame, animated: false)
        }
    }
    
    
    // MARK: - Scrolling MonthViews
    
    private func scrolledToPreviousMonth() {
        
        guard let previousMonthView = monthViews[.previous], let presentedMonthView = monthViews[.presented] else { return }
        
        //remove next monthView, this will be replaced by presented monthView
        monthViews[.next]?.removeFromSuperview()
        
        //replace previous monthView identifier with 'presented' identifier and set isPresented value
        replaceMonthViewIdentifier(previousMonthView, with: .presented, shouldScrollToPosition: true)
        previousMonthView.isPresented = true
        
        //replace presented monthView identifier with 'next' identifier and set isPresented value
        replaceMonthViewIdentifier(presentedMonthView, with: .next, shouldScrollToPosition: false)
        presentedMonthView.isPresented = false
        
        //add new monthView which will become the new 'previous' monthView
        addMonthView(getPreviousMonthView(for: previousMonthView.date), withIdentifier: .previous)
        
    }
    
    
    private func scrolledToNextMonth() {
        
        guard let nextMonthView = monthViews[.next], let presentedMonthView = monthViews[.presented] else { return }
        
        //remove previous monthView, this will be replaced by presented monthView
        monthViews[.previous]?.removeFromSuperview()
        
        //replace next monthView identifier with 'presented' identifier and set isPresented value
        replaceMonthViewIdentifier(nextMonthView, with: .presented, shouldScrollToPosition: true)
        nextMonthView.isPresented = true
        
        //replace presented monthView identifier with 'previous' identifier and set isPresented value
        replaceMonthViewIdentifier(presentedMonthView, with: .previous, shouldScrollToPosition: false)
        nextMonthView.isPresented = false
        
        //add new monthView which will become the new 'next' monthView
        addMonthView(getNextMonthView(for: nextMonthView.date), withIdentifier: .next)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let page = Int(floor((scrollView.contentOffset.x -
            scrollView.frame.width / 2) / scrollView.frame.width) + 1)
        if currentPage != page {
            currentPage = page
        }
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        //decide in which direction the user did scroll
        if decelerate {
            let rightBorderOfScrollView = scrollView.frame.width
            if scrollView.contentOffset.x <= rightBorderOfScrollView {
                scrollDirection = .toPrevious
            } else {
                scrollDirection = .toNext
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if pageChanged {
            switch scrollDirection {
            case .toNext: scrolledToNextMonth()
            case .toPrevious: scrolledToPreviousMonth()
            case .none: break
            }
        }
        
        scrollDirection = .none
    }
    
    
    
    // MARK: - Presenting of monthViews
    
    func presentNextView() {
        if !isPresenting {
            
            guard let previous = monthViews[.previous], let presented = monthViews[.presented], let next = monthViews[.next] else { return }
            
            isPresenting = true
            
            UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                
                //animate positions of monthViews
                previous.frame.origin.x -= self.scrollView.frame.width
                presented.frame.origin.x -= self.scrollView.frame.width
                next.frame.origin.x -= self.scrollView.frame.width
                
            }, completion: {_ in
                
                //replace identifiers
                self.replaceMonthViewIdentifier(presented, with: .previous, shouldScrollToPosition: false)
                self.replaceMonthViewIdentifier(next, with: .presented, shouldScrollToPosition: false)
                self.presentedMonthView = next
                
                //set isPresented value
                previous.isPresented = false
                self.presentedMonthView.isPresented = true
                
                //remove previous monthView
                previous.removeFromSuperview()
                
                //create and insert new 'next' monthView
                self.addMonthView(self.getNextMonthView(for: next.date), withIdentifier: .next)
                self.isPresenting = false
                
            })
        }
    }
    
    
    func presentPreviousView() {
        if !isPresenting {
            
            guard let previous = monthViews[.previous], let presented = monthViews[.presented], let next = monthViews[.next] else { return }
            
            isPresenting = true
            
            UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                
                //animate positions of monthViews
                previous.frame.origin.x += self.scrollView.frame.width
                presented.frame.origin.x += self.scrollView.frame.width
                next.frame.origin.x += self.scrollView.frame.width
                
            }, completion: {_ in
                
                //replace identifiers
                self.replaceMonthViewIdentifier(presented, with: .next, shouldScrollToPosition: false)
                self.replaceMonthViewIdentifier(previous, with: .presented, shouldScrollToPosition: false)
                self.presentedMonthView = previous
                
                //set isPresented value
                next.isPresented = false
                self.presentedMonthView.isPresented = true
                
                //remove previous monthView
                next.removeFromSuperview()
                
                //create and insert new 'previous' monthView
                self.addMonthView(self.getPreviousMonthView(for: previous.date), withIdentifier: .previous)
                self.isPresenting = false
                
            })
        }
    }

}



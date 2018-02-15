//
//  HomeViewController.swift
//  SharedCoreData
//
//  Created by iLeaf Solutions on 18/12/17.
//  Copyright © 2017 iLeaf. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController,JBDatePickerViewDelegate{

    ///Input is month name
    @IBOutlet weak var lblCurrentMnth: UILabel!
    /// calender view
    @IBOutlet weak var datePickerView: JBDatePickerView!
    /// Input is todays did you know fact
    @IBOutlet weak var lblFactsDescription: UILabel!
    /// Contain all facts
    var arrayFacts = [SCDFactModel]()
    /// Know facts model
    var factsModel = SCDFactModel()
    /// Date formatter
    lazy var dateFormatter: DateFormatter = {
        
        var formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        datePickerView.delegate = self
        if !isAppAlreadyLaunchedOnce(){
            
            //Read json and save it to coredata
             readJson()
         }
        else
         {   //Fetch todays fact
             fetchTodaysFact()
         }
       
       
        //let arry = SCDCoreDataWrapper.sharedInstance.getUser(entity: "User")
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
     // MARK: Helper functions
    func getMonth(month:Int) -> String {
        switch month {
        case 1:
            return "Jan"
        case 2:
            return "Feb"
        case 3:
            return "Mar"
        case 4:
            return "Apr"
        case 5:
            return "May"
        case 6:
            return "Jun"
        case 7:
            return "Jul"
        case 8:
            return "Aug"
        case 9:
            return "Sep"
        case 10:
            return "Oct"
        case 11:
            return "Nov"
        default:
            return "Dec"
        }
    }
    func fetchTodaysFact()
    {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from:date)
        let month = components.month
        
        let day:Int = components.day!
        let todaysDate =  getMonth(month: month!)+" "+String(day)
        let data = SCDCoreDataWrapper.sharedInstance.fetchTodaysFact(filter: todaysDate)
        let replaced = data.fact.trimmingCharacters(in: NSCharacterSet.whitespaces)
        lblFactsDescription.text = replaced.capitalizingFirstLetter()
    }
    
    // MARK: - JBDatePickerViewDelegate implementation
    
    func didSelectDay(_ dayView: JBDatePickerDayView) {
      //Fetching todays fact from coredata
        let data = SCDCoreDataWrapper.sharedInstance.fetchTodaysFact(filter: dateFormatter.string(from: datePickerView.selectedDateView.date!))
        let replaced = data.fact.trimmingCharacters(in: NSCharacterSet.whitespaces)
        
        lblFactsDescription.text = replaced.capitalizingFirstLetter()

    }
    
    func didPresentOtherMonth(_ monthView: JBDatePickerMonthView) {
        self.lblCurrentMnth.text = datePickerView.presentedMonthView.monthDescription
        
    }
    // MARK: - JBDatePickerViewDelegate custom colors
    var colorForWeekDaysViewBackground: UIColor {
        return UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    }
    
    var colorForSelectionCircleForOtherDate: UIColor {
        return UIColor(red: 81.0/255.0, green: 92.0/255.0, blue: 229.0/255.0, alpha: 1.0)
    }
    var colorForSelectionCircleForToday: UIColor
    {
        return UIColor(red: 81.0/255.0, green: 92.0/255.0, blue: 229.0/255.0, alpha: 1.0)
    }
    var colorForWeekDaysViewText : UIColor
    {
        return UIColor(red: 81.0/255.0, green: 92.0/255.0, blue: 229.0/255.0, alpha: 1.0)
    }
    //MARK:App already launched or not
    
    /// App already launched or not
    ///
    /// - Returns: App already launched true or false
    func isAppAlreadyLaunchedOnce()->Bool{
        let defaults = UserDefaults.standard
        if let isAppAlreadyLaunchedOnce = defaults.string(forKey: "kIsAppAlreadyLaunchedOnce"){
            print("App already launched : \(isAppAlreadyLaunchedOnce)")
            return true
        }else{
            defaults.set(true, forKey: "kIsAppAlreadyLaunchedOnce")
            return false
        }
    }
     //MARK: Read json and save to coredata
    private func readJson() {
        do {
            if let file = Bundle.main.url(forResource: "DidYouKnowFacts", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    // json is a dictionary
                    print(object)
                } else if let object = json as? [Any] {
                    // json is an array
                    for data in object{
                        if let items : NSDictionary = data as? NSDictionary
                        {
                            self.factsModel.fact = items["fact"] as!String
                            self.factsModel.date = items["date"] as! String
                            arrayFacts.append(self.factsModel)
                        }
            
                    }
                    SCDCoreDataWrapper.sharedInstance.saveFacts(facts: arrayFacts, entity: "Facts")
                    fetchTodaysFact()
                    print(object)
                } else {
                    print("JSON is invalid")
                }
            } else {
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
    }


}
extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

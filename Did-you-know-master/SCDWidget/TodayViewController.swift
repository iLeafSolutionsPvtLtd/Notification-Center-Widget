//
//  TodayViewController.swift
//  SCDWidget
//
//  Created by iLeaf Solutions on 14/12/17.
//  Copyright © 2017 iLeaf. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreData

class TodayViewController: UIViewController, NCWidgetProviding {
    //Core data context
    var managedContext: NSManagedObjectContext?
    /// Input is todays fact
    @IBOutlet weak var lblFactsDescription: UILabel!
    
    //MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        fetchTodaysFact()
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
    

        completionHandler(NCUpdateResult.newData)
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
        
        // let year =  components.year
        let month = components.month
        
        let day:Int = components.day!
        let todaysDate =  getMonth(month: month!)+" "+String(day)
        let data = self.fetchTodaysFact(filter: todaysDate)
        let replaced = data.fact.trimmingCharacters(in: NSCharacterSet.whitespaces)
        lblFactsDescription.text = replaced
    }

    //MARK: Get Facts with filter from coredata
    //from DB Function
    func fetchTodaysFact(filter:String) ->SCDFactModel{
        
        var todaysFact = SCDFactModel()
        //var managedContext = context
        if #available(iOS 10.0, *) {
            managedContext =
                SCDCoreDataWrapper.sharedInstance.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            managedContext = SCDCoreDataWrapper.sharedInstance.managedObjectContext
        }
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Facts")
        do {
            //go get the results
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.predicate =  NSPredicate(format: "date == %@",filter)
            // let Results = try getContext().fetch(fetchRequest)
            // print(Results)
            let searchResults = try SCDCoreDataWrapper.sharedInstance.getContext().fetch(fetchRequest)
            //I like to check the size of the returned results!
            print ("num of results = \(String(describing: searchResults.count))")
            //You need to convert to NSManagedObject to use 'for' loops
            for transPort in searchResults {
                //get the Key Value pairs from searchResult ()
                let data = SCDFactModel()
                todaysFact =  data.factsMapping(factMapper: transPort)
                
                
            }
            
            return todaysFact
        }
        catch {
            print("Error with request: \(error)")
            return todaysFact
        }
    }

}

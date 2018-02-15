//
//  SCDUserModel.swift
//  SharedCoreData
//
//  Created by iLeaf Solutions on 15/12/17.
//  Copyright © 2017 iLeaf. All rights reserved.
//

import Foundation
import CoreData
struct SCDFactModel {
    
    //MARK:- Properties
    
    /// know fact
    var fact:String    = ""
    /// date
    var date:String    = ""
   
    
    
    
    
    //MARK:- Facts saving mapping
    
    func coreDataMapping(data:SCDFactModel, managedPerson:NSManagedObject) {
        managedPerson.setValue(data.fact, forKey: "fact")
        managedPerson.setValue(data.date, forKey: "date")
       
        
    }
    
    //MARK:- Facts retrive mapping
    func factsMapping(factMapper:AnyObject) ->SCDFactModel {
        
        var data = SCDFactModel()
        data.fact = factMapper.value(forKey: "fact") as! String
        data.date = factMapper.value(forKey: "date") as! String
     
        return data
    }
    
}

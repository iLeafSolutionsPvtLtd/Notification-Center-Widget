//
//  SCDCoreDataWrapper.swift
//  SharedCoreData
//
//  Created by iLeaf Solutions on 15/12/17.
//  Copyright © 2017 iLeaf. All rights reserved.
//

import UIKit
import CoreData

class SCDCoreDataWrapper: NSObject {
    var context: NSManagedObjectContext?
    static let sharedInstance : SCDCoreDataWrapper = {
        let instance = SCDCoreDataWrapper()
        return instance
    }()
    
    // MARK: - Core Data stack
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "SharedCoreData")
        var persistentStoreDescriptions: NSPersistentStoreDescription
        
        let storeUrl =  FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.ileaf.SharedCoreData")!.appendingPathComponent("\("SharedCoreData").sqlite")
        
        let description = NSPersistentStoreDescription()
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        description.url = storeUrl
        
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url:  FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.ileaf.SharedCoreData")!.appendingPathComponent("\("SharedCoreData").sqlite"))]

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
  
    // MARK: - Core Data Saving support
    func saveContext () {
        if #available(iOS 10.0, *) {
            context = persistentContainer.viewContext
            if (context?.hasChanges)! {
                do {
                    try context?.save()
                } catch {
                }
            }
        } else {
            // Fallback on earlier versions
            // iOS 9.0 and below - however you were previously handling it
            guard let modelURL = Bundle.main.url(forResource: "SharedCoreData", withExtension:"momd") else {
                fatalError("Error loading model from bundle")
            }
            guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
                fatalError("Error initializing mom from: \(modelURL)")
            }
            let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
            context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let docURL = urls[urls.endIndex-1]
            let storeURL = docURL.appendingPathComponent("SharedCoreData.sqlite")
            do {
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
            
        }
        
    }
    public lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    //MARK:- Get the NSManagedObjectContext
    func getContext () -> NSManagedObjectContext {
        if #available(iOS 10.0, *) {
            return SCDCoreDataWrapper.sharedInstance.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            return self.managedObjectContext
            //return NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        }
        
    }
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        do {
            return try NSPersistentStoreCoordinator.coordinator(name:"SharedCoreData")
        } catch {
            print("CoreData: Unresolved error \(error)")
        }
        return nil
    }()
    
    
    //MARK:- Save all did you know facts
    func saveFacts(facts:[SCDFactModel], entity:String )  {
        
        var managedContext = context
        if #available(iOS 10.0, *) {
            managedContext =
                SCDCoreDataWrapper.sharedInstance.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            managedContext = self.managedObjectContext
        }
        // 2
        let entity = NSEntityDescription.entity(forEntityName: entity,in: managedContext!)!
        
        
        do {
           
            for fact in facts
            {
            let person = NSManagedObject(entity: entity,insertInto: managedContext)
                
            let factMapper = fact
            factMapper.coreDataMapping(data: fact, managedPerson: person)
            }
            
            }
            do{
                try managedContext?.save()
            }catch{
                debugPrint("error")
            }
            
        }
    
    //MARK:- Get Facts with filter
    //from DB Function
    func fetchTodaysFact(filter:String) ->SCDFactModel{
        
        var todaysFact = SCDFactModel()
        var managedContext = context
        if #available(iOS 10.0, *) {
            managedContext =
                SCDCoreDataWrapper.sharedInstance.persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            managedContext = self.managedObjectContext
        }
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Facts")
        do {
            //go get the results
            fetchRequest.returnsObjectsAsFaults = false
            fetchRequest.predicate =  NSPredicate(format: "date == %@",filter)
            // let Results = try getContext().fetch(fetchRequest)
            // print(Results)
            let searchResults = try managedContext?.fetch(fetchRequest)
            
            
            //I like to check the size of the returned results!
            print ("num of results = \(String(describing: searchResults?.count))")
            //You need to convert to NSManagedObject to use 'for' loops
            for transPort in searchResults! {
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

/// NSPersistentStoreCoordinator extension
extension NSPersistentStoreCoordinator {
    
    /// NSPersistentStoreCoordinator error types
    public enum CoordinatorError: Error {
        /// .momd file not found
        case modelFileNotFound
        /// NSManagedObjectModel creation fail
        case modelCreationError
        /// Gettings document directory fail
        case storePathNotFound
    }
    
    /// Return NSPersistentStoreCoordinator object
    static func coordinator(name: String) throws -> NSPersistentStoreCoordinator? {
        
        guard let modelURL = Bundle.main.url(forResource: name, withExtension: "momd") else {
            throw CoordinatorError.modelFileNotFound
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            throw CoordinatorError.modelCreationError
        }
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            throw CoordinatorError.storePathNotFound
        }
        do {
            let url = documents.appendingPathComponent("\(name).sqlite")
            let options = [ NSMigratePersistentStoresAutomaticallyOption : true,
                            NSInferMappingModelAutomaticallyOption : true ]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            throw error
        }
        
        return coordinator
    }
}


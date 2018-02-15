//
//  Facts+CoreDataProperties.swift
//  SharedCoreData
//
//  Created by iLeaf Solutions on 18/12/17.
//  Copyright © 2017 iLeaf. All rights reserved.
//

import Foundation
import CoreData


extension Facts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Facts> {
        return NSFetchRequest<Facts>(entityName: "Facts")
    }

    @NSManaged public var date: String?
    @NSManaged public var fact: String?

}

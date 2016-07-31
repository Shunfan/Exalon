//
//  Item+CoreDataProperties.swift
//  Exalon
//
//  Created by Kwak on 7/30/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Item {

    @NSManaged var name: String?
    @NSManaged var amount: NSNumber?
    @NSManaged var date: NSDate?
    @NSManaged var category: NSManagedObject?

}

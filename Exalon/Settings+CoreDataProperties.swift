//
//  Settings+CoreDataProperties.swift
//  Exalon
//
//  Created by Shunfan Du on 8/15/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Settings {

    @NSManaged var currency: String?
    @NSManaged var touchID: NSNumber?

}

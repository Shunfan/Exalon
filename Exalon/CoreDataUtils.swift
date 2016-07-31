//
//  CoreDataUtils.swift
//  Exalon
//
//  Created by Kwak on 7/30/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import UIKit
import CoreData

var _managedObjectContext : NSManagedObjectContext?

class CoreDataUtils: NSObject {
    static func managedObjectContext() -> NSManagedObjectContext {
        if (_managedObjectContext == nil) {
            let aD : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            _managedObjectContext = aD.managedObjectContext
        }
        return _managedObjectContext!;
    }
    
    
    static func saveContext() {
        do {
            let context = CoreDataUtils.managedObjectContext()
            try context.save()
        } catch {
            print("Unresolved error \(error)")
            abort()
        }
        
    }
    
}

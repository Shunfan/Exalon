//
//  Utils.swift
//  Exalon
//
//  Created by Shunfan Du on 8/16/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import CoreData

class Utils: NSObject {
    var currency: String?
    var settings: Settings?
    
    // Get the current currency string, for example, "$"
    static func getCurrency() -> String {
        let fetchRequest = NSFetchRequest(entityName: "Settings")
        
        do {
            let settingsList = try CoreDataUtils.managedObjectContext().executeFetchRequest(fetchRequest)
            
            if settingsList.count > 0 {
                let settings = settingsList[0] as! Settings
                return settings.currency!
            }
        } catch {
            // To be implemented
        }
        
        return ""
    }
    
    // Get all items in a particular year and month
    static func getItemsIn(year: Int, month: Int) -> [Item] {
        var fetchedItems: [Item]!
        
        let fetchRequest = NSFetchRequest(entityName: "Item")
        
        let startPredicate = NSPredicate(format: "date >= %@", self.startOfMonth(year, month: month))
        let endPredicate = NSPredicate(format: "date <= %@", self.endOfMonth(year, month: month))
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [startPredicate, endPredicate])
        
        do {
            fetchedItems = try CoreDataUtils.managedObjectContext().executeFetchRequest(fetchRequest) as! [Item]
        } catch {
            // To be implemented
        }
        
        return fetchedItems
    }
    
    static func startOfMonth(year: Int, month: Int) -> NSDate {
        let dateComponents = NSDateComponents()
        dateComponents.year = year
        dateComponents.month = month
        
        let calendar = NSCalendar.currentCalendar()
        let startDate = calendar.dateFromComponents(dateComponents)!
        
        return startDate
    }
    
    static func endOfMonth(year: Int, month: Int) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let nextMonthDate = calendar.dateByAddingUnit(.Month, value: 1, toDate: startOfMonth(year, month: month), options: [])!
        let endDate = nextMonthDate.dateByAddingTimeInterval(-1)
        
        return endDate
    }
}

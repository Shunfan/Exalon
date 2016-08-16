//
//  CurrencyUtils.swift
//  Exalon
//
//  Created by Shunfan Du on 8/16/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import CoreData

class CurrencyUtils: NSObject {
    var currency: String?
    var settings: Settings?
    
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
}

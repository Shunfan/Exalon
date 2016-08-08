//
//  AddItemTableViewController.swift
//  Exalon
//
//  Created by Shunfan Du on 7/26/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import UIKit
import CoreData
import ActionSheetPicker_3_0

class AddItemTableViewController: UITableViewController {
    
    @IBOutlet weak var itemTypeLabel: UILabel!
    @IBOutlet weak var itemCategoryLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemAmountLabel: UILabel!
    @IBOutlet weak var itemDateLabel: UILabel!
    
    var isDeposit : Bool = true
    var targetCategory: Category!
    var targetDate: NSDate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        let dateString = formatter.stringFromDate(NSDate())
        self.itemDateLabel.text = dateString
    }
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        let item = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext: CoreDataUtils.managedObjectContext()) as! Item
        item.category = self.targetCategory
        item.name = self.itemNameLabel.text
        item.amount = convertStringToDouble(self.itemAmountLabel.text!)
        item.date = self.targetDate
        
        CoreDataUtils.saveContext()
        navigationController?.popViewControllerAnimated(true)
    }
    
    func convertStringToDouble(text: String) -> Double {
        if Double(text) != nil {
            return Double(text)!
        }
        
        return 0.0
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row) {
        case 0:
            self.isDeposit = !self.isDeposit
            if self.isDeposit {
                self.itemTypeLabel.text = "Deposit"
            } else {
                self.itemTypeLabel.text = "Withdraw"
            }
        case 1:
            // Get categories that matches the type selected
            var categories  = [Category]()
            let fetchRequest = NSFetchRequest(entityName: "Category")
            do {
                try categories = CoreDataUtils.managedObjectContext().executeFetchRequest(fetchRequest) as! [Category]
            } catch {
                // To be implement
            }
            
            var categoryFilteredList = [Category]()
            
            for category in categories {
                if self.isDeposit && (category.isDeposit?.boolValue)! {
                    categoryFilteredList.append(category)
                }
                
                if !self.isDeposit && !(category.isDeposit?.boolValue)! {
                    categoryFilteredList.append(category)
                }
            }
            
            var categoryNameList = [String]()
            
            for category in categoryFilteredList {
                categoryNameList.append(category.name!)
            }
            
            ActionSheetMultipleStringPicker.showPickerWithTitle(
                "Category",
                rows: [categoryNameList],
                initialSelection: [0],
                doneBlock: { picker, indexes, values in
                    // Save the category so that the item can be saved into that category later
                    self.targetCategory = categoryFilteredList[indexes[0] as! Int]
                    self.itemCategoryLabel.text = categoryNameList[indexes[0] as! Int]
                    return
                },
                cancelBlock: { ActionMultipleStringCancelBlock in return },
                origin: tableView)
        case 2:
            let ac = UIAlertController(title: "Item Name", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            
            // Add Text Field
            ac.addTextFieldWithConfigurationHandler { (textField) in
                if self.itemNameLabel.text == "Not Set" {
                    textField.text = ""
                } else {
                    textField.text = self.itemNameLabel.text
                }            }
            
            // Add a cancel
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)
            ac.addAction(cancelAction)
            
            // Add an OK button
            let createList = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) in
                let textField = ac.textFields?.first
                
                self.itemNameLabel.text = textField?.text
            }
            
            ac.addAction(createList)
            self.presentViewController(ac, animated: true, completion: nil)
        case 3:
            let ac = UIAlertController(title: "Item Amount", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            
            // Add Text Field
            ac.addTextFieldWithConfigurationHandler { (textField) in
                textField.keyboardType = .DecimalPad
                textField.text = self.itemAmountLabel.text
            }
            
            // Add a cancel
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)
            ac.addAction(cancelAction)
            
            // Add an OK button
            let createList = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) in
                let textField = ac.textFields?.first
                
                self.itemAmountLabel.text = textField?.text
            }
            
            ac.addAction(createList)
            self.presentViewController(ac, animated: true, completion: nil)
        case 4:
            ActionSheetDatePicker.showPickerWithTitle(
                "Date",
                datePickerMode: .Date,
                selectedDate: NSDate(),
                doneBlock: { (picker, values, indexes) -> Void in
                    self.targetDate = values as! NSDate
                    
                    let formatter = NSDateFormatter()
                    formatter.dateStyle = NSDateFormatterStyle.LongStyle
                    let dateString = formatter.stringFromDate(values as! NSDate)
                    self.itemDateLabel.text = dateString
                    return
                },
                cancelBlock: { (ActionMultipleStringCancelBlock) -> Void in return },
                origin: self.tableView)
        default:
            print("error")
        }
    }

}

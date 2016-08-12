//
//  ItemTableViewController.swift
//  Exalon
//
//  Created by Shunfan Du on 7/26/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import UIKit
import CoreData
import ActionSheetPicker_3_0

class ItemTableViewController: UITableViewController {
    
    @IBOutlet weak var itemTypeLabel: UILabel!
    @IBOutlet weak var itemCategoryLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemAmountLabel: UILabel!
    @IBOutlet weak var itemDateLabel: UILabel!
    
    var itemToEdit: Item?
    var isDeposit : Bool = true
    var itemCategory: Category!
    var itemDate: NSDate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        
        if itemToEdit != nil {
            self.navigationItem.title = "Edit an Item"
            
            self.itemCategory = self.itemToEdit!.category as! Category
            self.isDeposit = self.itemCategory.isDeposit!.boolValue
            self.itemDate = self.itemToEdit!.date
            
            self.itemTypeLabel.text = self.isDeposit ? "Deposit" : "Withdraw"
            self.itemCategoryLabel.text = self.itemCategory.name
            self.itemNameLabel.text = self.itemToEdit!.name
            self.itemAmountLabel.text = String(self.itemToEdit!.amount!)
            self.itemDateLabel.text = formatter.stringFromDate(self.itemToEdit!.date!)
        } else {
            // Set date to today by default
            self.itemDate = NSDate()
            let dateString = formatter.stringFromDate(self.itemDate)
            self.itemDateLabel.text = dateString
        }
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        if self.itemCategory == nil || self.itemNameLabel.text == "Not Set" || self.itemAmountLabel.text == "Not Set" {
            let alertController = UIAlertController(title: "Basic Info Required", message: "Category, name and amount are required fields.", preferredStyle: .Alert)
            let OKAlertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(OKAlertAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            if self.itemToEdit != nil {
                self.itemToEdit!.category = self.itemCategory
                self.itemToEdit!.name = self.itemNameLabel.text
                self.itemToEdit!.amount = convertStringToDouble(self.itemAmountLabel.text!)
                self.itemToEdit!.date = self.itemDate
            } else {
                let item = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext: CoreDataUtils.managedObjectContext()) as! Item
                item.category = self.itemCategory
                item.name = self.itemNameLabel.text
                item.amount = convertStringToDouble(self.itemAmountLabel.text!)
                item.date = self.itemDate
            }
            
            CoreDataUtils.saveContext()
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
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
            
            if categoryFilteredList.count != 0 {
                ActionSheetMultipleStringPicker.showPickerWithTitle(
                    "Category",
                    rows: [categoryNameList],
                    initialSelection: [0],
                    doneBlock: { picker, indexes, values in
                        // Save the category so that the item can be saved into that category later
                        self.itemCategory = categoryFilteredList[indexes[0] as! Int]
                        self.itemCategoryLabel.text = categoryNameList[indexes[0] as! Int]
                        return
                    },
                    cancelBlock: { ActionMultipleStringCancelBlock in return },
                    origin: tableView)
            }
        case 2:
            let ac = UIAlertController(title: "Item Name", message: "", preferredStyle: UIAlertControllerStyle.Alert)

            ac.addTextFieldWithConfigurationHandler { (textField) in
                textField.text = self.itemNameLabel.text == "Not Set" ? "" : self.itemNameLabel.text
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)

            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) in
                let textField = ac.textFields!.first!
                self.itemNameLabel.text = textField.text
            }
            
            ac.addAction(cancelAction)
            ac.addAction(okAction)
            self.presentViewController(ac, animated: true, completion: nil)
        case 3:
            let ac = UIAlertController(title: "Item Amount", message: "", preferredStyle: UIAlertControllerStyle.Alert)

            ac.addTextFieldWithConfigurationHandler { (textField) in
                textField.keyboardType = .DecimalPad
                textField.text = self.itemAmountLabel.text == "Not Set" ? "" : self.itemAmountLabel.text
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)

            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) in
                let textField = ac.textFields!.first!
                self.itemAmountLabel.text = String(self.convertStringToDouble(textField.text!))
            }
            
            ac.addAction(cancelAction)
            ac.addAction(okAction)
            self.presentViewController(ac, animated: true, completion: nil)
        case 4:
            ActionSheetDatePicker.showPickerWithTitle(
                "Date",
                datePickerMode: .Date,
                selectedDate: NSDate(),
                doneBlock: { (picker, values, indexes) -> Void in
                    self.itemDate = values as! NSDate
                    
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

//
//  AddCategoryTableViewController.swift
//  Exalon
//
//  Created by Shunfan Du on 7/27/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import UIKit
import CoreData
import ActionSheetPicker_3_0

class AddCategoryTableViewController: UITableViewController {
    @IBOutlet weak var categoryTypeLabel: UILabel!
    @IBOutlet weak var categoryColorLabel: UILabel!
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    var isDeposit : Bool = true
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row) {
        case 0:
            let ac = UIAlertController(title: "Category Name", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            
            // Add Text Field
            ac.addTextFieldWithConfigurationHandler { (textField) in
//                textField.placeholder = "Name for this Category"
                if self.categoryNameLabel.text == "Name for Category" {
                    textField.text = ""
                } else {
                    textField.text = self.categoryNameLabel.text
                }

            }
            
            // Add a cancel
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)
            ac.addAction(cancelAction)
            
            // Add an OK button
            let createList = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) in
                let textField = ac.textFields?.first
                
                self.categoryNameLabel.text = textField?.text
            }
            
            ac.addAction(createList)
            self.presentViewController(ac, animated: true, completion: nil)

        case 1:
            self.isDeposit = !self.isDeposit
            if self.isDeposit {
                self.categoryTypeLabel.text = "Deposit"
            } else {
                self.categoryTypeLabel.text = "Withdraw"
            }
        case 2:
            ActionSheetMultipleStringPicker.showPickerWithTitle("Color", rows: [
                ["Red", "Blue", "White", "Green", "Black", "Custom"]
                ], initialSelection: [0], doneBlock: {
                    picker, values, indexes in
                    
                    switch (values[0] as! Int){
                    case 0:
                        self.categoryColorLabel.text = "Red"
                    case 1:
                        self.categoryColorLabel.text = "Blue"
                    case 2:
                        self.categoryColorLabel.text = "White"
                    case 3:
                        self.categoryColorLabel.text = "Green"
                    case 4:
                        self.categoryColorLabel.text = "Black"
                    case 5:
                        self.categoryColorLabel.text = "Custom"
                    default:
                        return
                    }
                    
                    
                    return
                }, cancelBlock: { ActionMultipleStringCancelBlock in return }, origin: tableView)
        default:
            print("error")
        }
    }
    

    @IBAction func addCategoryButtonPressed(sender: AnyObject) {
        let category = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: CoreDataUtils.managedObjectContext()) as! Category
        category.name = self.categoryNameLabel.text
        category.isDeposit = self.isDeposit
        category.color = self.categoryColorLabel.text
        
        CoreDataUtils.saveContext()
        navigationController?.popViewControllerAnimated(true)
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */


    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

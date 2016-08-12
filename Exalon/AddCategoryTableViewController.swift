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
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var categoryColorView: UIView!
    @IBOutlet weak var colorRedSlider: UISlider!
    @IBOutlet weak var colorGreenSlider: UISlider!
    @IBOutlet weak var colorBlueSlider: UISlider!
    @IBOutlet weak var colorAlphaSlider: UISlider!
    
    var isDeposit : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateCategoryColorView()
    }
    
    @IBAction func sliderChanged(sender: AnyObject) {
        self.updateCategoryColorView()
    }
    
    func updateCategoryColorView() {
        self.categoryColorView.backgroundColor = UIColor(
            red: CGFloat(self.colorRedSlider.value),
            green: CGFloat(self.colorGreenSlider.value),
            blue: CGFloat(self.colorBlueSlider.value),
            alpha: CGFloat(self.colorAlphaSlider.value)
        )
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row) {
        case 0:
            let ac = UIAlertController(title: "Category Name", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            
            // Add Text Field
            ac.addTextFieldWithConfigurationHandler { (textField) in
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
        default:
            print("NA")
        }
    }
    

    @IBAction func addCategoryButtonPressed(sender: AnyObject) {
        let category = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: CoreDataUtils.managedObjectContext()) as! Category
        category.name = self.categoryNameLabel.text
        category.isDeposit = self.isDeposit
        category.color = "\(self.colorRedSlider.value) \(self.colorGreenSlider.value) \(self.colorBlueSlider.value) \(self.colorAlphaSlider.value)"
        
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

//
//  AddItemTableViewController.swift
//  Exalon
//
//  Created by Shunfan Du on 7/26/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class AddItemTableViewController: UITableViewController {
    @IBOutlet weak var itemTypeLabel: UILabel!
    @IBOutlet weak var itemDateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        let dateString = formatter.stringFromDate(NSDate())
        self.itemDateLabel.text = dateString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row) {
        case 0:
            ActionSheetMultipleStringPicker.showPickerWithTitle("Type", rows: [
                ["Withdraw", "Deposit"]
                ], initialSelection: self.itemTypeLabel.text == "Withdraw" ? [0] : [1], doneBlock: {
                    picker, values, indexes in
                    if values[0] as! NSObject == 0 {
                        self.itemTypeLabel.text = "Withdraw"
                    } else {
                        self.itemTypeLabel.text = "Deposit"
                    }
                    return
                }, cancelBlock: { ActionMultipleStringCancelBlock in return }, origin: tableView)
        case 3:
            ActionSheetDatePicker.showPickerWithTitle("Date", datePickerMode: .Date, selectedDate: NSDate(), doneBlock: {
                (picker, values, indexes) -> Void in
                let formatter = NSDateFormatter()
                formatter.dateStyle = NSDateFormatterStyle.LongStyle
                let dateString = formatter.stringFromDate(values as! NSDate)
                self.itemDateLabel.text = dateString
                return
                }, cancelBlock: { (ActionMultipleStringCancelBlock) -> Void in
                    return
                }, origin: tableView)
        default:
            print("error")
        }
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

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

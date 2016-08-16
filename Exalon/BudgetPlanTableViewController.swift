//
//  BudgetPlanTableViewController.swift
//  Exalon
//
//  Created by Shunfan Du on 7/27/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import UIKit
import CoreData
import Charts

class BudgetPlanTableViewController: UITableViewController {
    @IBOutlet weak var budgetPieChartView: PieChartView!
    
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var daysLeftLabel: UILabel!
    @IBOutlet weak var dailyBudgetLabel: UILabel!
    
    
    
    let categories = ["Spent", "Left"]
    
    var budgetPlan: Budget?
    var isBudget: Bool = false
    var isOverBudget: Bool = false
    var goal: Double?
    var current: Double?
    var amountOver: Double?
    var daysLeft: Int?
    var dailyBudget: Double?

    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let fetchRequest = NSFetchRequest(entityName: "Budget")
        fetchRequest.fetchBatchSize = 1
        do {
            var arr = try CoreDataUtils.managedObjectContext().executeFetchRequest(fetchRequest)
            if arr.count > 0 {
                budgetPlan = (arr[0] as! Budget)
            }
        } catch {
        }

        
        if self.budgetPlan == nil {
            budgetPlan = (NSEntityDescription.insertNewObjectForEntityForName("Budget", inManagedObjectContext: CoreDataUtils.managedObjectContext()) as! Budget)
        }
        
        updateUI()
    }
    func updateUI() {
        self.current = self.appDelegate.getCurrentTotal()
        self.currentLabel.text = String(self.current!)
        
//        self.daysLeft = Utils.getDaysLeft()
        self.daysLeft = self.appDelegate.getDaysLeft()
        self.daysLeftLabel.text = String(self.daysLeft!)
        
        if self.goal>self.current {
            self.isOverBudget = false
        }
        
        if (budgetPlan!.goal != nil) {
            self.isBudget = true
            self.goal = Double((budgetPlan!.goal)!)
            self.goalLabel.text = "$" + String(self.goal!)
        } else {
            self.isBudget = false
        }
        
        
        
        if isBudget {
            if self.current > self.goal {
                self.isOverBudget = true
                self.amountOver = self.current!-self.goal!
                self.dailyBudgetLabel.text = "Stop Spending You Peasant!!!"
                let data = [self.goal!, 0]
                setPieChart(categories, values: data)
            } else {
                self.isOverBudget = false
                self.dailyBudget = Double((self.goal!-self.current!)/Double(self.daysLeft!))
                self.dailyBudgetLabel.text = "$" + String(round(100*self.dailyBudget!)/100)
                let data = [self.current!, self.goal!-self.current!]
                setPieChart(categories, values: data)
            }
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch (indexPath.row) {
        case 0:
            return CGFloat(250)
        case 5:
            return CGFloat(250)
        default:
            return CGFloat(44)
        }
    }

//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("", forIndexPath: indexPath)
//
//
//        return cell
//    }
    
    func setPieChart(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let spent = UIColor(red: CGFloat(255/255), green: CGFloat(0/255), blue: CGFloat(0/255), alpha: 1)
        let remaining = UIColor(red: CGFloat(0/255), green: CGFloat(255/255), blue: CGFloat(0/255), alpha: 1)
        let colors: [UIColor] = [spent,remaining]
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Budget")
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        pieChartDataSet.colors = colors
        budgetPieChartView.data = pieChartData
        
        if self.isOverBudget {
            // Sets the center of the pieChart Text
            budgetPieChartView.centerText = "Over Budget!"
            // Removes discriptive text from individual slices
            budgetPieChartView.drawSliceTextEnabled = false
            // Removes the center cut out of the graph
            budgetPieChartView.drawHoleEnabled = true

        } else {
        
        
        // Sets the center of the pieChart Text
        budgetPieChartView.centerText = ""
        // Removes discriptive text from individual slices
        budgetPieChartView.drawSliceTextEnabled = false
        // Removes the center cut out of the graph
        budgetPieChartView.drawHoleEnabled = false
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row) {
        case 1:
            let ac = UIAlertController(title: "Budget Plan Goal", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            
            // Add Text Field
            ac.addTextFieldWithConfigurationHandler { (textField) in
                textField.keyboardType = .DecimalPad
                textField.text = self.goalLabel.text == "Not Set" ? "" : self.goalLabel.text
            }
            
            // Add a cancel
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)
            ac.addAction(cancelAction)
            
            // Add an OK button
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) in
                let textField = ac.textFields!.first!
                self.goalLabel.text = "$" + String(self.convertStringToDouble(textField.text!))
                self.budgetPlan!.goal = self.convertStringToDouble(textField.text!)
                self.isBudget = true
                CoreDataUtils.saveContext()
                self.updateUI()
            }
            
            ac.addAction(okAction)
            self.presentViewController(ac, animated: true, completion: nil)
        default:
            print("NA")
        }
    }
    
    func convertStringToDouble(text: String) -> Double {
        if Double(text) != nil {
            return Double(text)!
        }
        
        return 0.0
    }



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

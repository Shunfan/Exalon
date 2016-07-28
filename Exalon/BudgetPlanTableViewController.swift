//
//  BudgetPlanTableViewController.swift
//  Exalon
//
//  Created by Shunfan Du on 7/27/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import UIKit
import Charts

class BudgetPlanTableViewController: UITableViewController {
    @IBOutlet weak var budgetPieChartView: PieChartView!
    
    let categories = ["Spent", "Left"]
    let data = [60.00, 40.00]

    override func viewDidLoad() {
        super.viewDidLoad()
        setPieChart(categories, values: data)
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
        
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Budget")
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        budgetPieChartView.data = pieChartData
        
        // Sets the center of the pieChart Text
        //        pieChartView.centerText = "Test"
        // Removes discriptive text from individual slices
        budgetPieChartView.drawSliceTextEnabled = false
        // Removes the center cut out of the graph
        budgetPieChartView.drawHoleEnabled = false
        
        
        var colors: [UIColor] = []
        
        for _ in 0..<dataPoints.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        
        pieChartDataSet.colors = colors
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

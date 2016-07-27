//
//  OverviewViewController.swift
//  Exalon
//
//  Created by Shunfan Du on 7/10/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import UIKit
import Charts

class OverviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let overviewCellIdentifier = "OverviewCell"
    
    // Example data for demo use
    let categories = ["Entertainment", "Gorceries", "Books"]
    let totalSpent = [59.99, 20.00, 100.00]
    
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var transactionTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPieChart(categories, values: totalSpent)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(overviewCellIdentifier, forIndexPath: indexPath)

        cell.textLabel?.text = categories[indexPath.row]
        cell.detailTextLabel?.text = "$\(totalSpent[indexPath.row])"

        return cell
    }

    func setPieChart(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Total Spent")
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        
        // Sets the center of the pieChart Text
//        pieChartView.centerText = "Test"
        // Removes discriptive text from individual slices
        pieChartView.drawSliceTextEnabled = false
        // Removes the center cut out of the graph
        pieChartView.drawHoleEnabled = false
        
        
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

}
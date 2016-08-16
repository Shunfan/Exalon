//
//  OverviewViewController.swift
//  Exalon
//
//  Created by Shunfan Du on 7/10/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import UIKit
import Charts
import CoreData

class OverviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let overviewCellIdentifier = "OverviewCell"
    let editItemSegueIdentifier = "EditItem"
    
    var currentYear: Int!
    var currentMonth: Int!
    var currentDay: Int!
    var daysLeft: Int!
    
    var categoryData = [Category: Double]()
    var currentMonthTotal: Double = 0
    var itemList: [Item]!
    var categoryList: [Category]!
    
    @IBOutlet weak var currentMonthYearLabel: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var transactionTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up currentMonthYearLabel
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate: NSDate())
        self.currentYear = components.year
        self.currentMonth = components.month
        self.currentDay = components.day
        self.calculateDaysRemaining()
//        Utils.setDaysLeft(self.daysLeft)
        self.appDelegate.setDaysLeft(self.daysLeft)
        self.reloadCurrentMonthLabel()

        self.itemList = Utils.getItemsIn(self.currentYear, month: self.currentMonth)
    }
    
    func calculateDaysRemaining() {
        if self.currentMonth == 4 || self.currentMonth == 6 || self.currentMonth == 9 || self.currentMonth == 11 {
            self.daysLeft = 30 - self.currentDay
        }else if self.currentMonth == 1 || self.currentMonth == 3 || self.currentMonth == 5 || self.currentMonth == 7 || self.currentMonth == 8 || self.currentMonth == 10 || self.currentMonth == 12 {
            self.daysLeft = 31 - self.currentDay
        } else {
            if self.currentYear % 4 == 0 {
                self.daysLeft = 29 - self.currentDay
            } else {
                self.daysLeft = 28 - self.currentDay
            }
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.itemList = Utils.getItemsIn(self.currentYear, month: self.currentMonth)
        
        self.transactionTableView.reloadData()
        self.loadPieChart()
    }
    
    @IBAction func previousMonthPressed(sender: UIButton) {
        if self.currentMonth == 1 {
            self.currentMonth = 12
            self.currentYear = self.currentYear - 1
        } else {
            self.currentMonth = self.currentMonth - 1
        }
        
        self.reloadCurrentMonthLabel()
        
        self.itemList = Utils.getItemsIn(self.currentYear, month: self.currentMonth)
        
        self.loadPieChart()
        self.transactionTableView.reloadData()
    }
    
    @IBAction func nextMonthPressed(sender: UIButton) {
        if self.currentMonth == 12 {
            self.currentMonth = 1
            self.currentYear = self.currentYear + 1
        } else {
            self.currentMonth = self.currentMonth + 1
        }
        
        self.reloadCurrentMonthLabel()
        
        self.itemList = Utils.getItemsIn(self.currentYear, month: self.currentMonth)
        
        self.loadPieChart()
        self.transactionTableView.reloadData()
    }
    
    func reloadCurrentMonthLabel() {
        let dateFormatter = NSDateFormatter()
        self.currentMonthYearLabel.text = "\(dateFormatter.monthSymbols[self.currentMonth - 1]) \(self.currentYear)"
    }
    
    func loadPieChart() {
        self.categoryData.removeAll()
        self.currentMonthTotal = 0
        
        for item in self.itemList {
            let itemCategory = item.category as! Category
            let itemAmount = item.amount as! Double

            self.currentMonthTotal = self.currentMonthTotal + itemAmount
            if !itemCategory.isDeposit!.boolValue {
                if self.categoryData[itemCategory] != nil {
                    self.categoryData[itemCategory] = self.categoryData[itemCategory]! + itemAmount
                } else {
                    self.categoryData[itemCategory] = itemAmount
                }
            }
            
            self.appDelegate.setCurrentTotal(self.currentMonthTotal)
        }

        self.setPieChart(Array(self.categoryData.keys), values: Array(self.categoryData.values))
    }
    
    func setPieChart(categories: [Category], values: [Double]) {
        self.pieChartView.clear()
        
        self.pieChartView.noDataText = "No withdraw items in this month"
        self.pieChartView.infoFont = UIFont.systemFontOfSize(CGFloat(20.0))
        self.pieChartView.infoTextColor = UIColor.blackColor()
        
        
        self.pieChartView.descriptionText = ""
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<categories.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        var colors: [UIColor] = []
        
        colors = categories.map({ (category) -> UIColor in
            return Utils.getColor(category.color!)
        })
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        let pieChartData = PieChartData(xVals: categories.map({ (category) -> String in
            return category.name!
        }), dataSet: pieChartDataSet)
        pieChartDataSet.colors = colors
        self.pieChartView.data = pieChartData
        
        print("\n")
        print("\(dataEntries)")
        print("\(pieChartDataSet)")
        print("\(pieChartData)")
        print("\(colors)")
        
        // Sets the center of the pieChart Text
        //        pieChartView.centerText = "Test"
        // Removes discriptive text from individual slices
        self.pieChartView.drawSliceTextEnabled = false
        // Removes the center cut out of the graph
        self.pieChartView.drawHoleEnabled = false
    }
    
    // MARK - UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(overviewCellIdentifier, forIndexPath: indexPath) as! TransactionTableViewCell
        
        cell.itemNameLabel.text = self.itemList[indexPath.row].name
//        cell.textLabel?.text = self.itemList[indexPath.row].name
        
        let itemCategory = self.itemList[indexPath.row].category as! Category
        cell.itemCategoryNameLabel.text = itemCategory.name
        cell.itemCategoryNameLabel.textColor = Utils.getColor(itemCategory.color!)

        cell.itemAmountLabel.text = itemCategory.isDeposit!.boolValue ? "+ \(Utils.getCurrency())\(self.itemList[indexPath.row].amount!)" : "- \(Utils.getCurrency())\(self.itemList[indexPath.row].amount!)"
//        cell.detailTextLabel?.text = itemCategory.isDeposit!.boolValue ? "+ \(Utils.getCurrency())\(self.itemList[indexPath.row].amount!)" : "- \(Utils.getCurrency())\(self.itemList[indexPath.row].amount!)"
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.editItemSegueIdentifier {
            if let indexPath = self.transactionTableView.indexPathForSelectedRow {
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! ItemTableViewController
                controller.itemToEdit = self.itemList[indexPath.row]
            }
        }
    }
    
}

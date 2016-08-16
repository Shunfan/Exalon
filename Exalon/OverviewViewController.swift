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

class OverviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    let overviewCellIdentifier = "OverviewCell"
    let editItemSegueIdentifier = "EditItem"
    
    var currentYear: Int!
    var currentMonth: Int!
    
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
        let components = calendar.components([.Year, .Month], fromDate: NSDate())
        self.currentYear = components.year
        self.currentMonth = components.month
        self.reloadCurrentMonthLabel()

        
        self.itemList = Utils.getItemsIn(self.currentYear, month: self.currentMonth)
        print(Utils.getItemsIn(2016, month: 9))
        
        self.loadPieChart()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
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
        
        setPieChart(Array(self.categoryData.keys), values: Array(self.categoryData.values))
    }
    
    func setPieChart(categories: [Category], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<categories.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        var colors: [UIColor] = []
        
        colors = categories.map({ (category) -> UIColor in
            let rgbaValues = category.color!.characters.split{$0 == " "}.map(String.init)
            return UIColor(red: CGFloat(Double(rgbaValues[0])!),
                           green: CGFloat(Double(rgbaValues[1])!),
                           blue: CGFloat(Double(rgbaValues[2])!),
                           alpha: CGFloat(Double(rgbaValues[3])!))
        })
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Total Spent")
        let pieChartData = PieChartData(xVals: categories.map({ (category) -> String in
            return category.name!
        }), dataSet: pieChartDataSet)
        pieChartDataSet.colors = colors
        self.pieChartView.data = pieChartData
        
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
        let cell = tableView.dequeueReusableCellWithIdentifier(overviewCellIdentifier, forIndexPath: indexPath)
        
        cell.textLabel?.text = self.itemList[indexPath.row].name
        
        let itemCategory = self.itemList[indexPath.row].category as! Category
        cell.detailTextLabel?.text = itemCategory.isDeposit!.boolValue ? "+ \(Utils.getCurrency())\(self.itemList[indexPath.row].amount!)" : "- \(Utils.getCurrency())\(self.itemList[indexPath.row].amount!)"
        
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
    
    
    // MARK - NSFetchedResultsControllerDelegate
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest(entityName: "Item")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.fetchBatchSize = 20
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataUtils.managedObjectContext(), sectionNameKeyPath: nil, cacheName: "ItemCache")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            print("Error in fetchedResultsController")
            abort()
        }
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.transactionTableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            self.transactionTableView.reloadData()
            self.loadPieChart()
        default:
            self.transactionTableView.reloadData()
            self.loadPieChart()
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.transactionTableView.endUpdates()
    }
    
}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}

extension NSDate: Comparable { }

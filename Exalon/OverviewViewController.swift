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
    
    // Example data for demo use
    var categoryNameList = [String]()
    var categoryAmountList = [Double]()
    
    var itemList: [Item]!
    var categoryList: [Category]!
    
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var transactionTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.itemList = self.fetchedResultsController.fetchedObjects as! [Item]
        
        self.loadPieChart()
    }
    
    func loadPieChart() {
        categoryNameList.removeAll()
        categoryAmountList.removeAll()
        
        let fetchRequest = NSFetchRequest(entityName: "Category")
        do {
            try self.categoryList = CoreDataUtils.managedObjectContext().executeFetchRequest(fetchRequest) as! [Category]
        } catch {
            // To be implement
        }
        
        for category in self.categoryList {
            if !category.isDeposit!.boolValue {
                self.categoryNameList.append(category.name!)
                
                let itemsInTheCategory = category.items?.allObjects as! [Item]
                var amountCounter = 0.0
                
                for item in itemsInTheCategory {
                    amountCounter += item.amount as! Double
                }
                self.categoryAmountList.append(amountCounter)
            }
        }
        
        print(self.categoryNameList)
        print(self.categoryAmountList)
        
        setPieChart(self.categoryNameList, values: self.categoryAmountList)
    }

    func setPieChart(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        print("1: \(self.categoryNameList)")
        
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Total Spent")
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        self.pieChartView.data = pieChartData
        
        // Sets the center of the pieChart Text
//        pieChartView.centerText = "Test"
        // Removes discriptive text from individual slices
        self.pieChartView.drawSliceTextEnabled = false
        // Removes the center cut out of the graph
        self.pieChartView.drawHoleEnabled = false
        
        
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
    
    // MARK - UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(overviewCellIdentifier, forIndexPath: indexPath)
        
        cell.textLabel?.text = self.itemList[indexPath.row].name
        cell.detailTextLabel?.text = "$\(self.itemList[indexPath.row].amount!)"
        
        return cell
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
            self.itemList.insert(anObject as! Item, atIndex: newIndexPath!.row)
            self.transactionTableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            self.loadPieChart()
        default:
            return
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

//
//  CategoryTableViewController.swift
//  Exalon
//
//  Created by Shunfan Du on 7/26/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    let categoryCellIdentifier = "CategoryCell"
    
    // Example data for demo use
    var depositList: [Category] = []
    var withdrawList: [Category] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for category in fetchedResultsController.fetchedObjects! {
            let category = category as! Category
            
            if category.isDeposit!.boolValue {
                self.depositList.append(category)
            } else {
                self.withdrawList.append(category)
            }
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0:
            return max(self.depositList.count, 1)
        case 1:
            return max(self.withdrawList.count, 1)
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (section) {
        case 0:
            return "Deposit"
        case 1:
            return "Withdraw"
        default:
            return "Other"
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(categoryCellIdentifier, forIndexPath: indexPath)

        switch (indexPath.section) {
        case 0:
            if self.depositList.count == 0 {
                cell.textLabel?.text = "No deposit category"
            } else {
                cell.textLabel?.text = self.depositList[indexPath.row].name
            }
        case 1:
            if self.withdrawList.count == 0 {
                cell.textLabel?.text = "No withdraw category"
            } else {
                cell.textLabel?.text = self.withdrawList[indexPath.row].name
            }
        default:
            cell.textLabel?.text = "Other"
        }

        return cell
    }
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest(entityName: "Category")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.fetchBatchSize = 20
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataUtils.managedObjectContext(), sectionNameKeyPath: nil, cacheName: "CategoryCache")
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
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            let category = anObject as! Category
            
            if category.isDeposit!.boolValue {
                self.depositList.append(category)
                
                if self.depositList.count == 1 {
                    let newIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                    tableView.reloadRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
                } else {
                    let newIndexPath = NSIndexPath(forRow: self.depositList.count - 1, inSection: 0)
                    tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
                }
            } else {
                self.withdrawList.append(category)
                
                if self.withdrawList.count == 1 {
                    let newIndexPath = NSIndexPath(forRow: 0, inSection: 1)
                    tableView.reloadRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
                } else {
                    let newIndexPath = NSIndexPath(forRow: self.withdrawList.count - 1, inSection: 1)
                    tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
                }
            }
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

}

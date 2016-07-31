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
            return self.depositList.count
        case 1:
            return self.withdrawList.count
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
            cell.textLabel?.text = self.depositList[indexPath.row].name
        case 1:
            cell.textLabel?.text = self.withdrawList[indexPath.row].name
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
            print("hehe xd 1")
            let category = anObject as! Category
            
            if category.isDeposit!.boolValue {
                self.depositList.append(category)
                let newIndexPath = NSIndexPath(forRow: depositList.count - 1, inSection: 0)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            } else {
                self.withdrawList.append(category)
                let newIndexPath = NSIndexPath(forRow: withdrawList.count - 1, inSection: 1)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
        case .Delete:
            print("hehe xd 2")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

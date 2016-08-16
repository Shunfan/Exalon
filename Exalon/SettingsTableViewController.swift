//
//  SettingsTableViewController.swift
//  Exalon
//
//  Created by Shunfan Du on 8/15/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import ActionSheetPicker_3_0
import CoreData
import MessageUI
import UIKit

class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var touchIDSwitch: UISwitch!
    
    let currencyList = ["$", "¥", "€", "£"]
    
    var settings: Settings?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest(entityName: "Settings")
        
        do {
            let settingsList = try CoreDataUtils.managedObjectContext().executeFetchRequest(fetchRequest)
            
            if settingsList.count > 0 {
                self.settings = (settingsList[0] as! Settings)
            }
        } catch {
            // To be implemented
        }
        
        self.currencyLabel.text = self.settings!.currency
        self.touchIDSwitch.setOn(self.settings!.touchID!.boolValue, animated: true)
    }

    @IBAction func touchIDSwitched(sender: UISwitch) {
        if sender.on {
            self.settings!.touchID = true
        } else {
            self.settings!.touchID = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        CoreDataUtils.saveContext()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        case 2:
            return 1
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                ActionSheetMultipleStringPicker.showPickerWithTitle(
                    "Currency",
                    rows: [self.currencyList],
                    initialSelection: [self.currencyList.indexOf(self.settings!.currency!)!],
                    doneBlock: { picker, indexes, values in
                        self.currencyLabel.text = self.currencyList[indexes[0] as! Int]
                        self.settings!.currency = self.currencyList[indexes[0] as! Int]
                        return
                    },
                    cancelBlock: { ActionMultipleStringCancelBlock in return },
                    origin: tableView)
            default:
                print("NA")
            }
        case 2:
            switch indexPath.row {
            case 0:
                let mailComposeViewController = configuredMailComposeViewController()
                if MFMailComposeViewController.canSendMail() {
                    self.presentViewController(mailComposeViewController, animated: true, completion: nil)
                } else {
                    self.showSendMailErrorAlert()
                }
            default:
                print("NA")
            }
        default:
            print("NA")
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["feedback@exalonapp.com"])
        mailComposerVC.setSubject("Feedback from an Exalon user")
        mailComposerVC.setMessageBody("My modal name: \(UIDevice.currentDevice().modelName)", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let alertController = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .Alert)
        
        let okAlertAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertController.addAction(okAlertAction)

        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}

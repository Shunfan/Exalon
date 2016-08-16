//
//  AuthenticationViewController.swift
//  Exalon
//
//  Created by Shunfan Du on 8/15/16.
//  Copyright © 2016 Rose-Hulman. All rights reserved.
//

import LocalAuthentication
import UIKit

class AuthenticationViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        // Create an authentication context
        let authenticationContext = LAContext()
        
        var error: NSError?
        
        // Check if the device has a fingerprint sensor
        // If not, show the user an alert view and bail out!
        guard authenticationContext.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: &error) else {
            self.showAlertViewIfNoBiometricSensorHasBeenDetected()
            return
        }
        
        // Check the fingerprint
        authenticationContext.evaluatePolicy(
            .DeviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Only awesome people are allowed",
            reply: { [unowned self] (success, error) -> Void in
                
                if success {
                    // Fingerprint recognized
                    // Go to view controller
                    self.navigateToAuthenticatedViewController()
                } else {
                    // Check if there is an error
                    if let error = error {
                        let message = self.errorMessageForLAErrorCode(error.code)
                        self.showAlertWithTitle("Error", message: message)
                        
                    }
                    
                }
                
            })
    }
    
    func showAlertWithTitle(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let okAlertAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertController.addAction(okAlertAction)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func showAlertViewIfNoBiometricSensorHasBeenDetected(){
        self.showAlertWithTitle("Error", message: "This device does not have a TouchID sensor.")
    }
    
    func navigateToAuthenticatedViewController(){
        if let loggedInVC = storyboard?.instantiateViewControllerWithIdentifier("LoggedInViewController") {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.showViewController(loggedInVC, sender: self)
            }
        }
    }
    
    func errorMessageForLAErrorCode(errorCode: Int) -> String{
        var message = ""
        
        switch errorCode {
        case LAError.AppCancel.rawValue:
            message = "Authentication was cancelled by application"
        case LAError.AuthenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
        case LAError.InvalidContext.rawValue:
            message = "The context is invalid"
        case LAError.PasscodeNotSet.rawValue:
            message = "Passcode is not set on the device"
        case LAError.SystemCancel.rawValue:
            message = "Authentication was cancelled by the system"
        case LAError.TouchIDLockout.rawValue:
            message = "Too many failed attempts."
        case LAError.TouchIDNotAvailable.rawValue:
            message = "TouchID is not available on the device"
        case LAError.UserCancel.rawValue:
            message = "The user did cancel"
        case LAError.UserFallback.rawValue:
            message = "The user chose to use the fallback"
        default:
            message = "Did not find error code on LAError object"
        }
        
        return message
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

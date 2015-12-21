//
//  ViewController.swift
//  InstagramClone
//
//  Created by alex oh on 12/21/15.
//  Copyright © 2015 Alex Oh. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    
    var activityIndicator = UIActivityIndicatorView()
    
    @IBAction func signUp(sender: AnyObject) {
        
        if username.text == "" || password.text == "" {
            
            displayAlert("Error in Form", message: "Please enter a username and password")

        } else {
            
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            signUpThroughParse(username.text!, password: password.text!)
        }
        
    }
    
    @IBAction func logIn(sender: AnyObject) {
        
        if username.text == "" || password.text == "" {
            
            displayAlert("Error in Form", message: "Please enter a username and password")
            
        } else {
            
            PFUser.logInWithUsernameInBackground(username.text!, password: password.text!, block: { (user, error) -> Void in
                
                if error == nil {
                    
                    // signup successful
                    print("Log in successful")
                    
                } else {
                    
                    if let errorString = error?.userInfo["error"] as? String {
                        
                        self.displayAlert("Failed Log In", message: errorString)
                        
                    }
                    
                }

                
            })
        }
        
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    func displayAlert(title: String, message: String) {
        
        var alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    func signUpThroughParse(username: String, password: String) {
        
        var user = PFUser()
        
        user.username = username
        user.password = password
        
        user.signUpInBackgroundWithBlock { (success, error) -> Void in
            
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            
            if error == nil {
                
                // signup successful
                
            } else {
                
                if let errorString = error?.userInfo["error"] as? String {
                    
                    self.displayAlert("Failed SignUp", message: errorString)
                    
                }
                
            }
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


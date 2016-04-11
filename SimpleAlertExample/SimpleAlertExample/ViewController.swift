//
//  ViewController.swift
//  SimpleAlertExample
//
//  Created by dr2050 on 4/9/16.
//  Copyright © 2016 Confusion Studios LLC. All rights reserved.
//

import UIKit
import SimpleAlertLib

class ViewController: UIViewController {
    
    override func viewDidAppear(animated: Bool) {
        showFirstAlert()
    }

    @IBAction func showFirstAlert() {
        let alert = SimpleAlert.makeAlert("Very Simple", message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin arcu diam, laoreet non egestas nec, bibendum non neque.\n\nAre you really sure you want to do this?")
        alert.addButtonWithTitle("I'm insane!") {
            print("yeah I'm out of my head")
        }
        alert.addButtonWithTitle("Another Alert, Light") {
            self.showSecondAlert(true)
        }

        alert.addButtonWithTitle("Another Alert, Dark") {
            self.showSecondAlert(false)
        }
        
        alert.showInWindow(self.view.window!)
    
    
    }
    
    func showSecondAlert(useLight: Bool) {
    
        let alert = SimpleAlert.makeAlert("Another Alert", message: "You could fill out these boxes.");
        let username = alert.addTextFieldWithPlaceholder("Username", secureEntry: false, changeHandler: { (textField) in
            print("typing!")
        })
        alert.addTextFieldWithPlaceholder("Pass", secureEntry: true, changeHandler: nil)
        alert.addButtonWithTitle("OK", block: {
            print("Okay pressed, username is: \(username.text!)")
        })
        alert.addButtonWithTitle("Cancel", block: {})
        alert.theme = useLight ? .Light : .Dark
        alert.showInWindow(self.view.window!)
    
    }
    
    
}


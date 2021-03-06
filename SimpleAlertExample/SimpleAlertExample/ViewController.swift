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
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor.gray
        showFirstAlert()
        for i in 1...5 {
            showThirdAlert(i)
        }
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
        alert.show(onComplete: {}, animated: true)
    }
    
    func showSecondAlert(_ useLight: Bool) {
    
        let alert = SimpleAlert.makeAlert("Another Alert", message: "You could fill out these boxes.");
        let username = alert.addTextField(with: "Username", secureEntry: false, changeHandler: { (textField) in
            print("typing!")
        })
        alert.addTextField(with: "Pass", secureEntry: true, changeHandler: nil)
        alert.addButtonWithTitle("OK", block: {
            print("Okay pressed, username is: \(username.text!)")
        })
        alert.addButtonWithTitle("Cancel", block: {})
        alert.theme = useLight ? .light : .dark
        alert.show(onComplete: {
            username.becomeFirstResponder()
        }, animated: true)
    }
    
    func showThirdAlert(_ which: Int) {
        let alert = SimpleAlert.makeAlert(nil, message: "Many alerts: \(which)");
        alert.addButtonWithTitle("OK", block: {})
        alert.theme = .light
        alert.show(onComplete: {}, animated: true)
    }
    
    
}


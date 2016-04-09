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
        let alert = SimpleAlert(title: "Very Simple", message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec quam quam, posuere eu diam ut, imperdiet bibendum magna. Integer ut luctus enim, vel fermentum enim. Aenean elementum cursus metus, sit amet\n\niaculis tellus suscipit ac. Cras nec ex in ex auctor convallis. Nullam fermentum quam nibh, eget iaculis sapien eleifend eu. Proin arcu diam, laoreet non egestas nec, bibendum non neque.\n\nAre you really sure you want to do this?")
        alert.addButtonWithTitle("I'm insane!") { 
            print("yeah I'm out of my head")
        }
        alert.addButtonWithTitle("Show me another Alert") {
            let alert2 = SimpleAlert(title:"Another Alert", message: "Different theme, get it?");
            alert2.addButtonWithTitle("OK", block: { 
                print("Okay")
            })
            alert2.theme = .Light
            alert2.showInWindow(self.view.window!)
            
        }
        
        alert.addButtonWithTitle("Never Ask Me Again") {
            print("user doesn't want to be asked again")
        }
        
        alert.showInWindow(self.view.window!)
        
    }



}

// (c) Confusion Studios LLC and affiliates. Confidential and proprietary.

import SimpleAlertLib
import UIKit

class ViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        view.backgroundColor = UIColor.orange
        showFirstAlert()
        for i in 1 ... 5 {
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

        alert.showInWindow(view.window!)
    }

    func showSecondAlert(_ useLight: Bool) {
        let alert = SimpleAlert.makeAlert("Another Alert", message: "You could fill out these boxes.")
        let username = alert.addTextFieldWithPlaceholder("Username", secureEntry: false, changeHandler: { textField in
            print("typing!")
        })
        alert.addTextFieldWithPlaceholder("Pass", secureEntry: true, changeHandler: nil)
        alert.addButtonWithTitle("OK", block: {
            print("Okay pressed, username is: \(username.text!)")
        })
        alert.addButtonWithTitle("Cancel", block: {})
        alert.theme = useLight ? .light : .dark
        alert.showInWindow(view.window!)
    }

    func showThirdAlert(_ which: Int) {
        let alert = SimpleAlert.makeAlert("Title!", message: "Many alerts: \(which)")
        alert.addButtonWithTitle("OK", block: {})
        alert.theme = .light
        alert.showInWindow(view.window!)
    }
}

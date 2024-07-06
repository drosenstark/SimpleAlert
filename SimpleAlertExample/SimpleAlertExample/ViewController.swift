// (c) Confusion Studios LLC and affiliates. Confidential and proprietary.

import SimpleAlertLib
import UIKit

class ViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        view.backgroundColor = UIColor.orange
        showFirstAlert()
//        for i in 1 ... 5 {
//            showThirdAlert(i)
//        }
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

        alert.addButtonWithTitle("Do the picker") {
            self.showPickerAlert()
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

    func showPickerAlert() {
        let alertText = "This is an alert with a picker.\nIsn't it nice to have such a handy tool?\nIt makes selection so much easier!"
        let alert = SimpleAlert.makeAlert("Title!", message: alertText)
        let pickerView = TestPickerView()
        pickerView.backgroundColor = .white
        pickerView.tintColor = .black
        pickerView.layer.cornerRadius = pickerView.frame.size.height * 0.1
        pickerView.layer.borderColor = UIColor.black.cgColor
        pickerView.layer.borderWidth = 1.0

        alert.setCustomView(pickerView)
        let okButton = alert.addButtonWithTitle("OK", block: {})
        alert.doNotAutomaticallyEnableTheseButtons = [okButton]
        alert.addButtonWithTitle("Cancel", block: {})

        pickerView.setOnDirtyStateChangedHandler { isDirty in
            okButton.isEnabled = isDirty
        }

        alert.theme = .dark
        alert.showInWindow(view.window!)
    }
}

class PickerViewWithDirtyCleanState: UIPickerView, UIPickerViewDelegate {
    private var onDirtyStateChanged: ((Bool) -> Void)?
    private var initialValuesByComponent: [Int: Int]?

    public var areAllComponentsDirty: Bool = false {
        didSet {
            onDirtyStateChanged?(areAllComponentsDirty)
        }
    }

    override var dataSource: UIPickerViewDataSource? {
        didSet {
            setCleanState()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        delegate = self
    }

    func setOnDirtyStateChangedHandler(_ handler: ((Bool) -> Void)?) {
        onDirtyStateChanged = handler
    }

    func setCleanState() {
        var initialValue = [Int: Int]()
        let numberOfComponents = self.numberOfComponents
        for component in 0 ..< numberOfComponents {
            let selectedRow = self.selectedRow(inComponent: component)
            initialValue[component] = selectedRow
        }

        self.initialValuesByComponent = initialValue

        areAllComponentsDirty = false
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let initialValuesByComponent else { return }

        // Check if all components are dirty
        areAllComponentsDirty = initialValuesByComponent.allSatisfy { $0.value != pickerView.selectedRow(inComponent: $0.key) }
    }
}

class TestPickerView: PickerViewWithDirtyCleanState, UIPickerViewDataSource {
    let fruits = ["None", "Apple", "Banana", "Cherry", "Date", "Elderberry", "Fig", "Grape", "Honeydew", "Kiwi", "Lemon", "Mango", "Nectarine", "Orange", "Papaya", "Quince"]
    let preparations = ["None", "Sliced", "Diced", "Whole", "Juiced", "Pureed"]

    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        dataSource = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return fruits.count
        } else {
            return preparations.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return fruits[row]
        } else {
            return preparations[row]
        }
    }
}

//
//  AlertReplacement.swift
//  PlayingWithUI
//
//  Created by dr2050 on 4/7/16.
//  Copyright © 2016 Confusion Studios LLC. All rights reserved.
//

import UIKit
import Cartography


@objc public enum SimpleAlertTheme : Int { case dark, light }


@objc(SimpleAlert)
open class SimpleAlert: UIView, UITextFieldDelegate {

    weak static var lastAlert : SimpleAlert?

    let messageLabel = UILabel()
    let titleLabel = UILabel()
    open let box = UIView()
    open let buttonsBox = UIView()
    open var buttons: [UIButton] = []
    let textFieldsBox = UIView()
    var textFields: [UITextField] = []
    open var doNotAutomaticallyEnableTheseButtons : [UIButton] = []

    open var topIcon = UIView(frame: CGRect(x: 0,y: 0,width: 50,height: 50))
    open var modalBackgroundColor = UIColor.black.withAlphaComponent(0.4)
    open var boxBackgroundColor : UIColor!
    open var buttonsBoxBackgroundColor: UIColor!
    open var titleTextColor  : UIColor!
    open var messageTextColor  : UIColor!
    open var buttonHighlightColor  : UIColor!
    open var buttonsBoxColor: UIColor!

    open var boxWidth = CGFloat(250.0)
    open var topMargin = CGFloat(20.0)
    open var bottomMarginIfNecessary = CGFloat(20.0)
    open var sideMargin = CGFloat(20.0)
    open var spaceBetweenSections = CGFloat(10.0)

    open var textFieldTextColor = UIColor.black
    open var textFieldPlaceholderColor = UIColor.darkGray
    open var textFieldBackgroundColor = UIColor.white
    open var textFieldRowHeight = CGFloat(30.0)
    open var textFieldRowVerticalSpace = CGFloat(1.0)
    open var textFieldInset = CGFloat(10.0)

    open var buttonInset = CGFloat(0.0)
    let titleHeight = CGFloat(30.0)
    open var buttonRowHeight = CGFloat(40.0)
    open var buttonRowVerticalSpace = CGFloat(1.0)

    open var showAlertInTopHalf : Bool = false


    var showWasAnimated = false

    // working around a shared dependency on other stuff in my own libs
    open var doThisToEveryButton: ((UIButton)->())?


    // MARK: - class methods
    @objc(makeAlertWithTitle:message:)
    open class func makeAlert(_ title: String?, message: String) -> SimpleAlert {
        let retVal = SimpleAlert()
        retVal.title = title
        retVal.message = message
        retVal.theme = .dark
        return retVal
    }

    open var title : String? {
        didSet {
            titleLabel.text = title
        }
    }

    open var message : String? {
        didSet {
            messageLabel.text = message
        }
    }

    // MARK: - Add Methods
    @discardableResult
    open func addButtonWithTitle(_ title: String, block: (()->())?) -> UIButton {
        return addButtonWithTitle(title, dismissAlertOnTouchUp: true, block: block)
    }

    @discardableResult
    open func addButtonWithTitle(_ title: String, dismissAlertOnTouchUp: Bool, block: (()->())?) -> UIButton {
        return setupButtonWithText(title, dismissAlertOnTouchUp: dismissAlertOnTouchUp, handler: block)
    }

    @discardableResult
    open func addTextFieldWithPlaceholder(_ placeholder:String, secureEntry: Bool, changeHandler: ((UITextField)->())?) -> UITextField {
        let retVal = UITextField()
        retVal.backgroundColor = UIColor.white
        retVal.placeholder = placeholder
        retVal.isSecureTextEntry = secureEntry
        retVal.font = UIFont.systemFont(ofSize: textFieldRowHeight / 3.0 + 2.0)
        retVal.delegate = self
        if let handler = changeHandler {
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: retVal, queue: OperationQueue.main) { (notification) in
                handler(retVal)
            }
        }


        textFields.append(retVal)
        textFieldsBox.addSubview(retVal)

        return retVal
    }


    open func showInWindow(_ window: UIWindow, animated : Bool = true)  {

        // if you're trying to show the same thing twice, we just get out
        if let lastAlert = SimpleAlert.lastAlert, lastAlert.superview != nil {
            if (lastAlert.title == self.title && lastAlert.message == self.message && lastAlert.buttons.count == self.buttons.count) {
                return
            } else {
                self.modalBackgroundColor = UIColor.clear
            }
        } else {
            SimpleAlert.lastAlert = self
        }


        window.addSubview(self)
        self.frame = window.bounds
        self.prepSubviews()

        if (animated) {
            self.alpha = 0.0
            UIView.animate(withDuration: 0.5, animations: {
                self.alpha = 1.0
            })
        }

        self.perform(#selector(enableButtons), with: nil, afterDelay: 0.5)
        showWasAnimated = animated
    }

    @objc open func enableButtons() {
        addKeyboardNotifications()
        for button in self.buttons {
            if (!doNotAutomaticallyEnableTheseButtons.contains(button)) {
                button.isEnabled = true
            }
        }
    }

    // MARK: - Dismiss
    func fastDismiss() {
        self.removeFromSuperview()
        removeKeyboardNotifications()
    }

    open func dismiss() {
        removeKeyboardNotifications()
        if (!showWasAnimated) {
            self.removeFromSuperview()
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.alpha = 0.0
            }, completion: { (_) in
                self.removeFromSuperview()
            })
        }
    }

    // MARK: - UITextFieldDelegate Methods
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    open func textFieldDidBeginEditing(_ textField: UITextField) {
    }


    // MARK: - Keyboard notifications to get UITextFields out of the way
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }

    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    var frameBeforePullup : CGRect?
    var framePulledUp : CGRect?
    var bottomOfTextNeedsPullUpBy : CGFloat?

    @objc open func keyboardDidShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let keyboardFrame : CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else {
            return
        }
        guard let textField = self.textFields.last else { return }
        var textFieldFrame = textField.window!.convert(textField.frame, from: textField.superview)
        textFieldFrame.size.height += 10
        if keyboardFrame.intersects(textFieldFrame) {
            if (frameBeforePullup == nil) {
                frameBeforePullup = box.frame
                bottomOfTextNeedsPullUpBy = textFieldFrame.origin.y + textFieldFrame.size.height - keyboardFrame.origin.y
            }
            var frame = box.frame
            frame.origin.y -= bottomOfTextNeedsPullUpBy!
            framePulledUp = frame
            box.frame = frame
            layoutTopIcon()
        }
        return
    }

    @objc open func keyboardDidHide(_ notification: Notification) {
        guard let frameBeforePullup = frameBeforePullup else { return }
        box.frame = frameBeforePullup
        layoutTopIcon()
        framePulledUp = nil
    }

    // MARK: - Theme
    // the initial value is for Objective-C to work
    open var theme : SimpleAlertTheme = .dark {
        didSet {
            if (theme == .dark) {
                boxBackgroundColor = UIColor.black
                titleTextColor = UIColor.white
                buttonHighlightColor = UIColor.lightGray
                textFieldBackgroundColor = UIColor.white
                textFieldTextColor = UIColor.black
                textFieldPlaceholderColor = UIColor.darkGray
            } else {
                boxBackgroundColor = UIColor.white
                titleTextColor = UIColor.black
                buttonHighlightColor = UIColor.lightGray
                textFieldBackgroundColor = UIColor.black
                textFieldTextColor = UIColor.white
                textFieldPlaceholderColor = UIColor.lightGray
            }
            messageTextColor = titleTextColor
            buttonsBoxColor = buttonHighlightColor
            buttonsBoxBackgroundColor = boxBackgroundColor
        }

    }




    func setupButtonWithText(_ text: String, dismissAlertOnTouchUp: Bool = true, handler: (()->())?) -> UIButton {
        let button = ButtonSub.makeButtonSub(handler)
        if let doThis = self.doThisToEveryButton {
            doThis(button)
        }
        button.setTitle(text, for: UIControlState())
        button.setTitleColor(self.tintColor, for: UIControlState())

        button.addTarget(self, action: #selector(SimpleAlert.handleButtonTouch(_:)), for: UIControlEvents.touchDown)
        button.addTarget(self, action: #selector(SimpleAlert.handleButtonTouchUp(_:)), for: UIControlEvents.touchUpOutside)
        if (dismissAlertOnTouchUp) {
            button.addTarget(self, action: #selector(SimpleAlert.handleButtonTouchUpInside(_:)), for: UIControlEvents.touchUpInside)
        } else {
            button.addTarget(self, action: #selector(SimpleAlert.handleButtonTouchUp(_:)), for: UIControlEvents.touchUpInside)
        }
        buttonsBox.addSubview(button)
        buttons.append(button)

        return button
    }

    var boxConstraints : ConstraintGroup!

    // public for being overridden
    open func prepSubviews() {
        addSubview(topIcon)
        box.layer.cornerRadius = 10.0
        backgroundColor = modalBackgroundColor
        box.backgroundColor = boxBackgroundColor
        box.clipsToBounds = true
        addSubview(box)

        titleLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.textColor = titleTextColor
        box.addSubview(titleLabel)

        messageLabel.font = UIFont.systemFont(ofSize: 13.0)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.textColor = messageTextColor
        box.addSubview(messageLabel)

        box.addSubview(textFieldsBox)
        textFieldsBox.clipsToBounds = true

        let textFieldRowTotalHeight = textFieldRowHeight + textFieldRowVerticalSpace
        let textFieldsBoxHeight = textFieldRowTotalHeight * CGFloat(textFields.count)

        box.addSubview(buttonsBox)
        buttonsBox.backgroundColor = buttonsBoxColor
        buttonsBox.clipsToBounds = true

        let buttonRowTotalHeight = buttonRowHeight + buttonRowVerticalSpace
        let buttonsBoxHeight = buttonRowTotalHeight * CGFloat(buttons.count)

        self.bringSubview(toFront: self.topIcon)

        constrain(self) { view in
            view.size == view.superview!.size
        }

        let titleHeight = self.title == nil ? 0.0 : self.titleHeight

        boxConstraints = constrain(box) { box in
            box.width == boxWidth
            if (showAlertInTopHalf) {
                box.centerY == box.superview!.centerY * 0.50
                box.centerX == box.superview!.centerX
            } else {
                box.center == box.superview!.center
            }
        }

        constrain(box, titleLabel, messageLabel, buttonsBox, textFieldsBox) { box, titleLabel, messageLabel, buttonsBox, textFieldsBox in
            titleLabel.width == box.width - sideMargin * 2
            titleLabel.centerX == box.centerX
            titleLabel.height == titleHeight

            messageLabel.width == titleLabel.width
            messageLabel.centerX == box.centerX

            textFieldsBox.width == box.width
            textFieldsBox.centerX == box.centerX

            buttonsBox.width == box.width
            buttonsBox.centerX == box.centerX

            titleLabel.top == box.top + topMargin
            messageLabel.top == titleLabel.bottom + spaceBetweenSections

            textFieldsBox.height == textFieldsBoxHeight
            textFieldsBox.top == messageLabel.bottom + spaceBetweenSections
            let spaceAfterTextFields = textFieldsBoxHeight == 0 ? 0 : spaceBetweenSections * 0.5

            buttonsBox.height == buttonsBoxHeight
            buttonsBox.top == textFieldsBox.bottom + spaceAfterTextFields

            var boxHeightWithoutMessage = topMargin + titleHeight  + 2 * spaceBetweenSections + spaceAfterTextFields
            boxHeightWithoutMessage += textFieldsBoxHeight // (textFieldsBoxHeight > 0) ? buttonsBoxHeight + buttonInset * 0.5 : bottomMarginIfNecessary
            boxHeightWithoutMessage += (buttonsBoxHeight > 0) ? buttonsBoxHeight : bottomMarginIfNecessary
            box.height == messageLabel.height + boxHeightWithoutMessage
        }


        for (index, textField) in textFields.enumerated() {

            textField.backgroundColor = textFieldBackgroundColor
            textField.textColor = textFieldTextColor

            // [[NSAttributedString alloc] initWithString:@"PlaceHolder Text" attributes:@{NSForegroundColorAttributeName: color}];
            if let placeholderText = textField.placeholder {
                textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedStringKey.foregroundColor: textFieldPlaceholderColor]);
            }

            let radiusAndInset = textFieldRowHeight / 8.0
            textField.layer.cornerRadius = radiusAndInset
            let leftBox = UIView(frame: CGRect(x: 0, y: 0, width: radiusAndInset * 2.0, height: 1))
            textField.leftView = leftBox
            textField.leftViewMode = .always

            let top = CGFloat(CGFloat(index) * textFieldRowTotalHeight)
            constrain(textFieldsBox, textField) { textFieldsBox, textField in
                textField.height == textFieldRowHeight
                textField.width == textFieldsBox.width - textFieldInset
                textField.centerX == textFieldsBox.centerX
                textField.top == textFieldsBox.top + top + textFieldRowVerticalSpace
            }

        }

        for (index, button) in buttons.enumerated() {
            // change button color
            handleButtonTouchUp(button)

            let top = CGFloat(CGFloat(index) * (buttonRowTotalHeight))
            constrain(buttonsBox, button) { buttonsBox, button in
                button.height == buttonRowHeight
                button.width == buttonsBox.width - buttonInset
                button.centerX == buttonsBox.centerX
                button.top == buttonsBox.top + buttonRowVerticalSpace + top
            }

        }

    }



    // MARK: - Each button calls these for highlighting background
    @objc func handleButtonTouch(_ button: UIButton) {
        button.backgroundColor = buttonHighlightColor
    }

    @objc func handleButtonTouchUp(_ button: UIButton) {
        button.backgroundColor = buttonsBoxBackgroundColor
    }

    @objc func handleButtonTouchUpInside(_ button: UIButton) {
        self.dismiss()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        layoutTopIcon()
    }

    func layoutTopIcon() {
        var frame = self.topIcon.frame
        frame.origin.y = self.box.frame.origin.y - 0.5 * frame.size.height
        frame.origin.x = 0.5 * (self.bounds.size.width - frame.size.width)
        topIcon.frame = frame
    }

}


// MARK: - Special UIButton Sub
class ButtonSub : UIButton {

    var handler: (()->())?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    class func makeButtonSub(_ handler: (()->())?) -> ButtonSub {
        let retVal = ButtonSub(type: .custom)
        retVal.handler = handler
        retVal.addTarget(retVal, action: #selector(callHandler), for: .touchUpInside)
        retVal.isEnabled = false
        return retVal
    }

    init() {
        super.init(frame: CGRect.zero)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }


    @objc func callHandler() {
        handler?()
    }


}

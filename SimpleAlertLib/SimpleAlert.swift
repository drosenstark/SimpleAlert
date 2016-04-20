//
//  AlertReplacement.swift
//  PlayingWithUI
//
//  Created by dr2050 on 4/7/16.
//  Copyright © 2016 Confusion Studios LLC. All rights reserved.
//

import UIKit
import Cartography


@objc public enum SimpleAlertTheme : Int { case Dark, Light }


@objc(SimpleAlert)
public class SimpleAlert: UIView {
    
    weak static var lastAlert : SimpleAlert?
    
    let messageLabel = UILabel()
    let titleLabel = UILabel()
    public let box = UIView()
    public let buttonsBox = UIView()
    public var buttons: [UIButton] = []
    let textFieldsBox = UIView()
    var textFields: [UITextField] = []
    
    public var topIcon = UIView(frame: CGRectMake(0,0,50,50))
    public var modalBackgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
    public var boxBackgroundColor : UIColor!
    public var buttonsBoxBackgroundColor: UIColor!
    public var titleTextColor  : UIColor!
    public var messageTextColor  : UIColor!
    public var buttonHighlightColor  : UIColor!
    public var buttonsBoxColor: UIColor!
    
    public var boxWidth = CGFloat(250.0)
    public var topMargin = CGFloat(20.0)
    public var bottomMarginIfNecessary = CGFloat(20.0)
    public var sideMargin = CGFloat(20.0)
    public var spaceBetweenSections = CGFloat(10.0)
    
    public var textFieldTextColor = UIColor.blackColor()
    public var textFieldPlaceholderColor = UIColor.darkGrayColor()
    public var textFieldBackgroundColor = UIColor.whiteColor()
    public var textFieldRowHeight = CGFloat(30.0)
    public var textFieldRowVerticalSpace = CGFloat(1.0)
    public var textFieldInset = CGFloat(10.0)
    
    public var buttonInset = CGFloat(0.0)
    let titleHeight = CGFloat(30.0)
    public var buttonRowHeight = CGFloat(40.0)
    public var buttonRowVerticalSpace = CGFloat(1.0)
    
    var showWasAnimated = false
    
    // working around a shared dependency on other stuff in my own libs
    public var doThisToEveryButton: ((UIButton)->())?
    
    
    // MARK: - class methods
    public class func makeAlert(title: String?, message: String) -> SimpleAlert {
        let retVal = SimpleAlert()
        retVal.title = title
        retVal.message = message
        retVal.theme = .Dark
        return retVal
    }
    
    public var title : String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    public var message : String? {
        didSet {
            messageLabel.text = message
        }
    }
    
    // MARK: - Add Methods
    public func addButtonWithTitle(title: String, block: (()->())?) -> UIButton {
        return setupButtonWithText(title, handler: block)
    }
    
    public func addTextFieldWithPlaceholder(placeholder:String, secureEntry: Bool, changeHandler: ((UITextField)->())?) -> UITextField {
        let retVal = UITextField()
        retVal.backgroundColor = UIColor.whiteColor()
        retVal.placeholder = placeholder
        retVal.secureTextEntry = secureEntry
        retVal.font = UIFont.systemFontOfSize(textFieldRowHeight / 3.0 + 2.0)
        if let handler = changeHandler {
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: retVal, queue: NSOperationQueue.mainQueue()) { (notification) in
                handler(retVal)
            }
        }
        
        
        textFields.append(retVal)
        textFieldsBox.addSubview(retVal)
        
        return retVal
    }
    
    
    public func showInWindow(window: UIWindow, animated : Bool = true)  {
        
        // if you're trying to show the same thing twice, we just get out
        if let lastAlert = SimpleAlert.lastAlert where lastAlert.superview != nil {
            if (lastAlert.title == self.title && lastAlert.message == self.message && lastAlert.buttons.count == self.buttons.count) {
                return
            } else {
                self.modalBackgroundColor = UIColor.clearColor()
            }
        } else {
            SimpleAlert.lastAlert = self
        }
        
        
        window.addSubview(self)
        self.frame = window.bounds
        self.prepSubviews()
        
        if (animated) {
            self.alpha = 0.0
            UIView.animateWithDuration(0.5) {
                self.alpha = 1.0
            }
        }
        
        self.performSelector(#selector(enableButtons), withObject: nil, afterDelay: 0.5)
        showWasAnimated = animated
    }
    
    public func enableButtons() {
        for button in self.buttons {
            button.enabled = true
        }
    }
    
    func fastDismiss() {
        self.removeFromSuperview()
    }
    
    public func dismiss() {
        if (!showWasAnimated) {
            self.removeFromSuperview()
        } else {
            UIView.animateWithDuration(0.5, animations: {
                self.alpha = 0.0
            }) { (_) in
                self.removeFromSuperview()
            }
        }
    }
    
    
    // the initial value is for Objective-C to work
    public var theme : SimpleAlertTheme = .Dark {
        didSet {
            if (theme == .Dark) {
                boxBackgroundColor = UIColor.blackColor()
                titleTextColor = UIColor.whiteColor()
                buttonHighlightColor = UIColor.lightGrayColor()
                textFieldBackgroundColor = UIColor.whiteColor()
            } else {
                boxBackgroundColor = UIColor.whiteColor()
                titleTextColor = UIColor.blackColor()
                buttonHighlightColor = UIColor.lightGrayColor()
                textFieldBackgroundColor = UIColor.lightGrayColor()
            }
            textFieldTextColor = UIColor.blackColor()
            textFieldPlaceholderColor = UIColor.darkGrayColor()
            messageTextColor = titleTextColor
            buttonsBoxColor = buttonHighlightColor
            buttonsBoxBackgroundColor = boxBackgroundColor
        }
        
    }
    
    
    
    
    func setupButtonWithText(text: String, handler: (()->())?) -> UIButton {
        let button = ButtonSub.makeButtonSub(handler)
        if let doThis = self.doThisToEveryButton {
            doThis(button)
        }
        button.setTitle(text, forState: .Normal)
        button.setTitleColor(self.tintColor, forState: UIControlState.Normal)
        
        button.addTarget(self, action: #selector(SimpleAlert.handleButtonTouch(_:)), forControlEvents: UIControlEvents.TouchDown)
        button.addTarget(self, action: #selector(SimpleAlert.handleButtonTouchUp(_:)), forControlEvents: UIControlEvents.TouchUpOutside)
        button.addTarget(self, action: #selector(SimpleAlert.handleButtonTouchUpInside(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonsBox.addSubview(button)
        buttons.append(button)
        
        return button
    }
    
    
    // public for being overridden
    public func prepSubviews() {
        addSubview(topIcon)
        box.layer.cornerRadius = 10.0
        backgroundColor = modalBackgroundColor
        box.backgroundColor = boxBackgroundColor
        box.clipsToBounds = true
        addSubview(box)
        
        titleLabel.font = UIFont.boldSystemFontOfSize(17.0)
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .Center
        titleLabel.textColor = titleTextColor
        box.addSubview(titleLabel)
        
        messageLabel.font = UIFont.systemFontOfSize(13.0)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .Center
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
        
        self.bringSubviewToFront(self.topIcon)
        
        constrain(self) { view in
            view.size == view.superview!.size
        }
        
        let titleHeight = self.title == nil ? 0.0 : self.titleHeight
        
        constrain(box, titleLabel, messageLabel, buttonsBox, textFieldsBox) { box, titleLabel, messageLabel, buttonsBox, textFieldsBox in
            box.width == boxWidth
            box.center == box.superview!.center
            
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
        
        
        for (index, textField) in textFields.enumerate() {
            
            textField.backgroundColor = textFieldBackgroundColor
            // [[NSAttributedString alloc] initWithString:@"PlaceHolder Text" attributes:@{NSForegroundColorAttributeName: color}];
            if let placeholderText = textField.placeholder {
                textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSForegroundColorAttributeName: textFieldPlaceholderColor]);
            }
            
            let radiusAndInset = textFieldRowHeight / 8.0
            textField.layer.cornerRadius = radiusAndInset
            let leftBox = UIView(frame: CGRectMake(0, 0, radiusAndInset * 2.0, 1))
            textField.leftView = leftBox
            textField.leftViewMode = .Always
            
            let top = CGFloat(CGFloat(index) * textFieldRowTotalHeight)
            constrain(textFieldsBox, textField) { textFieldsBox, textField in
                textField.height == textFieldRowHeight
                textField.width == textFieldsBox.width - textFieldInset
                textField.centerX == textFieldsBox.centerX
                textField.top == textFieldsBox.top + top + textFieldRowVerticalSpace
            }
            
        }
        
        for (index, button) in buttons.enumerate() {
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
    func handleButtonTouch(button: UIButton) {
        button.backgroundColor = buttonHighlightColor
    }
    
    func handleButtonTouchUp(button: UIButton) {
        button.backgroundColor = buttonsBoxBackgroundColor
    }
    func handleButtonTouchUpInside(button: UIButton) {
        self.dismiss()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        var frame = self.topIcon.frame
        frame.origin.y = self.box.frame.origin.y - 0.5 * frame.size.height
        frame.origin.x = 0.5 * (self.bounds.size.width - frame.size.width)
        topIcon.frame = frame
        
    }
    
}

class ButtonSub : UIButton {
    
    var handler: (()->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    class func makeButtonSub(handler: (()->())?) -> ButtonSub {
        let retVal = ButtonSub(type: .Custom)
        retVal.handler = handler
        retVal.addTarget(retVal, action: #selector(callHandler), forControlEvents: .TouchUpInside)
        retVal.enabled = false
        return retVal
    }
    
    init() {
        super.init(frame: CGRectZero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    func callHandler() {
        handler?()
    }
    
    
}
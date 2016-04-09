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


    let messageLabel = UILabel()
    let titleLabel = UILabel()
    let box = UIView()
    let otherViewsBox = UIView()
    var otherViews: [UIView] = []

    public var modalBackgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
    public var boxBackgroundColor : UIColor!
    public var titleTextColor  : UIColor!
    public var messageTextColor  : UIColor!
    public var buttonHighlightColor  : UIColor!
    public var otherViewBoxColor : UIColor!

    public var topMargin = CGFloat(20.0)
    public var bottomMarginIfNecessary = CGFloat(20.0)
    public var sideMargin = CGFloat(20.0)
    public var spaceBetweenSections = CGFloat(10.0)
    public var otherViewInset = CGFloat(0.0)
    let titleHeight = CGFloat(30.0)
    public var otherViewRowHeight = CGFloat(40.0)
    public var otherViewRowSpace = CGFloat(0.5)

    // working around a shared dependency on other stuff in my own libs
    public var doThisToEveryButton: ((UIButton)->())?


    // MARK: - class methods
    public class func makeAlert(title: String, message: String) -> SimpleAlert {
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
    public func addButtonWithTitle(title: String, block: ()->()) -> UIButton {
        return setupButtonWithText(title, handler: block)
    }

//    public func addCancelButtonWithTitle(title: String, block: ()->()) -> UIButton {
//        return setupButtonWithText(title, handler: block)
//    }
//
//    public func addDestructiveButtonWithTitle(title: String, block: ()->()) -> UIButton {
//        return setupButtonWithText(title, handler: block)
//    }
//
    public func showInWindow(window: UIWindow)  {
        window.addSubview(self)
        self.frame = window.bounds
        self.prepSubviews()
    }

    // the initial value is for Objective-C to work
    public var theme : SimpleAlertTheme = .Dark {
        didSet {
            if (theme == .Dark) {
                boxBackgroundColor = UIColor.blackColor()
                titleTextColor = UIColor.whiteColor()
                buttonHighlightColor = UIColor.lightGrayColor()
            } else {
                boxBackgroundColor = UIColor.whiteColor()
                titleTextColor = UIColor.blackColor()
                buttonHighlightColor = UIColor.lightGrayColor()
            }
            messageTextColor = titleTextColor
            otherViewBoxColor = buttonHighlightColor
        }

    }




    func setupButtonWithText(text: String, handler: ()->()) -> UIButton {
        let button = ButtonSub.makeButtonSub(handler)
        if let doThis = self.doThisToEveryButton {
            doThis(button)
        }
        button.setTitle(text, forState: .Normal)
        button.setTitleColor(self.tintColor, forState: UIControlState.Normal)

        button.addTarget(self, action: #selector(SimpleAlert.handleButtonTouch(_:)), forControlEvents: UIControlEvents.TouchDown)
        button.addTarget(self, action: #selector(SimpleAlert.handleButtonTouchUp(_:)), forControlEvents: UIControlEvents.TouchUpOutside)
        button.addTarget(self, action: #selector(SimpleAlert.handleButtonTouchUpInside(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        otherViewsBox.addSubview(button)
        otherViews.append(button)


        return button
    }


    // public for being overridden
    public func prepSubviews() {
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

        box.addSubview(otherViewsBox)
        otherViewsBox.backgroundColor = otherViewBoxColor
        otherViewsBox.clipsToBounds = true

        let otherViewRowTotalHeight = otherViewRowHeight + otherViewRowSpace


        let otherViewsBoxHeight = otherViewRowTotalHeight * CGFloat(otherViews.count)

        constrain(self, box, titleLabel, messageLabel, otherViewsBox) { view, box, titleLabel, messageLabel, otherViewsBox in

            view.size == view.superview!.size
            box.width == 250
            box.center == view.center

            titleLabel.width == box.width - sideMargin * 2
            titleLabel.centerX == box.centerX
            titleLabel.height == titleHeight

            messageLabel.width == titleLabel.width
            messageLabel.centerX == box.centerX

            otherViewsBox.width == box.width
            otherViewsBox.centerX == box.centerX


            titleLabel.top == box.top + topMargin
            messageLabel.top == titleLabel.bottom + spaceBetweenSections

            otherViewsBox.height == otherViewsBoxHeight
            otherViewsBox.top == messageLabel.bottom + spaceBetweenSections

            var boxHeightWithoutMessage = topMargin + titleHeight  + 2 * spaceBetweenSections
            boxHeightWithoutMessage += (otherViewsBoxHeight > 0) ? otherViewsBoxHeight + otherViewInset * 0.25 : bottomMarginIfNecessary

            box.height == messageLabel.height + boxHeightWithoutMessage

        }

        for (index, otherView) in otherViews.enumerate() {
            // change button color
            if let button = otherView as? UIButton {
                handleButtonTouchUp(button)
            }

            let top = otherViewRowSpace + CGFloat(CGFloat(index) * otherViewRowTotalHeight + 0.25 * otherViewInset)
            constrain(otherViewsBox, otherView) { otherViewsBox, otherView in
                otherView.height == otherViewRowHeight - 0.5 * otherViewInset
                otherView.width == otherViewsBox.width - otherViewInset
                otherView.centerX == otherViewsBox.centerX
                otherView.top == otherViewsBox.top + top
            }

        }

    }

    public func dismiss() {
        self.removeFromSuperview()
    }

    // MARK: - Each button calls these for highlighting background
    func handleButtonTouch(button: UIButton) {
        button.backgroundColor = buttonHighlightColor
    }

    func handleButtonTouchUp(button: UIButton) {
        button.backgroundColor = boxBackgroundColor
    }
    func handleButtonTouchUpInside(button: UIButton) {
        self.dismiss()
    }



}

class ButtonSub : UIButton {

    var handler: (()->())?


    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    class func makeButtonSub(handler: ()->()) -> ButtonSub {
        let retVal = ButtonSub(type: .Custom)
        retVal.handler = handler
        retVal.addTarget(retVal, action: #selector(callHandler), forControlEvents: .TouchUpInside)
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

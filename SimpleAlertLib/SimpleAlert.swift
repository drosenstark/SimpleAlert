// (c) Confusion Studios LLC and affiliates. Confidential and proprietary.

@objc public enum SimpleAlertTheme: Int { case dark, light }

@objc open class SimpleAlert: UIView, UITextFieldDelegate {
    weak static var lastAlert: SimpleAlert?

    let messageLabel = UILabel()
    let titleLabel = UILabel()
    @objc public let box = UIView()
    @objc public let buttonsBox = UIView()
    @objc open var buttons: [UIButton] = []
    let textFieldsBox = UIView()
    var textFields: [UITextField] = []
    @objc open var doNotAutomaticallyEnableTheseButtons: [UIButton] = []

    @objc open var topIcon = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    @objc open var modalBackgroundColor = UIColor.black.withAlphaComponent(0.4)
    @objc open var boxBackgroundColor: UIColor!
    @objc open var buttonsBoxBackgroundColor: UIColor!
    @objc open var titleTextColor: UIColor!
    @objc open var messageTextColor: UIColor!
    @objc open var buttonHighlightColor: UIColor!
    @objc open var buttonsBoxColor: UIColor!

    @objc open var boxWidth = CGFloat(300.0)
    @objc open var topMargin = CGFloat(20.0)
    @objc open var bottomMarginIfNecessary = CGFloat(20.0)
    @objc open var sideMargin = CGFloat(20.0)
    @objc open var spaceBetweenSections = CGFloat(10.0)

    @objc open var textFieldTextColor = UIColor.black
    @objc open var textFieldPlaceholderColor = UIColor.darkGray
    @objc open var textFieldBackgroundColor = UIColor.white
    @objc open var textFieldRowHeight = CGFloat(30.0)
    @objc open var textFieldRowVerticalSpace = CGFloat(1.0)
    @objc open var textFieldInset = CGFloat(10.0)

    @objc open var buttonInset = CGFloat(0.0)
    let titleHeight = CGFloat(30.0)
    @objc open var buttonRowHeight = CGFloat(40.0)
    @objc open var buttonRowVerticalSpace = CGFloat(1.0)

    @objc open var showAlertInTopHalf: Bool = false

    var showWasAnimated = false

    // working around a shared dependency on other stuff in my own libs
    @objc open var doThisToEveryButton: ((UIButton) -> Void)?

    // MARK: - class methods

    @objc(makeAlertWithTitle:message:)
    open class func makeAlert(_ title: String?, message: String) -> SimpleAlert {
        let retVal = SimpleAlert()
        retVal.title = title
        retVal.message = message
        retVal.theme = .dark
        return retVal
    }

    @objc open var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    @objc open var message: String? {
        didSet {
            messageLabel.text = message
        }
    }

    // MARK: - Add Methods

    @discardableResult
    @objc open func addButtonWithTitle(_ title: String, block: (() -> Void)?) -> UIButton {
        return addButtonWithTitle(title, dismissAlertOnTouchUp: true, block: block)
    }

    @discardableResult
    @objc open func addButtonWithTitle(_ title: String, dismissAlertOnTouchUp: Bool, block: (() -> Void)?) -> UIButton {
        return setupButtonWithText(title, dismissAlertOnTouchUp: dismissAlertOnTouchUp, handler: block)
    }

    @discardableResult
    @objc open func addTextFieldWithPlaceholder(_ placeholder: String, secureEntry: Bool, changeHandler: ((UITextField) -> Void)?) -> UITextField {
        let retVal = UITextField()
        retVal.backgroundColor = UIColor.white
        retVal.placeholder = placeholder
        retVal.isSecureTextEntry = secureEntry
        retVal.font = UIFont.systemFont(ofSize: textFieldRowHeight / 3.0 + 2.0)
        retVal.delegate = self
        if let handler = changeHandler {
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: retVal, queue: OperationQueue.main) { notification in
                handler(retVal)
            }
        }

        textFields.append(retVal)
        textFieldsBox.addSubview(retVal)

        return retVal
    }

    @objc open func showInWindow(_ window: UIWindow, animated: Bool = true) {
        // if you're trying to show the same thing twice, we just get out
        if let lastAlert = SimpleAlert.lastAlert, lastAlert.superview != nil {
            if lastAlert.title == title, lastAlert.message == message, lastAlert.buttons.count == buttons.count {
                return
            } else {
                modalBackgroundColor = UIColor.clear
            }
        } else {
            SimpleAlert.lastAlert = self
        }

        window.addSubview(self)

        translatesAutoresizingMaskIntoConstraints = false

        widthAnchor.constraint(equalTo: window.widthAnchor).activateAndName("simpleAlert.widthOne")
        heightAnchor.constraint(equalTo: window.heightAnchor).activateAndName("simpleAlert.heightOne")

        prepSubviews()

        if animated {
            alpha = 0.0
            UIView.animate(withDuration: 0.5, animations: {
                self.alpha = 1.0
            })
        }

        perform(#selector(enableButtons), with: nil, afterDelay: 0.5)
        showWasAnimated = animated
    }

    @objc open func enableButtons() {
        addKeyboardNotifications()
        for button in buttons {
            if !doNotAutomaticallyEnableTheseButtons.contains(button) {
                button.isEnabled = true
            }
        }
    }

    // MARK: - Dismiss

    func fastDismiss() {
        removeFromSuperview()
        removeKeyboardNotifications()
    }

    @objc open func dismiss() {
        removeKeyboardNotifications()
        if !showWasAnimated {
            DispatchQueue.main.async {
                self.removeFromSuperview()
            }
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.alpha = 0.0
            }, completion: { _ in
                self.removeFromSuperview()
            })
        }
    }

    // MARK: - UITextFieldDelegate Methods

    @objc open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    @objc open func textFieldDidBeginEditing(_ textField: UITextField) {}

    // MARK: - Keyboard notifications to get UITextFields out of the way

    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    var frameBeforePullup: CGRect?
    var framePulledUp: CGRect?
    var bottomOfTextNeedsPullUpBy: CGFloat?

    @objc open func keyboardDidShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else {
            return
        }
        guard let textField = textFields.last else { return }
        var textFieldFrame = textField.window!.convert(textField.frame, from: textField.superview)
        textFieldFrame.size.height += 10
        if keyboardFrame.intersects(textFieldFrame) {
            if frameBeforePullup == nil {
                frameBeforePullup = box.frame
                bottomOfTextNeedsPullUpBy = textFieldFrame.origin.y + textFieldFrame.size.height - keyboardFrame.origin.y
            }
            var frame = box.frame
            frame.origin.y -= bottomOfTextNeedsPullUpBy!
            framePulledUp = frame
            box.frame = frame
            layoutTopIcon()
        }
    }

    @objc open func keyboardDidHide(_ notification: Notification) {
        guard let frameBeforePullup = frameBeforePullup else { return }
        box.frame = frameBeforePullup
        layoutTopIcon()
        framePulledUp = nil
    }

    // MARK: - Theme

    // the initial value is for Objective-C to work
    @objc open var theme: SimpleAlertTheme = .dark {
        didSet {
            if theme == .dark {
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

    func setupButtonWithText(_ text: String, dismissAlertOnTouchUp: Bool = true, handler: (() -> Void)?) -> UIButton {
        let button = ButtonSub.makeButtonSub(handler)
        if let doThis = doThisToEveryButton {
            doThis(button)
        }
        button.setTitle(text, for: UIControl.State())
        button.setTitleColor(tintColor, for: UIControl.State())

        button.addTarget(self, action: #selector(SimpleAlert.handleButtonTouch(_:)), for: UIControl.Event.touchDown)
        button.addTarget(self, action: #selector(SimpleAlert.handleButtonTouchUp(_:)), for: UIControl.Event.touchUpOutside)
        if dismissAlertOnTouchUp {
            button.addTarget(self, action: #selector(SimpleAlert.handleButtonTouchUpInside(_:)), for: UIControl.Event.touchUpInside)
        } else {
            button.addTarget(self, action: #selector(SimpleAlert.handleButtonTouchUp(_:)), for: UIControl.Event.touchUpInside)
        }
        buttonsBox.addSubview(button)
        buttons.append(button)

        return button
    }

    // public for being overridden
    @objc open func prepSubviews() {
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

        bringSubviewToFront(topIcon)

        constrainSizeTo(view: superview)

        let titleHeight = title == nil ? 0.0 : self.titleHeight

        box.widthAnchor.constraint(lessThanOrEqualToConstant: boxWidth).activateAndName("simpleAlert.box.width")
        box.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.80).activateAndName("simpleAlert.box.width.vs.enclosing.view", priority: .defaultHigh)

        let multiplerY = showAlertInTopHalf ? 0.5 : 1.0
        box.constrainCenterTo(view: box.superview, multiplierY: multiplerY)

        [box, titleLabel, messageLabel, buttonsBox, textFieldsBox].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        titleLabel.widthAnchor.constraint(equalTo: box.widthAnchor, constant: -(sideMargin * 2)).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: box.centerXAnchor, constant: 0).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true

        messageLabel.widthAnchor.constraint(equalTo: titleLabel.widthAnchor, multiplier: 1.0).isActive = true
        messageLabel.centerXAnchor.constraint(equalTo: box.centerXAnchor, constant: 0).isActive = true

        textFieldsBox.widthAnchor.constraint(equalTo: box.widthAnchor, constant: 0.0).isActive = true
        textFieldsBox.centerXAnchor.constraint(equalTo: box.centerXAnchor, constant: 0.0).isActive = true

        buttonsBox.widthAnchor.constraint(equalTo: box.widthAnchor, constant: 0.0).isActive = true
        buttonsBox.centerXAnchor.constraint(equalTo: box.centerXAnchor, constant: 0.0).isActive = true

        titleLabel.topAnchor.constraint(equalTo: box.topAnchor, constant: topMargin).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: spaceBetweenSections).activateAndName("simpleAlert.messageLabel.topAnchor")

        textFieldsBox.heightAnchor.constraint(equalToConstant: textFieldsBoxHeight).isActive = true
        textFieldsBox.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: spaceBetweenSections).activateAndName("simpleAlert.textFieldsBox.topAnchor")

        let spaceAfterTextFields = textFieldsBoxHeight == 0 ? 0 : spaceBetweenSections * 0.5

        buttonsBox.heightAnchor.constraint(equalToConstant: buttonsBoxHeight).isActive = true
        buttonsBox.topAnchor.constraint(equalTo: textFieldsBox.bottomAnchor, constant: spaceAfterTextFields).isActive = true

        let boxHeightWithoutMessage = {
            var result = topMargin + titleHeight + 2 * self.spaceBetweenSections + spaceAfterTextFields
            result += textFieldsBoxHeight
            result += (buttonsBoxHeight > 0) ? buttonsBoxHeight : self.bottomMarginIfNecessary
            return result
        }()

        box.heightAnchor.constraint(equalTo: messageLabel.heightAnchor, constant: boxHeightWithoutMessage).activateAndName("simpleAlert.box.height")

        for (index, textField) in textFields.enumerated() {
            textField.backgroundColor = textFieldBackgroundColor
            textField.textColor = textFieldTextColor

            if let placeholderText = textField.placeholder {
                textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor: textFieldPlaceholderColor])
            }

            let radiusAndInset = textFieldRowHeight / 8.0
            textField.layer.cornerRadius = radiusAndInset
            let leftBox = UIView(frame: CGRect(x: 0, y: 0, width: radiusAndInset * 2.0, height: 1))
            textField.leftView = leftBox
            textField.leftViewMode = .always
            textField.translatesAutoresizingMaskIntoConstraints = false

            let top = CGFloat(CGFloat(index) * textFieldRowTotalHeight)
            textField.heightAnchor.constraint(equalToConstant: textFieldRowHeight).isActive = true
            textField.widthAnchor.constraint(equalTo: textFieldsBox.widthAnchor, constant: -textFieldInset).isActive = true
            textField.centerXAnchor.constraint(equalTo: textFieldsBox.centerXAnchor, constant: 0).isActive = true
            textField.topAnchor.constraint(equalTo: textFieldsBox.topAnchor, constant: top + textFieldRowVerticalSpace).isActive = true
        }

        for (index, button) in buttons.enumerated() {
            // change button color
            handleButtonTouchUp(button)

            let top = CGFloat(CGFloat(index) * buttonRowTotalHeight)
            button.heightAnchor.constraint(equalToConstant: buttonRowHeight).isActive = true

            button.translatesAutoresizingMaskIntoConstraints = false

            button.heightAnchor.constraint(equalToConstant: buttonRowHeight).isActive = true
            button.widthAnchor.constraint(equalTo: buttonsBox.widthAnchor, constant: -buttonInset).isActive = true
            button.centerXAnchor.constraint(equalTo: buttonsBox.centerXAnchor, constant: 0).isActive = true
            button.topAnchor.constraint(equalTo: buttonsBox.topAnchor, constant: buttonRowVerticalSpace + top).isActive = true
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
        dismiss()
    }

    @objc override open func layoutSubviews() {
        super.layoutSubviews()
        layoutTopIcon()
    }

    func layoutTopIcon() {
        var frame = topIcon.frame
        frame.origin.y = box.frame.origin.y - 0.5 * frame.size.height
        frame.origin.x = 0.5 * (bounds.size.width - frame.size.width)
        topIcon.frame = frame
    }
}

// MARK: - Special UIButton Sub

class ButtonSub: UIButton {
    var handler: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    class func makeButtonSub(_ handler: (() -> Void)?) -> ButtonSub {
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

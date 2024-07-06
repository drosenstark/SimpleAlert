// (c) Confusion Studios LLC and affiliates. Confidential and proprietary.

private let IS_PHONE = (UIDevice.current.userInterfaceIdiom == .phone)

@objc public enum SimpleAlertTheme: Int { case dark, light }

/// SimpleAlert is a simple framework for alerts/dialogs on iOS.
@objc open class SimpleAlert: UIView, UITextFieldDelegate {
    weak static var lastAlert: SimpleAlert?

    private let messageLabel = UILabel()
    private let titleLabel = UILabel()

    // this contains the text fields OR the custom view
    private let middleContainer = UIView()
    private var textFields: [UITextField] = []
    private var middleContainerCustomView: UIView?

    @objc public let box = UIView()
    @objc public let buttonsBox = UIView()
    @objc public var buttons: [UIButton] = []
    @objc public var doNotAutomaticallyEnableTheseButtons: [UIButton] = []

    @objc public var topIcon = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    @objc public var modalBackgroundColor = UIColor.black.withAlphaComponent(0.4)
    @objc public var boxBackgroundColor: UIColor!
    @objc public var buttonsBoxBackgroundColor: UIColor!
    @objc public var titleTextColor: UIColor!
    @objc public var messageTextColor: UIColor!
    @objc public var buttonHighlightColor: UIColor!
    @objc public var buttonsBoxColor: UIColor!

    @objc public var messageLabelTextAlignment = NSTextAlignment.center

    @objc public var topMargin = CGFloat(20.0)
    @objc public var bottomMarginIfNecessary = CGFloat(20.0)
    @objc public var sideMargin = CGFloat(20.0)
    @objc public var spaceBetweenSections = CGFloat(10.0)

    @objc public var textFieldTextColor = UIColor.black
    @objc public var textFieldPlaceholderColor = UIColor.darkGray
    @objc public var textFieldBackgroundColor = UIColor.white
    @objc public var textFieldRowHeight = CGFloat(30.0)
    @objc public var textFieldRowVerticalSpace = CGFloat(1.0)
    @objc public var textFieldInset = CGFloat(10.0)

    @objc public var buttonInset = CGFloat(0.0)
    @objc public var buttonRowVerticalSpace = CGFloat(1.0)

    @objc public var showAlertInTopHalf: Bool = false

    private var showWasAnimated = false

    // working around a shared dependency on other stuff in my own libs
    @objc public var doThisToEveryButton: ((UIButton) -> Void)?

    // MARK: - Sizes

    public var boxWidth: CGFloat = IS_PHONE ? 300 : 350
    public var titleHeight: CGFloat = 30.0
    private var titleFontSize: CGFloat = IS_PHONE ? 17.0 : 19.0
    private var messageFontSize: CGFloat = IS_PHONE ? 15 : 16.5
    private var buttonRowHeight: CGFloat = IS_PHONE ? 37.5 : 45.0
    private var buttonFontSize: CGFloat = IS_PHONE ? 17.0 : 19.0

    // for keyboard notifications
    private var boxOuterConstraints = [NSLayoutConstraint]()
    
    // MARK: - Class Methods

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

    @objc open var attributedTextForMessage: NSAttributedString? {
        didSet {
            messageLabel.attributedText = attributedTextForMessage
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
        guard middleContainerCustomView == nil else {
            fatalError("choose text fields or custom view but not both")
        }

        let textField = UITextField()
        textField.backgroundColor = UIColor.white
        textField.placeholder = placeholder
        textField.isSecureTextEntry = secureEntry
        textField.font = UIFont.systemFont(ofSize: textFieldRowHeight / 3.0 + 4.0)
        textField.delegate = self
        if let handler = changeHandler {
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { notification in
                handler(textField)
            }
        }

        textFields.append(textField)
        middleContainer.addSubview(textField)

        return textField
    }

    // alias
    open func setMiddleContainerCustomView(_ customView: UIView) {
        setCustomView(customView)
    }

    open func setCustomView(_ customView: UIView) {
        guard textFields.count == 0 else {
            fatalError("choose text fields or custom view but not both")
        }

        middleContainerCustomView = customView
        middleContainer.addSubview(customView)
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

        prepSubviews(in: window)

        if animated {
            alpha = 0.0
            UIView.animate(withDuration: 0.5, animations: {
                self.alpha = 1.0
            })
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            
            self.enableButtons()
            self.addKeyboardNotifications()
        }
        showWasAnimated = animated
    }

    @objc open func enableButtons() {
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
            let delay = stopSpinnerAnimationMaybe() ? 0.5 : 0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.removeFromSuperview()
            }
        } else {
            dismissAnimated()
        }
    }

    /// true if there was a spinner to stop
    private func stopSpinnerAnimationMaybe() -> Bool {
        if let middleContainer = middleContainerCustomView as? (UIView & StopAnimatingProtocol) {
            middleContainer.stopAnimating()
            return true
        }
        return false
    }
    
    private func dismissAnimated() {
        let delay = stopSpinnerAnimationMaybe() ? 0.5 : 0
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.dismissAnimatedInner()
        }
    }
    
    private func dismissAnimatedInner() {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0.0
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }

    // MARK: - UITextFieldDelegate Methods

    @objc open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    @objc open func textFieldDidBeginEditing(_ textField: UITextField) {}

    // MARK: - Keyboard notifications to get UITextFields out of the way

    private func addKeyboardNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: .main) { [weak self] notification in
            self?.keyboardDidShow(notification)
        }
        notificationCenter.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: .main) { [weak self] notification in
            self?.keyboardDidHide(notification)
        }
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    var didMoveForKeyboard = false
    
    private func keyboardDidShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else {
            return
        }
        if keyboardFrame.intersects(box.frame) {
            boxOuterConstraints.setToIsActive(false)
            boxOuterConstraints = box.constrainCenterAndTopTo(view: box.superview, marginY: 50)
            didMoveForKeyboard = true
        }
    }

    private func keyboardDidHide(_ notification: Notification) {
        if didMoveForKeyboard {
            boxOuterConstraints.setToIsActive(false)
            setupCenteredMiddleOuterBoxConstraints()
            didMoveForKeyboard = false
        }
    }

    private func setupCenteredMiddleOuterBoxConstraints() {
        let multiplerY = showAlertInTopHalf ? 0.5 : 1.0
        boxOuterConstraints = box.constrainCenterTo(view: box.superview, multiplierY: multiplerY)
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
                textFieldBackgroundColor = UIColor.darkGray
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

        button.adjustFontSize(to: buttonFontSize)
        button.setTitle(text, for: UIControl.State())
        button.setTitleColor(tintColor, for: UIControl.State())
        button.setTitleColor(.gray, for: .disabled)

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
    open func prepSubviews(in window: UIWindow) {
        addSubview(topIcon)
        box.layer.cornerRadius = 10.0
        backgroundColor = modalBackgroundColor
        box.backgroundColor = boxBackgroundColor
        box.clipsToBounds = true
        addSubview(box)

        titleLabel.font = UIFont.boldSystemFont(ofSize: titleFontSize)
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.textColor = titleTextColor
        box.addSubview(titleLabel)

        messageLabel.font = UIFont.systemFont(ofSize: messageFontSize)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = messageLabelTextAlignment
        messageLabel.textColor = messageTextColor
        box.addSubview(messageLabel)

        box.addSubview(middleContainer)
        middleContainer.clipsToBounds = true

        let textFieldRowTotalHeight = textFieldRowHeight + textFieldRowVerticalSpace
        let customMiddleViewGutsHeight: CGFloat
        if let middleContainerCustomView {
            customMiddleViewGutsHeight = middleContainerCustomView.frame.size.height
        } else {
            customMiddleViewGutsHeight = textFieldRowTotalHeight * CGFloat(textFields.count)
        }

        box.addSubview(buttonsBox)
        buttonsBox.backgroundColor = buttonsBoxColor
        buttonsBox.clipsToBounds = true

        let buttonRowTotalHeight = buttonRowHeight + buttonRowVerticalSpace
        let buttonsBoxHeight = buttonRowTotalHeight * CGFloat(buttons.count)

        if let middleContainerCustomView {
            middleContainerCustomView.translatesAutoresizingMaskIntoConstraints = false
            middleContainerCustomView.centerXAnchor.constraint(equalTo: middleContainer.centerXAnchor).isActive = true
            middleContainerCustomView.widthAnchor.constraint(equalTo: middleContainer.widthAnchor, multiplier: 0.9).isActive = true
        }

        bringSubviewToFront(topIcon)

        constrainSizeTo(view: superview)

        let titleHeight = title == nil ? 0.0 : self.titleHeight

        box.widthAnchor.constraint(lessThanOrEqualToConstant: boxWidth).activateAndName("simpleAlert.box.width")
        box.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.80).activateAndName("simpleAlert.box.width.vs.enclosing.view", priority: .defaultHigh)

        setupCenteredMiddleOuterBoxConstraints()

        [box, titleLabel, messageLabel, buttonsBox, middleContainer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        titleLabel.widthAnchor.constraint(equalTo: box.widthAnchor, constant: -(sideMargin * 2)).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: box.centerXAnchor, constant: 0).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true

        messageLabel.widthAnchor.constraint(equalTo: titleLabel.widthAnchor, multiplier: 1.0).isActive = true
        messageLabel.centerXAnchor.constraint(equalTo: box.centerXAnchor, constant: 0).isActive = true

        middleContainer.widthAnchor.constraint(equalTo: box.widthAnchor, constant: 0.0).isActive = true
        middleContainer.centerXAnchor.constraint(equalTo: box.centerXAnchor, constant: 0.0).isActive = true

        buttonsBox.widthAnchor.constraint(equalTo: box.widthAnchor, constant: 0.0).isActive = true
        buttonsBox.centerXAnchor.constraint(equalTo: box.centerXAnchor, constant: 0.0).isActive = true

        titleLabel.topAnchor.constraint(equalTo: box.topAnchor, constant: topMargin).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: spaceBetweenSections).activateAndName("simpleAlert.messageLabel.topAnchor")

        middleContainer.heightAnchor.constraint(equalToConstant: customMiddleViewGutsHeight).isActive = true
        middleContainer.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: spaceBetweenSections).activateAndName("simpleAlert.textFieldsBox.topAnchor")

        let spaceAfterTextFields: CGFloat = {
            if customMiddleViewGutsHeight == 0 {
                return buttons.count > 0 ? 10 : 0
            } else {
                return spaceBetweenSections * 0.5
            }
        }()

        buttonsBox.heightAnchor.constraint(equalToConstant: buttonsBoxHeight).isActive = true
        buttonsBox.topAnchor.constraint(equalTo: middleContainer.bottomAnchor, constant: spaceAfterTextFields).isActive = true

        let boxHeightWithoutMessage = {
            var result = topMargin + titleHeight + 2 * self.spaceBetweenSections + spaceAfterTextFields
            result += customMiddleViewGutsHeight
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
            textField.widthAnchor.constraint(equalTo: middleContainer.widthAnchor, constant: -textFieldInset).isActive = true
            textField.centerXAnchor.constraint(equalTo: middleContainer.centerXAnchor, constant: 0).isActive = true
            textField.topAnchor.constraint(equalTo: middleContainer.topAnchor, constant: top + textFieldRowVerticalSpace).isActive = true
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

    @objc private func handleButtonTouch(_ button: UIButton) {
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

fileprivate class ButtonSub: UIButton {
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

// MARK: - Util

private extension CGSize {
    var longestSide: CGFloat {
        return max(width, height)
    }
}

private extension UIButton {
    func adjustFontSize(to newFontSize: CGFloat) {
        guard let font = titleLabel?.font else { return }

        titleLabel?.font = UIFont(descriptor: font.fontDescriptor, size: newFontSize)
    }
}

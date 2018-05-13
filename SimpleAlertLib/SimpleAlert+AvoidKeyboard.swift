import UIKit

extension SimpleAlert {
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc open func keyboardDidShow(_ notification: Notification) {
        constrainBox(toTopQuarter: true)
        animateForKeyboard(with: notification)
    }
    
    @objc open func keyboardDidHide(_ notification: Notification) {
        constrainBox(toTopQuarter: showAlertInTopHalf)
        animateForKeyboard(with: notification)
    }
    
    func animateForKeyboard(with notification: Notification) {
        let userInfo = notification.userInfo
        var animationOptions: UIViewAnimationOptions = []
        animationOptions.insert(.curveEaseInOut)
        
        var animationDuration: TimeInterval = 0.0
        
        if let animationDurationFromUserInfo = userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            animationDuration = animationDurationFromUserInfo
        }
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: animationOptions, animations: {
            self.layoutIfNeeded()
        })
    }
}


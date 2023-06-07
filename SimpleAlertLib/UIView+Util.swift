// (c) Confusion Studios LLC and affiliates. Confidential and proprietary.

import UIKit

extension UIView {
    func constrainCenterTo(view: UIView?, multiplierY: CGFloat = 1.0, multiplierX: CGFloat = 1.0) {
        guard let view else { return }

        NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerX, multiplier: multiplierX, constant: 0).activateAndName("simpleAlert.box.centerX")
        NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .centerY, multiplier: multiplierY, constant: 0).activateAndName("simpleAlert.box.centerY")
    }

    func constrainSizeTo(view: UIView?, multiplierY: CGFloat = 1.0, multiplierX: CGFloat = 1.0) {
        guard let view else { return }

        NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .width, multiplier: multiplierX, constant: 0).activateAndName("simpleAlert.box.width")
        NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .height, multiplier: multiplierY, constant: 0).activateAndName("simpleAlert.box.height")
    }
}

extension NSLayoutConstraint {
    func activateAndName(_ name: String, priority: UILayoutPriority? = nil) {
        if let priority {
            self.priority = priority
        }
        identifier = name
        isActive = true
    }
}

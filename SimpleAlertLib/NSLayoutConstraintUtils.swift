// (c) Confusion Studios LLC and affiliates. Confidential and proprietary.

import UIKit

extension NSLayoutConstraint {
    @discardableResult
    func activateAndName(_ name: String, priority: UILayoutPriority? = nil) -> NSLayoutConstraint {
        if let priority {
            self.priority = priority
        }
        identifier = name
        isActive = true
        return self
    }
}

extension Array where Element == NSLayoutConstraint {
    func setToIsActive(_ isActive: Bool) {
        for constraint in self {
            constraint.isActive = isActive
        }
    }
    
}

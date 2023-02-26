// (c) Confusion Studios LLC and affiliates. Confidential and proprietary.

import UIKit

extension UIView {
    func constrainCenter(to view: UIView, multiplierY: CGFloat = 1.0, multiplierX: CGFloat = 1.0) {
        centerXAnchor.constraint(equalToSystemSpacingAfter: view.centerXAnchor, multiplier: multiplierX).isActive = true
        centerYAnchor.constraint(equalToSystemSpacingBelow: view.centerYAnchor, multiplier: multiplierY).isActive = true
    }
    
    func constrainSize(to view: UIView, multiplierY: CGFloat = 1.0, multiplierX: CGFloat = 1.0) {
        widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplierX).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: multiplierY).isActive = true
    }

}

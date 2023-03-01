// (c) Confusion Studios LLC and affiliates. Confidential and proprietary.

import UIKit

public extension UIView {
    func constrainCenterTo(view: UIView?, multiplierY: CGFloat = 1.0, multiplierX: CGFloat = 1.0) {
        guard let view else { return }

        centerXAnchor.constraint(equalToSystemSpacingAfter: view.centerXAnchor, multiplier: multiplierX).isActive = true
        centerYAnchor.constraint(equalToSystemSpacingBelow: view.centerYAnchor, multiplier: multiplierY).isActive = true
    }
    
    func constrainSizeTo(view: UIView?, multiplierY: CGFloat = 1.0, multiplierX: CGFloat = 1.0) {
        guard let view else { return }
        
        widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplierX).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: multiplierY).isActive = true
    }

}

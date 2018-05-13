import Foundation

class SimpleAlertButton : UIButton {

    convenience init(_ handler: (()->())?) {
        self.init(type: .custom)
        self.handler = handler
        addTarget(self, action: #selector(callHandler), for: .touchUpInside)
        isEnabled = false
    }
    
    var handler: (()->())?

    @objc private func callHandler() {
        handler?()
    }
}

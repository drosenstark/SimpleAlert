# SimpleAlert
Looks like UIAlertController, pretty much, but from the client side it's a bit different.

Huge advantage: it shows in a `UIWindow` directly, so it can show above a `UIViewController` that's showing modally.

![Example Dark](http://dr2050.com/automatic-images/SimpleAlertDark.png)
![Example Light](http://dr2050.com/automatic-images/SimpleAlertLight.png)


## Example Code

```swift
let alert = SimpleAlert(title: "Very Simple", message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec quam quam, posuere eu diam ut, imperdiet bibendum magna. Integer ut luctus enim, vel fermentum enim. Aenean elementum cursus metus, sit amet\n\niaculis tellus suscipit ac. Cras nec ex in ex auctor convallis. Nullam fermentum quam nibh, eget iaculis sapien eleifend eu. Proin arcu diam, laoreet non egestas nec, bibendum non neque.\n\nAre you really sure you want to do this?")
alert.addButtonWithTitle("I'm insane!") {
    print("yeah I'm out of my head")
}
alert.addButtonWithTitle("Show me another Alert") {
    let alert2 = SimpleAlert.makeAlert("Another Alert", message: "Different theme, get it?");
    alert2.addButtonWithTitle("OK", block: {
        print("Okay")
    })
    alert2.theme = .Light
    alert2.showInWindow(self.view.window!)

}

alert.addButtonWithTitle("Never Ask Me Again") {
    print("user doesn't want to be asked again")
}

alert.showInWindow(self.view.window!)
```

### Example with Text Entry Fields

![Example Text Field Entry](http://dr2050.com/automatic-images/SimpleAlertUsernamePass.png)

```swift
let alert = SimpleAlert.makeAlert("Another Alert", message: "You could fill out these boxes.");
let username = alert.addTextFieldWithPlaceholder("Username", secureEntry: false, changeHandler: { (textField) in
    print("typing!")
})
alert.addTextFieldWithPlaceholder("Pass", secureEntry: true, changeHandler: nil)
alert.addButtonWithTitle("OK", block: {
    print("Okay pressed, username is: \(username.text!)")
})
alert.addButtonWithTitle("Cancel", block: {})
alert.theme = useLight ? .Light : .Dark
alert.showInWindow(self.view.window!)
```



## With Objective-C

Works perfectly well from Objective-C too, but **note**:
- Enum is called `SimpleAlertTheme`
- Enums are called `SimpleAlertThemeDark` and `SimpleAlertThemeLight`

## Using with Carthage

Put this in your Cartfile

`github "drosenstark/SimpleAlert" "master"`

and make sure to:
1. Update using `carthage update --platform iOS`
1. Add the framework to your copy-frameworks, something like `$(SRCROOT)/Carthage/Build/iOS/SimpleAlertLib.framework`


## Dependencies!

Requires Carthage (to get Cartography). Run

`carthage update --platform iOS`

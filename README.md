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
    let alert2 = SimpleAlert(title:"Another Alert", message: "Different theme, get it?");
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

## With Objective-C

Works perfectly well from Objective-C too, but **note**:
- Enum is called `SimpleAlertTheme`
- Enums are called `SimpleAlertThemeDark` and `SimpleAlertThemeLight`

## Dependencies!

You'll need [Cartography](https://github.com/robb/Cartography). Just run:

1. git submodule init
2. git submodule update

And that's it!

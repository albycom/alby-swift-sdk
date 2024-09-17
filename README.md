[![CocoaPods](https://img.shields.io/badge/platforms-iOS-orange.svg?maxAge=2592000)](https://cocoapods.org/pods/AlbyWidget)
[![Languages](https://img.shields.io/badge/languages-OjbC%20%7C%20%20Swift-orange.svg?maxAge=2592000)](https://github.com/albycom/alby_widget_ios)
[![CocoaPods](https://img.shields.io/cocoapods/v/alby_widget_ios.svg?maxAge=2592000)](https://cocoapods.org/pods/AlbyWidget)
[![Apache License](http://img.shields.io/badge/license-APACHE2-blue.svg?style=flat)](https://www.apache.org/licenses/LICENSE-2.0.html)


## Installation

AlbyWidget for iOS supports iOS 15+. 
Xcode 15 is required to build Alby iOS SDK.

### CocoaPods
Cocoapods 1.11.0 is required to install AlbyWidget.
Add the AlbyWidget pod into your Podfile and run `pod install`.
```ruby
    target :YourTargetName do
      pod 'AlbyWidget'
    end
```


### Swift Package Manager
Add `https://github.com/albycom/alby_widget_ios` as a Swift Package Repository in Xcode and follow the instructions to add `AlbyWidget` as a Swift Package.


## Setup and Configuration
This SDK only works with SwiftUI.

1. Make sure you have an Alby account - if you don't, go to https://alby.com and create one.
2. Get your brand id
3. Import the alby widget `import AlbyWidget`
3. Go to the SwiftUI View where you want to place the widget and after everything just add
```
.addAlbyWidget(productId: "your product id", brandId: "your-brand-id")
```

The default placement will be in the bottom of the screen. If you have a bottom bar or something similar, make sure you add a bottom
offset. In the example below we are moving the alby bottom sheet 50 points upwards.

```
.addAlbyWidget(productId: product.albyProductId, brandId: "017d2e91-58ee-41e4-a3c9-9cee17624b31", bottomOffset: 50)
```


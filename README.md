[![Languages](https://img.shields.io/badge/languages-OjbC%20%7C%20%20Swift-orange.svg?maxAge=2592000)](https://github.com/albycom/alby_widget_ios)
[![Apache License](http://img.shields.io/badge/license-APACHE2-blue.svg?style=flat)](https://www.apache.org/licenses/LICENSE-2.0.html)
![GitHub Tag](https://img.shields.io/github/v/tag/albycom/alby_widget_ios)


## Installation

AlbyWidget for iOS supports iOS 15+. 
Xcode 15 is required to build Alby iOS SDK.

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

### Possible issues
Depending on how your view is structured the keyboard inside the bottom sheet might not work as expected.
Make sure that you place the widget inside a ScrollView so the keyboard can scroll and the content be displayed.

### Example
```swift
struct HomeView: View {
    @State var productId = "my-product-id"
    @State var brandId = "my-brand-id"
    @State private var reloadView = false

    @State var widgetProductId = "my-product-id"
    @State var widgetBrandId = "my-brand-id"
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Product ID")
                TextField("Product ID", text: $productId)
                    .font(.title3)
                    .foregroundColor(.purple)
                    .padding()
                    .background(.yellow.opacity(0.2))
                    .cornerRadius(10)
                Text("Brand ID")
                TextField("Brand ID", text: $brandId)
                    .font(.title3)
                    .foregroundColor(.purple)
                    .padding()
                    .background(.yellow.opacity(0.2))
                    .cornerRadius(10)
                Button(action: {
                    // Update the widget values when the button is pressed
                    widgetProductId = productId
                    widgetBrandId = brandId
                }) {
                    Text("Update Widget")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Button(action: {
                    // Toggle reloadView to force a view reload
                    reloadView.toggle()
                }) {
                    Text("Reload View")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .addAlbyWidget(productId: $widgetProductId.wrappedValue, brandId: $widgetBrandId.wrappedValue, bottomOffset: 1)
            .background(Color(UIColor.white))
            .id(reloadView)
        
    }
}
```

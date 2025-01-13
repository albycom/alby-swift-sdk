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

## Prerequisites 
1. Make sure you have an Alby account - if you don't, go to https://alby.com and create one.
2. Get your brand id - this is an organization id that represents your brand
3. Get your widget id = this is a unique id that you can get in the widgets embed page inside the alby UI.
4. Import the alby widget `import AlbyWidget`

## Components

### addAlbyWidget
The `addAlbyWidget` function displays the Alby widget inside a sheet (modal). This is ideal for cases where you want the widget to appear in an overlay or pop-up format, giving users the option to engage with the widget without leaving the current screen.

Go to the SwiftUI View where you want to place the widget and after everything just add
```
.addAlbyWidget(productId: "your product id", brandId: "your-brand-id", widgetId: "your-widget-id")
```

The default placement will be in the bottom of the screen. If you have a bottom bar or something similar, make sure you add a bottom
offset. In the example below we are moving the alby bottom sheet 50 points upwards.

```
.addAlbyWidget(productId: "123", brandId: "456", widgetId: "789", bottomOffset: 50)
```

#### Possible issues
Depending on how your view is structured the keyboard inside the bottom sheet might not work as expected.
Make sure that you place the widget inside a ScrollView so the keyboard can scroll and the content be displayed.

#### Example Usage
```swift
struct HomeView: View {
    @State var productId = "my-product-id"
    @State var brandId = "my-brand-id"
    @State var widgetId = "my-widget-id"
    @State private var reloadView = false

    @State var widgetProductId = "my-product-id"
    @State var widgetBrandId = "my-brand-id"
    @State var widgetWidgetId = "my-widget-id"
    
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
                Text("Widget ID")
                TextField("Widget ID", text: $widgetId)
                    .font(.title3)
                    .foregroundColor(.purple)
                    .padding()
                    .background(.yellow.opacity(0.2))
                    .cornerRadius(10)
                Button(action: {
                    // Update the widget values when the button is pressed
                    widgetWidgetId = widgetId
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
        .addAlbyWidget(productId: $widgetProductId.wrappedValue, brandId: $widgetBrandId.wrappedValue, brandId: $widgetWidgetId.wrappedValue, bottomOffset: 1)
            .background(Color(UIColor.white))
            .id(reloadView)
        
    }
}
```
### AlbyInlineWidgetView
The `AlbyInlineWidgetView` is a component that allows embedding the Alby widget directly into your app's UI. It’s perfect for inline use on any page, like product details or brand-specific screens, where the widget integrates seamlessly within the existing view hierarchy.

In the SwiftUI View where you want to place the widget, add the AlbyInlineWidgetView component and pass in the required brandId, productId and widgetId parameters:
```
AlbyInlineWidgetView(
    brandId: "your brand id",
    productId: "your product id",
    widgetId: "your widget id"
)
```

#### Example Usage
```swift
VStack(spacing: 16) {
    AlbyInlineWidgetView(
        brandId: "your brand id",
        productId: "your product id",
        widgetId: "your widget id"
    )
    .padding(24)
}
.padding()
```

//
//  AlbyInlineWidgetView.swift
//  AlbyWidget
//
//  Created by Jason Deng on 10/8/24.
//

import SwiftUI

/// A SwiftUI view that displays the Alby Inline Widget.
/// This widget allows embedding the Alby generative QA component with a specific `productId`, `brandId` and `widgetId`
/// into your SwiftUI applications.
///
/// You can pass the `productId`, `brandId`,  `widgetId` to customize the widget for specific contexts.
///
/// ## Example Usage
/// ```swift
/// AlbyInlineWidgetView(productId: "123", brandId: "456", widgetId: "789")
/// ```
///
/// This will create a web-based view displaying the widget with the given `productId`, `brandId` and `widgetId`.
///
public struct AlbyInlineWidgetView: View {
    public let productId: String
    public let brandId: String
    public let widgetId: String
    
    public init(productId: String, brandId: String, widgetId: String) {
        self.productId = productId
        self.brandId = brandId
        self.widgetId = widgetId
    }

    @StateObject var viewModel = WebViewModel()

    public var body: some View {
        SwiftWebView(url: URL(string: "https://cdn.alby.com/assets/alby_widget.html?useBrandStyling=false&brandId=\(brandId)&productId=\(productId)&widgetId=\(widgetId)"), isScrollEnabled: true, viewModel: viewModel)
    }
}

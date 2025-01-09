//
//  AlbyInlineWidgetView.swift
//  AlbyWidget
//
//  Created by Jason Deng on 10/8/24.
//

import SwiftUI

/// A SwiftUI view that displays the Alby Inline Widget.
/// This widget allows embedding the Alby generative QA component with a specific `productId` and `brandId`
/// into your SwiftUI applications.
///
/// You can pass the `productId` and `brandId` to customize the widget for specific product and brand contexts.
///
/// ## Example Usage
/// ```swift
/// AlbyInlineWidgetView(productId: "123", brandId: "456")
/// ```
///
/// This will create a web-based view displaying the widget with the given `productId` and `brandId`.
///
public struct AlbyInlineWidgetView: View {
    public let productId: String
    public let brandId: String
    
    public init(productId: String, brandId: String) {
        self.productId = productId
        self.brandId = brandId
    }

    @StateObject var viewModel = WebViewModel()

    public var body: some View {
        SwiftWebView(url: URL(string: "https://cdn.alby.com/assets/alby_widget.html?component=alby-generative-qa&useBrandStyling=false&brandId=\(brandId)&productId=\(productId)"), isScrollEnabled: true, viewModel: viewModel)
    }
}

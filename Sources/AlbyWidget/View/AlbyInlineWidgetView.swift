//
//  AlbyInlineWidgetView.swift
//  AlbyWidget
//
//  Created by Jason Deng on 10/8/24.
//

import SwiftUI

/// A SwiftUI view that displays the alby Inline Widget.
/// This widget allows embedding the alby Generative QA component with a specific `productId`, `brandId` and `widgetId`
/// into your SwiftUI applications.
///
/// You can pass the `productId`, `brandId` and `widgetId` to customize the widget for specific product and brand contexts.
/// You can also pass the `testId`, `testVersion` and `testDescription` to customize the widget for A/B testing.
///
/// ## Example Usage
/// ```swift
/// AlbyInlineWidgetView(productId: "123", brandId: "456", widgetId: "789")
/// ```
///
/// This will create a web-based view displaying the widget with the given `productId`, `brandId` and `widgetId`.
///
public struct AlbyInlineWidgetView: View {
  let brandId: String
  let productId: String
  let widgetId: String?
  let testId: String?
  let testVersion: String?
  let testDescription: String?
  let viewModel: AlbyWidgetViewModel

  public init(productId: String, brandId: String, widgetId: String? = nil, testId: String? = nil, testVersion: String? = nil, testDescription: String? = nil) {
    self.productId = productId
    self.brandId = brandId
    self.widgetId = widgetId
    self.testId = testId
    self.testVersion = testVersion
    self.testDescription = testDescription
    self.viewModel = AlbyWidgetViewModel()
  }

  public var body: some View {
    // Break down URL construction into smaller parts
    let baseUrl = "https://cdn.alby.com/assets/alby_widget.html"
    let requiredParams = "component=alby-generative-qa&brandId=\(brandId)&productId=\(productId)"
    
    // Optional parameters
    var optionalParams = ""
    if let widgetId {
      optionalParams += "&widgetId=\(widgetId)"
    }
    if let testId {
      optionalParams += "&testId=\(testId)"
    }
    if let testVersion {
      optionalParams += "&testVersion=\(testVersion)"
    }
    if let testDescription {
      optionalParams += "&testDescription=\(testDescription)"
    }
    
    // Combine all parts
    let finalUrl = "\(baseUrl)?\(requiredParams)\(optionalParams)"
    
    return SwiftWebView(
      url: URL(string: finalUrl)!,
      isScrollEnabled: false,
      viewModel: viewModel
    )
  }
}

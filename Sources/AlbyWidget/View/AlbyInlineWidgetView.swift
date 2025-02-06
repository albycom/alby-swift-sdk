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
  public let productId: String
  public let brandId: String
  public let widgetId: String
  public let testId: String?
  public let testVersion: String?
  public let testDescription: String?

  public init(productId: String, brandId: String, widgetId: String, testId: String? = nil, testVersion: String? = nil, testDescription: String? = nil) {
    self.productId = productId
    self.brandId = brandId
    self.widgetId = widgetId
    self.testId = testId
    self.testVersion = testVersion
    self.testDescription = testDescription
  }

  @StateObject var viewModel = WebViewModel()

  public var body: some View {
    // Break down URL construction into smaller parts
    let baseUrl = "https://cdn.alby.com/assets/alby_widget.html"
    let requiredParams = "brandId=\(brandId)&productId=\(productId)"
    
    // Optional parameters
    var optionalParams = ""
    if let widgetId = widgetId {
      optionalParams += "&widgetId=\(widgetId)"
    }
    if let testId = testId {
      optionalParams += "&testId=\(testId)"
    }
    if let testVersion = testVersion {
      optionalParams += "&testVersion=\(testVersion)"
    }
    if let testDescription = testDescription {
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

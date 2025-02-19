//
//  AlbyInlineWidgetView.swift
//  AlbyWidget
//
//  Created by Jason Deng on 10/8/24.
//

import SwiftUI

/// A SwiftUI view that displays the alby Inline Widget.
/// This widget allows embedding the alby Generative QA component with a specific `productId` and `widgetId`
/// into your SwiftUI applications.
///
/// You can pass the `productId` and `widgetId` to customize the widget for specific product and widget contexts.
/// You can also pass the `testId`, `testVersion` and `testDescription` to customize the widget for A/B testing.
///
/// ## Example Usage
/// ```swift
/// AlbyInlineWidgetView(productId: "123", widgetId: "789")
/// ```
///
/// This will create a web-based view displaying the widget with the given `productId` and `widgetId`.
///
public struct AlbyInlineWidgetView: View {
  public let productId: String
  public let widgetId: String
  public let threadId: String?
  public let testId: String?
  public let testVersion: String?
  public let testDescription: String?

  public init(productId: String, widgetId: String, threadId: String? = nil, testId: String? = nil, testVersion: String? = nil, testDescription: String? = nil) {
    self.productId = productId
    self.widgetId = widgetId
    self.threadId = threadId
    self.testId = testId
    self.testVersion = testVersion
    self.testDescription = testDescription
  }

  @StateObject var viewModel = WebViewModel()

  public var body: some View {
    SwiftWebView(
      url: URL(
        string:
          "https://cdn.alby.com/assets/alby_widget.html?component=alby-generative-qa&brandId=\(AlbySDK.shared.brandId)&productId=\(productId)&widgetId=\(widgetId)\(threadId != nil ? "&threadId=\(threadId!)" : "")\(testId != nil ? "&testId=\(testId!)" : "")\(testVersion != nil ? "&testVersion=\(testVersion!)" : "")\(testDescription != nil ? "&testDescription=\(testDescription!)" : "")"
      ), isScrollEnabled: true, viewModel: viewModel)
  }
}
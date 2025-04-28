//
//  AlbyInlineWidgetView.swift
//  AlbyWidget
//
//  Created by Jason Deng on 10/8/24.
//

import SwiftUI
import WebKit

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
  @State private var isLoading = true

  public var body: some View {
    let brandId = AlbySDK.shared.brandId ?? ""
    
    let urlString = "https://cdn.alby.com/assets/alby_widget.html?component=alby-generative-qa&brandId=\(brandId)&productId=\(productId)&widgetId=\(widgetId)\(threadId != nil ? "&threadId=\(threadId!)" : "")\(testId != nil ? "&testId=\(testId!)" : "")\(testVersion != nil ? "&testVersion=\(testVersion!)" : "")\(testDescription != nil ? "&testDescription=\(testDescription!)" : "")&autoScroll=true"
    
    GeometryReader { geometry in
      ZStack {
        SwiftWebView(
          url: URL(string: urlString),
          isScrollEnabled: true,
          viewModel: viewModel)
          .frame(height: geometry.size.height)
        
        if isLoading {
          ProgressView()
            .scaleEffect(1.5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white.opacity(0.8))
        }
      }
      .frame(minHeight: isLoading ? 200 : geometry.size.height)
      .onReceive(viewModel.callbackValueJS) { event in
        if event == "widget-rendered" || event == "widget-empty" {
          isLoading = false
        }
      }
    }
  }
}

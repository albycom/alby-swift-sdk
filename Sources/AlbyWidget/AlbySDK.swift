//
//  AlbySDK.swift
//
//  Created by Jason Deng on 1/15/25.
//

import Foundation
import WebKit

public class AlbySDK {
  public static let shared = AlbySDK()  // Singleton instance

  private(set) public var brandId: String?
  private var isInitialized = false
  private let client = URLSession.shared
  private let analyticsEndpoint = "https://app.alby.net/analytics-service/v1/api/track"
  private let cookieDomain = "cdn.alby.com"
  private var webView: WKWebView?

  public init() {}

  public func initialize(brandId: String) {
    guard !isInitialized else {
      print("AlbySDK is already initialized.")
      return
    }
    self.brandId = brandId

    // Create a hidden WKWebView instance
    let configuration = WKWebViewConfiguration()
    let preferences = WKWebpagePreferences()
    preferences.allowsContentJavaScript = true
    configuration.defaultWebpagePreferences = preferences

    let webView = WKWebView(frame: .zero, configuration: configuration)
    webView.isHidden = true
    self.webView = webView

    // Load the Alby JS in the background
    if let url = URL(string: "https://cdn.alby.com/assets/alby_widget.html?brandId=\(brandId)") {
      let request = URLRequest(url: url)
      webView.load(request)
    }

    isInitialized = true
    print("AlbySDK initialized successfully.")
  }

  public func sendPurchasePixel(orderId: Any, orderTotal: Any, productIds: [Any], currency: String) {
    guard isInitialized else {
      print("AlbySDK has not been initialized. Please call `initialize(brandId)` first.")
      return
    }

    guard brandId != nil else {
      print("AlbySDK is missing brandId. Ensure `initialize` is called and brandId is set.")
      return
    }

    retrieveCookies { [weak self] cookies in
      guard let self = self else { return }

      let orderInfo: [String: String] = [
        "brand_id": self.brandId ?? "",
        "order_id": String(describing: orderId),
        "order_total": String(describing: orderTotal),
        "product_ids": productIds.map { String(describing: $0) }.joined(separator: ","),
        "currency": currency
      ]

      let queryString = orderInfo.map { key, value in
        "\(key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
      }.joined(separator: "&")

      let baseUrl = "https://tr.alby.com/p?\(queryString)"
      let finalUrl = cookies["_alby_user"].map { baseUrl + "&user_id=\($0)" } ?? baseUrl

      Task { [finalUrl] in
        await self.performRequest(url: finalUrl)
      }
    }
  }

  public func sendAddToCartEvent(price: Any, variantId: String, currency: String, quantity: Any) {
    guard isInitialized else {
      print("AlbySDK has not been initialized. Please call `initialize(brandId)` first.")
      return
    }

    guard brandId != nil else {
      print("AlbySDK is missing brandId. Ensure `initialize` is called and brandId is set.")
      return
    }

    retrieveCookies { [weak self] cookies in
      guard let self = self else { return }

      let payload: [String: Any] = [
        "brand_id": self.brandId ?? "",
        "event_type": "Click:AddToCart",
        "properties": [
          "price": String(describing: price),
          "variant_id": variantId,
          "currency": currency,
          "quantity": String(describing: quantity)
        ],
        "context": [
          "locale": Locale.current.identifier,
          "source": "ios-sdk"
        ],
        "event_timestamp": Date().timeIntervalSince1970,
        "user_id": cookies["_alby_user"] ?? ""
      ]

      Task { [payload] in
        await self.performRequest(url: self.analyticsEndpoint, method: "POST", requestBody: payload)
      }
    }
  }

  private func retrieveCookies(completion: @escaping ([String: String]) -> Void) {
    webView?.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
      // Filter cookies for the hardcoded domain
      let filteredCookies = cookies.filter { $0.domain.contains(self.cookieDomain) }
      let cookieDict = filteredCookies.reduce(into: [String: String]()) { dict, cookie in
        dict[cookie.name] = cookie.value
      }
      completion(cookieDict)
    }
  }

  private func performRequest(url: String, method: String = "GET", requestBody: Any? = nil) async {
    guard let requestUrl = URL(string: url) else {
      print("Invalid URL")
      return
    }

    var request = URLRequest(url: requestUrl)
    request.httpMethod = method

    if method.uppercased() == "POST", let body = requestBody {
      do {
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      } catch {
        print("Failed to encode request body: \(error)")
        return
      }
    }

    do {
      let (_, response) = try await client.data(for: request)
      if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
        print("alby Success: \(httpResponse.statusCode)")
      } else {
        print("alby Error: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
      }
    } catch {
      print("Request failed: \(error)")
    }
  }
}

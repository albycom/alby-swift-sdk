//
//  AlbyPurchasePixel.swift
//  AlbyWidget
//
//  Created by Jason Deng on 1/15/25.
//

import Foundation
import WebKit

class AlbySDK {
    private var brandId: String?
    private var isInitialized = false
    private let client = URLSession.shared
    private let analyticsEndpoint = "https://eks.alby.com/analytics-service/v1/api/track"
    private let cookieDomain = "https://cdn.alby.com"
    private var webView: WKWebView
    
    init() {}
    
    func initialize(brandId: String) {
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
        
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        self.webView.isHidden = true
        
        // Load the Alby JS in the background
        if let url = URL(string: "https://cdn.alby.com/assets/alby_widget.html?brandId=\(brandId)") {
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
        
        isInitialized = true
    }
    
    func sendPurchasePixel(orderId: Any, orderTotal: Any, productIds: [Any], currency: String) {
        ensureInitialized()
        
        let orderInfo: [String: String] = [
            "brand_id": brandId ?? "",
            "order_id": String(describing: orderId),
            "order_total": String(describing: orderTotal),
            "product_ids": productIds.map { String(describing: $0) }.joined(separator: ","),
            "currency": currency
        ]
        
        let queryString = orderInfo.map { key, value in
            "\(key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        }.joined(separator: "&")
    
        retrieveCookies { cookies in
            var finalUrl = "https://tr.alby.com/p?\(queryString)"

            if let userId = cookies["_alby_user"] {
                finalUrl += "&user_id=\(userId)"
            }
            
            Task { [weak self] in
                guard let self = self else { return }
                await self.performRequest(url: finalUrl)
            }
        }
    }
    
    func sendAddToCartEvent(price: String, variantId: String, currency: String, quantity: String) {
        ensureInitialized()
        
        retrieveCookies { cookies in            
            var payload: [String: Any] = [
                "brand_id": brandId ?? "",
                "event_type": "Click:AddToCart",
                "properties": [
                    "price": price,
                    "variant_id": variantId,
                    "currency": currency,
                    "quantity": quantity
                ],
                "context": [
                    "locale": Locale.current.identifier,
                    "source": "ios-sdk"
                ],
                "event_timestamp": Date().timeIntervalSince1970
            ]
            
            if let userId = cookies["_alby_user"] {
                payload["user_id"] = userId
            }
            
            Task { [weak self] in
                guard let self = self else { return }
                await self.performRequest(url: analyticsEndpoint, method: "POST", requestBody: payload)
            }
        }
    }
    
    private func retrieveCookies(completion: @escaping ([String: String]) -> Void) {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            // Filter cookies for the hardcoded domain
            let filteredCookies = cookies.filter { $0.domain.contains(self.cookieDomain) }
            let cookieDict = filteredCookies.reduce(into: [String: String]()) { dict, cookie in
                dict[cookie.name] = cookie.value
            }
            completion(cookieDict)
        }
    }
    
    private func ensureInitialized() {
        guard isInitialized else {
            fatalError("AlbySDK has not been initialized. Please call `initialize(brandId)` first.")
        }
        guard brandId != nil else {
            fatalError("Missing brandId. Ensure `initialize` is called and brandId is set.")
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
            let (data, response) = try await client.data(for: request)
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

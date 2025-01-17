//
//  AlbyPurchasePixel.swift
//  AlbyWidget
//
//  Created by Jason Deng on 1/15/25.
//

import Foundation
import WebKit

public struct AlbyPurchasePixel {
    private let baseURL = "https://tr.alby.com/p"
    private let cookieDomain = "cdn.alby.com"
    private let session = URLSession.shared
    private var webView: WKWebView

    public init() {
        // Create a hidden WKWebView instance
        let configuration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: configuration)
    }

    public func sendPurchasePixel(
        brandId: String,
        orderId: Any,
        orderTotal: Any,
        productIds: [Any],
        currency: String
    ) {
        let orderInfo = [
            "brand_id": brandId,
            "order_id": "\(orderId)",
            "order_total": "\(orderTotal)",
            "product_ids": productIds.map { "\($0)" }.joined(separator: ","),
            "currency": currency
        ]

        guard let queryString = orderInfo.map({ "\($0.key)=\($0.value)" }).joined(separator: "&").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error creating query string")
            return
        }

        retrieveCookies { cookies in
            var finalUrl = "\(self.baseURL)?\(queryString)"

            if let userId = cookies["_alby_user"] {
                finalUrl += "&user_id=\(userId)"
            }

            self.performRequest(urlString: finalUrl)
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

    private func performRequest(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Alby Purchase Pixel Error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Alby Purchase Pixel Response code: \(httpResponse.statusCode)")
            }
        }.resume()
    }
}

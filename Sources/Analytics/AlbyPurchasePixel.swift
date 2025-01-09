//
//  AlbyPurchasePixel.swift
//  AlbyWidget
//
//  Created by Jason Deng on 1/9/25.
//

import Foundation
import WebKit

public class AlbyPurchasePixel: NSObject {

    private var webView: WKWebView

   public override init() {
       // Create a hidden WKWebView
       let configuration = WKWebViewConfiguration()
       self.webView = WKWebView(frame: .zero, configuration: configuration)
       super.init()
   }
    
    public func sendPurchasePixel(
        brandId: String,
        orderId: Any,
        orderTotal: Any,
        productIds: [Any],
        currency: String
    ) {
        // Define the order info dictionary
        let orderInfo: [String: String] = [
            "brand_id": brandId,
            "order_id": String(orderId),
            "order_total": String(orderTotal),
            "product_ids": productIds.map { String(describing: $0) }.joined(separator: ","),
            "currency": currency
        ]

        // Construct the query string from the dictionary
        let queryString = orderInfo.compactMap { key, value in
            if !value.isEmpty {
                return "\(key)=\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            }
            return nil
        }.joined(separator: "&")

        // JavaScript to retrieve cookies from the WebView
        let cookieScript = "document.cookie"

        webView.evaluateJavaScript(cookieScript) { [weak self] result, error in
            guard let self = self else { return }
            if let cookies = result as? String {
                // Parse the cookies to extract session and user_id
                let cookieDictionary = cookies.split(separator: ";").reduce(into: [String: String]()) { dict, cookie in
                    let parts = cookie.split(separator: "=", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
                    if parts.count == 2 {
                        dict[parts[0]] = parts[1]
                    }
                }

                var finalUrl = "https://tr.alby.com/p?\(queryString)"

                if let session = cookieDictionary["_alby_session"] {
                    finalUrl += "&session=\(session)"
                }
                if let userId = cookieDictionary["_alby_user"] {
                    finalUrl += "&user_id=\(userId)"
                }

                self.performRequest(urlString: finalUrl)
            } else if let error = error {
                print("Error retrieving cookies: \(error.localizedDescription)")
            }
        }
    }

    private func performRequest(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending request: \(error.localizedDescription)")
            } else if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
            }
        }

        task.resume()
    }
}

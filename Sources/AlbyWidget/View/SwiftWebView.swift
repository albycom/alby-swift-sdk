//
//  SwiftWebView.swift
//  AlbyExampleIos
//
//  Created by Thiago Salvatore on 8/22/24.
//

import SwiftUI
import WebKit
import Combine

protocol WebViewHandlerDelegate {
    func receivedJsonValueFromWebView(value: [String: Any?])
}

struct SwiftWebView: UIViewRepresentable, WebViewHandlerDelegate {
    let url: URL?
    let isScrollEnabled: Bool
    @ObservedObject var viewModel: WebViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Receiving data from React JS to IOS
    func receivedJsonValueFromWebView(value: [String: Any?]) {
        $viewModel.callbackValueJS.wrappedValue.send((value.first?.value as? String)!)
    }

    func makeUIView(context: Context) -> WKWebView {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true

        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        // Use default persistent data store to keep cookies and localStorage
        config.websiteDataStore = .default()
        config.userContentController.add(self.makeCoordinator(), name: "IOS_BRIDGE")

        let webview = WKWebView(frame: .zero, configuration: config)

        webview.navigationDelegate = context.coordinator
        webview.allowsBackForwardNavigationGestures = false
        webview.scrollView.isScrollEnabled = isScrollEnabled

        if #available(iOS 16.4, *) {
            webview.isInspectable = true
        } else {
            // Fallback on earlier versions
        } // For Debug

        webview.isOpaque = false
        webview.backgroundColor = UIColor.white

        return webview
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let myUrl = url else {
            return
        }
        // Set cache policy to only ignore local cache
        var request = URLRequest(url: myUrl)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        if uiView.url != url {
            uiView.load(request)
        }
        
        if uiView.scrollView.isScrollEnabled != isScrollEnabled {
            uiView.scrollView.isScrollEnabled = isScrollEnabled;
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: SwiftWebView
        var callbackValueFromNative: AnyCancellable?

        var delegate: WebViewHandlerDelegate?

        init(_ uiWebView: SwiftWebView) {
            self.parent = uiWebView
            self.delegate = parent
        }

        deinit {
            callbackValueFromNative?.cancel()
        }

        func webView(_ webview: WKWebView, didFinish: WKNavigation!) {

            // sending data from IOS to React JS
            self.callbackValueFromNative = self.parent.viewModel.callbackValueFromNative
                .receive(on: RunLoop.main)
                .sink(receiveValue: { value in
                    let js = "var event = new CustomEvent('albyNativeEvent', { detail: { data: '\(value)'}}); window.dispatchEvent(event);"
                    webview.evaluateJavaScript(js, completionHandler: { (_, error) in
                        if let error = error {
                            print(error)
                        }
                    })
                })
        }

        func webView(_ webview: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

            if navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url {
                // Open the link in an external browser (Safari)
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            } else {
                // Allow other types of navigation
                decisionHandler(.allow)
            }
        }
    }
}

extension SwiftWebView.Coordinator: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "IOS_BRIDGE" {
            delegate?.receivedJsonValueFromWebView(value: (message.body as? [String: Any?])!)
        }
    }
}

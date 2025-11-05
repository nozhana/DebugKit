//
//  WebView.swift
//  DebugKit
//
//  Created by Nozhan A. on 11/5/25.
//

#if os(iOS)
import SwiftUI
import WebKit

struct WebView: View {
    var request: URLRequest?
    var simulatedResponse: (URLResponse, Data)? = nil
    var htmlString: String?
    var scaleToFit: Bool?
    
    init(request: URLRequest, simulatedResponse: (URLResponse, Data)?) {
        self.request = request
        self.simulatedResponse = simulatedResponse
    }
    
    init(request: URLRequest, simulatedResponse: URLResponse? = nil, simulatedResponseData: Data? = nil) {
        self.request = request
        if let simulatedResponse, let simulatedResponseData {
            self.simulatedResponse = (simulatedResponse, simulatedResponseData)
        }
    }
    
    init(svgData: Data, request: URLRequest? = nil) {
        self.request = request
        self.htmlString = String(data: svgData, encoding: .utf8)
        self.scaleToFit = true
    }
    
    var body: some View {
        GeometryReader { proxy in
            _WebView(frame: proxy.frame(in: .local),
                     request: request,
                     simulatedResponse: simulatedResponse,
                     htmlString: htmlString)
        }
    }
}

extension WebView {
    struct _WebView: UIViewRepresentable {
        var frame: CGRect
        var request: URLRequest?
        var simulatedResponse: (response: URLResponse, data: Data)?
        var htmlString: String?
        var scaleToFit: Bool?
        
        private let navigationDelegate: NavigationDelegate
        
        init(frame: CGRect, request: URLRequest?, simulatedResponse: (URLResponse, Data)? = nil, htmlString: String?, scaleToFit: Bool? = nil) {
            self.frame = frame
            self.request = request
            self.simulatedResponse = simulatedResponse
            self.htmlString = htmlString
            self.scaleToFit = scaleToFit
            self.navigationDelegate = .init(request: request)
        }
        
        func makeUIView(context: Context) -> WKWebView {
            let view = WKWebView(frame: frame)
            if let scaleToFit {
                view.scalesLargeContentImage = scaleToFit
            }
            view.navigationDelegate = navigationDelegate
            return view
        }
        
        func updateUIView(_ view: WKWebView, context: Context) {
            if let request,
               let simulatedResponse {
                view.loadSimulatedRequest(request, response: simulatedResponse.response, responseData: simulatedResponse.data)
            } else if let htmlString {
                view.loadHTMLString(htmlString, baseURL: request?.url)
            } else if let request {
                view.load(request)
            }
        }
    }
    
    
    private final class NavigationDelegate: NSObject, WKNavigationDelegate {
        var request: URLRequest?
        
        init(request: URLRequest? = nil) {
            self.request = request
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            guard let request else { return .cancel }
            return navigationAction.request.url == request.url ? .allow : .cancel
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse) async -> WKNavigationResponsePolicy {
            guard let request else { return .cancel }
            return navigationResponse.response.url == request.url ? .allow : .cancel
        }
    }
}
#endif

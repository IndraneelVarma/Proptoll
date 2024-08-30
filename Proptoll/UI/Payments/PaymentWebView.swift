//
//  PaymentWebView.swift
//  Proptoll
//
//  Created by Indraneel Varma on 30/08/24.
//

import SwiftUI
import WebKit

struct PaymentWebView: View {
    var html: String
    var body: some View {
        WebView(htmlString: html)
    }
}

struct WebView: UIViewRepresentable {
    let htmlString: String
    let isLoading = true
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}

#Preview {
    PaymentWebView(html: "html")
}

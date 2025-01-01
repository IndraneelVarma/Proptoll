import SwiftUI
@preconcurrency import WebKit
import MatomoTracker

struct PaymentWebView: View {
    var html: String
    @Binding var webViewOpen: Bool
    @Binding var isLoading: Bool
    @Binding var showPayScreen: Bool
    @State private var paymentStatus: PaymentStatus = .unknown
    
    var body: some View {
        WebView(htmlString: html, paymentStatus: $paymentStatus)
            .navigationBarBackButtonHidden(true)
            .onAppear(){
                //print("[PaymentWebView] View appeared")
                matomoTracker.track(view: ["Payments Web Page"])
            }
            .navigationDestination(isPresented: .constant(paymentStatus != .unknown)) {
                switch paymentStatus {
                case .success:
                    PaymentResultView(status: .success, webViewOpen: $webViewOpen, showPayScreen: $showPayScreen)
                case .failure:
                    PaymentResultView(status: .failure, webViewOpen: $webViewOpen, showPayScreen: $showPayScreen)
                case .unknown:
                    EmptyView()
                }
            }
    }
}

struct WebView: UIViewRepresentable {
    let htmlString: String
    let isLoading = true
    @Binding var paymentStatus: PaymentStatus
    
    func makeUIView(context: Context) -> WKWebView {
        //print("[WebView] Creating WKWebView instance")
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        //print("[WebView] Loading HTML content into WebView")
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        //print("[WebView] Creating WebView coordinator")
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        private var navigationLocked = false
        
        init(_ parent: WebView) {
            //print("[WebView.Coordinator] Initializing coordinator")
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // If navigation is locked, prevent any further navigation
            if navigationLocked {
                //print("[WebView.Coordinator] Navigation locked, canceling all navigation attempts")
                decisionHandler(.cancel)
                return
            }
            
            
            if let url = navigationAction.request.url {
                //print("[WebView.Coordinator] Navigation requested to URL: \(url.absoluteString)")
                
             if url.scheme == "itms-apps" || url.host?.contains("apps.apple.com") == true {
                    // Open in App Store
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                        decisionHandler(.cancel)
                        return
                    }
                } 
                if url.absoluteString.contains("/paymentSuccess") {
                    //print("[WebView.Coordinator] Payment success URL detected")
                    DispatchQueue.main.async {
                        //print("[WebView.Coordinator] Updating payment status to success")
                        self.parent.paymentStatus = .success
                    }
                    //print("[WebView.Coordinator] Locking navigation and canceling current request")
                    navigationLocked = true
                    decisionHandler(.cancel)
                    return
                } else if url.absoluteString.contains("/paymentFailure") {
                    //print("[WebView.Coordinator] Payment failure URL detected")
                    DispatchQueue.main.async {
                        //print("[WebView.Coordinator] Updating payment status to failure")
                        self.parent.paymentStatus = .failure
                    }
                    //print("[WebView.Coordinator] Locking navigation and canceling current request")
                    navigationLocked = true
                    decisionHandler(.cancel)
                    return
                }
            }
            
            //print("[WebView.Coordinator] Allowing navigation")
            decisionHandler(.allow)
        }
    }
}

enum PaymentStatus {
    case success
    case failure
    case unknown
}

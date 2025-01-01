import SwiftUI
import WebKit

struct ForceUpdateView2: View {
    @State private var showUpdateAlert = false
    @State private var isChecking = false
    
    /// Tracks whether the update is forced or not.
    @State private var isForceUpdate = false
    
    /// Toggles the WebView overlay if no update is required (and user hasn't seen or the HTML changed).
    @State private var showWebView = false
    
    /// The **new** HTML content we fetch from the server (or define in code).
    /// In a real app, you’d fetch this from some API. For demonstration, we’ll define it locally.
    @State private var newHTMLString: String = ""
    
    // MARK: - AppStorage Keys
    
    /// The last HTML content displayed (persisted in UserDefaults).
    @AppStorage("lastHTMLString") private var lastHTMLString: String = ""
    
    /// Tracks whether the user has dismissed/closed the HTML popup before (persisted in UserDefaults).
    @AppStorage("seenHTMLPopup") private var seenHTMLPopup: Bool = false
    
    @AppStorage("userTheme") private var userTheme: Theme = .system
    @Environment(\.colorScheme) private var systemColorScheme
    
    private var currentColorScheme: ColorScheme {
        switch userTheme {
        case .system:
            return systemColorScheme
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    var body: some View {
        ZStack {
            ContentView()  // <-- Your main content view
            
            // Shows the update alert if needed
            if showUpdateAlert {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        UpdateAlertView2(
                            showUpdateAlert: $showUpdateAlert,
                            isForceUpdate: isForceUpdate
                        )
                    )
            }
            
            // Shows a dismissable WebView if conditions are met:
            // 1) Force update is NOT needed, so we do not show the update alert
            // 2) The user hasn't seen it OR the HTML changed
            if showWebView {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        WebViewOverlay(
                            showWebView: $showWebView,
                            htmlString: lastHTMLString,
                            seenHTMLPopup: $seenHTMLPopup
                        )
                    )
            }
        }
        .preferredColorScheme(currentColorScheme)
        .onAppear {
            // Added API log here to indicate screen appearance
            //print("API Logs: ForceUpdateView2 appeared, calling checkForUpdate()")
            if !UserDefaults.standard.bool(forKey: "fromSettings") {
                checkForUpdate()
            }
        }
    }
    
    /// Checks the App Store version and compares **only** major versions
    private func checkForUpdate() {
        //print("API Logs: Entering checkForUpdate()")
        
        let currentVersion = Bundle.main.releaseVersionNumber
        //print("📱 Current app version:", currentVersion)
        //print("API Logs: Current app version: \(currentVersion)")
        
        guard let url = URL(string: "\(baseApiUrl)landing-info") else {
            //print("❌ Failed to create landing-info URL")
            //print("API Logs: Failed to create valid URL for landing-info endpoint")
            return
        }
        
        //print("🔍 Checking App Store version at URL:", url.absoluteString)
        //print("API Logs: Initiating network request to \(url.absoluteString)")
        isChecking = true
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            self.isChecking = false
            
            if let error = error {
                //print("❌ Network error:", error.localizedDescription)
                //print("API Logs: Network error -> \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                //print("❌ Invalid response type")
                //print("API Logs: The response is not an HTTPURLResponse type")
                return
            }
            
            //print("📡 App Store API response status:", httpResponse.statusCode)
            //print("API Logs: HTTP status code -> \(httpResponse.statusCode)")
            
            guard let data = data else {
                //print("❌ No data received from App Store")
                //print("API Logs: No data received in response")
                return
            }
            
            // Just for demonstration, //printing raw data:
            //print("📦 Received data:", String(data: data, encoding: .utf8) ?? "Unable to convert data to string")
            //print("API Logs: Data received -> \(String(data: data, encoding: .utf8) ?? "")")
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                //print("❌ Failed to parse JSON")
                //print("API Logs: JSON parsing failed")
                return
            }
            
            guard let minIosVersion = json["ios"] as? String else {
                //print("❌ No results found in JSON[ios]")
                //print("API Logs: Missing 'ios' key in JSON")
                return
            }
            
            guard let html = json["html"] as? String else {
                //print("❌ No results found in JSON[ios]")
                //print("API Logs: Missing 'html' key in JSON")
                return
            }
            
            DispatchQueue.main.async {
                self.newHTMLString = html
                //print("API Logs: Successfully assigned newHTMLString on main thread.")
            }
            
            // Compare only major versions
            let shouldForceUpdate = compareMajorVersions(minVersion: minIosVersion, current: currentVersion)
            //print("🔄 Should force update:", shouldForceUpdate)
            //print("API Logs: Result of compareMajorVersions -> \(shouldForceUpdate)")
            
            DispatchQueue.main.async {
                if shouldForceUpdate {
                    self.isForceUpdate = true
                    self.showUpdateAlert = true
                    //print("🚨 Force update alert shown: true")
                    //print("API Logs: isForceUpdate set to true, showUpdateAlert set to true")
                } else {
                    // If major version is not greater, show the WebView overlay if needed
                    //print("API Logs: No force update required, calling handleHTMLPopup()")
                    handleHTMLPopup()
                }
            }
        }.resume()
    }
    
    /// Compare **only** the major versions of the App Store vs. current.
    /// Returns true if the app store's major version is higher (i.e. force update).
    private func compareMajorVersions(minVersion: String, current: String) -> Bool {
        //print("API Logs: compareMajorVersions called -> minVersion: \(minVersion), current: \(current)")
        
        // Split versions
        let minMajor = minVersion.split(separator: ".").compactMap { Int($0) }.first ?? 0
        let currentMajor = current.split(separator: ".").compactMap { Int($0) }.first ?? 0
        
        //print("API Logs: minMajor: \(minMajor), currentMajor: \(currentMajor)")
        
        // If the App Store's major version is greater => Force update
        return minMajor > currentMajor
    }
    
    /// If no force update is needed, handle whether we should show the HTML popup again.
    /// 1) If newHTMLString differs from lastHTMLString => reset `seenHTMLPopup` to false.
    /// 2) If `seenHTMLPopup` is false => show the WebView overlay.
    private func handleHTMLPopup() {
        //print("API Logs: handleHTMLPopup called")
        // Check if the newly fetched HTML is different from what we have stored
        if newHTMLString != lastHTMLString {
            //print("API Logs: newHTMLString != lastHTMLString, resetting seenHTMLPopup to false")
            // If it's different, reset 'seenHTMLPopup' so that we show the overlay again
            lastHTMLString = newHTMLString
            seenHTMLPopup = false
        }
        
     /*   // If the user hasn't seen it (or the HTML just changed), show the overlay
        if !seenHTMLPopup {
            //print("API Logs: seenHTMLPopup is false, setting showWebView to true")
            showWebView = true
        }
     */ //for now showing popup everytime
        showWebView = true
    }
}

/// A custom alert view that adjusts its UI based on whether the update is forced or optional.
struct UpdateAlertView2: View {
    @Binding var showUpdateAlert: Bool
    
    /// Flag to indicate whether the update is forced
    let isForceUpdate: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundColor(.orange)
                .padding(5)
            
            Text("Update Required")
                .font(.headline)
                .padding(5)
            
            if isForceUpdate {
                Text("A new major version of the app is available. You must update to continue using the app.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(5)
            } else {
                Text("A new version of the app is available. We recommend updating to get the latest features and fixes.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(5)
            }
            
            Divider()
            
            HStack(spacing: 0) {
                Button(action: {
                    if let url = URL(string: "itms-apps://apple.com/app/id6480278605") {
                        UIApplication.shared.open(url)
                        //print("API Logs: Update Now tapped, opening App Store link")
                    }
                }) {
                    Text("Update Now")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                }
                
                Divider()
                
                if isForceUpdate {
                    // Forced update => "Close App" action
                    Button(action: {
                        //print("API Logs: Force update scenario, closing app.")
                        exit(0)
                    }) {
                        Text("Close App")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                    }
                } else {
                    // Optional update => "Skip" action (though we are not using optional logic now)
                    Button(action: {
                        // Simply dismiss the dialog
                        //print("API Logs: Skip tapped, dismissing update alert.")
                        showUpdateAlert = false
                    }) {
                        Text("Skip")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                    }
                }
            }
            .padding(5)
            .frame(height: 44)
        }
        .frame(width: min(300, UIScreen.main.bounds.width - 64))
        .background(
            RoundedRectangle(cornerRadius: 13)
                .fill(Color(uiColor: .systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 13)
                .stroke(Color(UIColor.separator), lineWidth: 0.5)
        )
    }
}

/// A simple overlay containing the dismiss button and the WebView displaying HTML content.
struct WebViewOverlay: View {
    @Binding var showWebView: Bool
    
    /// The HTML content to display.
    let htmlString: String
    
    /// Reference to the `seenHTMLPopup` so we can mark it `true` when closed.
    @Binding var seenHTMLPopup: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button {
                    // The user has now dismissed the popup, so mark it as seen
                    seenHTMLPopup = true
                    showWebView = false
                    //print("API Logs: WebView dismissed, seenHTMLPopup set to true")
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                        .padding()
                }
            }
            Spacer()
            
            // Our WebView container that loads HTML content
            WebView2(htmlString: htmlString)
                .cornerRadius(12)
                .padding()
            
            Spacer()
        }
    }
}

/// Simple SwiftUI wrapper around WKWebView, loading an HTML string.
struct WebView2: UIViewRepresentable {
    let htmlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        //print("API Logs: Creating WKWebView instance")
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        //print("API Logs: Loading HTML content into WKWebView")
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
}

import SwiftUI

struct ForceUpdateView: View {
    @State private var showUpdateAlert = false
    @State private var isChecking = false
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
            ContentView()
            
            if showUpdateAlert {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        UpdateAlertView(showUpdateAlert: $showUpdateAlert)
                    )
            }
        }
        .preferredColorScheme(currentColorScheme)
        .onAppear {
            checkForUpdate()
        }
    }
    
    private func checkForUpdate() {
        let currentVersion = Bundle.main.releaseVersionNumber
        //print("📱 Current app version:", currentVersion)
        
        guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=com.proptoll.consumer") else {
            //print("❌ Failed to create App Store URL")
            return
        }
        
        //print("🔍 Checking App Store version at URL:", url.absoluteString)
        isChecking = true
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            isChecking = false
            
            if let error = error {
                //print("❌ Network error:", error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                //print("❌ Invalid response type")
                return
            }
            
            //print("📡 App Store API response status:", httpResponse.statusCode)
            
            guard let data = data else {
                //print("❌ No data received from App Store")
                return
            }
            
            //print("📦 Received data:", String(data: data, encoding: .utf8) ?? "Unable to convert data to string")
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                //print("❌ Failed to parse JSON")
                return
            }
            
            guard let results = json["results"] as? [[String: Any]] else {
                //print("❌ No results found in JSON")
                return
            }
            
            guard let appStoreVersion = results.first?["version"] as? String else {
                //print("❌ No version found in App Store data")
                return
            }
            
            //print("📲 App Store version:", appStoreVersion)
            
            let shouldUpdate = compareVersions(appStore: appStoreVersion, current: currentVersion)
            //print("🔄 Should update:", shouldUpdate)
            //print("📊 Version comparison - App Store: \(appStoreVersion) vs Current: \(currentVersion)")
            
            DispatchQueue.main.async {
                showUpdateAlert = shouldUpdate
                //print("🚨 Update alert shown:", shouldUpdate)
            }
        }.resume()
    }
    
    private func compareVersions(appStore: String, current: String) -> Bool {
        let appStoreComponents = appStore.split(separator: ".").compactMap { Int($0) }
        let currentComponents = current.split(separator: ".").compactMap { Int($0) }
        
        //print("🔢 App Store version components:", appStoreComponents)
        //print("🔢 Current version components:", currentComponents)
        
        // Check if the App Store version ends with .0
        guard let firstComponent = appStoreComponents.first,
              let currentFirst = currentComponents.first , currentFirst < firstComponent && currentFirst != firstComponent else {
            //print("📝 App Store version doesn't end with .0 - skipping force update")
            return false
        }
        
        //print("📝 App Store version ends with .0 - proceeding with version comparison")
        
        let maxCount = max(appStoreComponents.count, currentComponents.count)
        
        for i in 0..<maxCount {
            let appStoreVersion = i < appStoreComponents.count ? appStoreComponents[i] : 0
            let currentVersion = i < currentComponents.count ? currentComponents[i] : 0
            
            //print("🔄 Comparing component \(i): App Store \(appStoreVersion) vs Current \(currentVersion)")
            
            if appStoreVersion > currentVersion {
                //print("📈 Update needed: App Store version is higher")
                return true
            } else if appStoreVersion < currentVersion {
                //print("📉 No update needed: Current version is higher")
                return false
            }
        }
        
        //print("📊 Versions are equal")
        return false
    }
}

struct UpdateAlertView: View {
    @Binding var showUpdateAlert: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundColor(.orange)
                .padding(5)
            
            Text("Update Required")
                .font(.headline)
                .padding(5)
            
            Text("A new version of the app is available. Please update to continue using the app.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(5)
            
            Divider()
            
            HStack(spacing: 0) {
                Button(action: {
                    if let url = URL(string: "itms-apps://apple.com/app/id6480278605") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Update Now")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                }
                
                Divider()
                
                Button(action: {
                    exit(0)
                }) {
                    Text("Close App")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                }
            }
            .padding(5)
            .frame(height: 44)
        }
        .frame(width: min(300, UIScreen.main.bounds.width - 64))
        .background(
            RoundedRectangle(cornerRadius: 13)
                .fill(.onMainTheme)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 13)
                .stroke(Color(UIColor.separator), lineWidth: 0.5)
        )
    }
}

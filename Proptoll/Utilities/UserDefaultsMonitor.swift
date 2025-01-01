import SwiftUI
import Foundation

class UserDefaultsMonitor: ObservableObject {
    @Published private(set) var mainName: String
    @Published private(set) var selectedUnitId: String
    @Published private(set) var selectedAccountId: String
    @Published private(set) var loggedIn: Bool
    @Published private(set) var paymentRefresh: Bool
    let accountId = try? keychain.string(forKey: "accountId")
    init() {
        self.mainName = UserDefaults.standard.string(forKey: "mainName") ?? ""
        self.selectedUnitId = UserDefaults.standard.string(forKey: "selectedUnitId") ?? ""
        self.selectedAccountId = /* UserDefaults.standard.string(forKey: "accountId") ?? ""*/ accountId ?? ""
        self.loggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        self.paymentRefresh = UserDefaults.standard.bool(forKey: "paymentRefresh")
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDefaultsDidChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    // Add methods to update values safely
    func updateMainName(_ newValue: String) {
        UserDefaults.standard.set(newValue, forKey: "mainName")
        self.mainName = newValue
    }
    
    func updateSelectedUnitId(_ newValue: String) {
        UserDefaults.standard.set(newValue, forKey: "selectedUnitId")
        self.selectedUnitId = newValue
    }
    
    func updateSelectedAccountId(_ newValue: String) {
        //UserDefaults.standard.set(newValue, forKey: "accountId")
        try? keychain.set(newValue, forKey: "accountId")
        self.selectedAccountId = newValue
    }
    
    func updateLoginStatus(_ newValue: Bool) {
        UserDefaults.standard.set(newValue, forKey: "isLoggedIn")
        self.loggedIn = newValue
    }
    
    func updatePaymentRefreshStatus(_ newValue: Bool) {
        UserDefaults.standard.set(newValue, forKey: "paymentRefresh")
        self.paymentRefresh = newValue
    }
    
    @objc private func userDefaultsDidChange() {
        // Only update if values actually changed to prevent cycles
        let accountId = try? keychain.string(forKey: "accountId")
        let newMainName = UserDefaults.standard.string(forKey: "mainName") ?? ""
        let newUnitId = UserDefaults.standard.string(forKey: "selectedUnitId") ?? ""
        let newAccountId = /*UserDefaults.standard.string(forKey: "accountId") ?? ""*/ accountId ?? ""
        let loggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        let paymentRefresh = UserDefaults.standard.bool(forKey: "paymentRefresh")
        
        DispatchQueue.main.async {
            if self.mainName != newMainName {
                self.mainName = newMainName
            }
            if self.selectedUnitId != newUnitId {
                self.selectedUnitId = newUnitId
            }
            if self.selectedAccountId != newAccountId {
                self.selectedAccountId = newAccountId
            }
            if self.loggedIn != loggedIn {
                self.loggedIn = loggedIn
            }
            if self.paymentRefresh != paymentRefresh {
                self.paymentRefresh = paymentRefresh
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

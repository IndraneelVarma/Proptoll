//
//  ContentView.swift
//  Proptoll
//
//  Created by Indraneel Varma on 07/08/24.
//

import SwiftUI
import RealmSwift

struct ContentView: View {
    @EnvironmentObject var router: Router
    @StateObject private var userDefaultsMonitor = UserDefaultsMonitor()

    var body: some View {
        NavigationStack(path: $router.path){
            ZStack{
                if !userDefaultsMonitor.loggedIn
                {
                    LoginView()
                }
                else
                {
                    if UserDefaults.standard.string(forKey: "appVersion") != Bundle.main.releaseVersionNumber || RealmManager.shared.realm.isEmpty {
                        WelcomeView()
                    } // to maintain data consistency.
                    else {
                        HomePageView()
                    }
                }
            }
            
        }
        
        
        
    }

    
}

#Preview {
    ContentView()
        .environmentObject(Router())
}

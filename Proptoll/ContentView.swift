//
//  ContentView.swift
//  Proptoll
//
//  Created by Indraneel Varma on 07/08/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var router: Router
    var body: some View {
        NavigationStack(path: $router.path){
            ZStack{
                let token = UserDefaults.standard.string(forKey: "jwtToken")
                if(token == nil)
                {
                    LoginView()
                }
                else
                {
                    HomePageView()
                }
            }
            .onAppear(){
                print(jwtToken)
            }
        }
        
        
        
    }
    
}

#Preview {
    ContentView()
        .environmentObject(Router())
}

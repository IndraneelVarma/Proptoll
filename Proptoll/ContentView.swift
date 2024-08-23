//
//  ContentView.swift
//  Proptoll
//
//  Created by Indraneel Varma on 07/08/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
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

#Preview {
    ContentView()
}

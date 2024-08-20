//
//  ContentView.swift
//  Proptoll
//
//  Created by Indraneel Varma on 07/08/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
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
}

#Preview {
    ContentView()
}

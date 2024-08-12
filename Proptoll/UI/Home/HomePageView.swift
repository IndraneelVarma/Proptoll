//
//  HomePageView.swift
//  Proptoll
//
//  Created by Indraneel Varma on 08/08/24.
//

import SwiftUI

struct HomePageView: View{
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    var body: some View {
        TabView {
            NoticeBoardView()
                .tabItem {
                    Image(systemName: "bookmark.square.fill")
                    Text("Notice Board")
                }
            
            BillsView()
                .tabItem {
                    Image(systemName: "dollarsign")
                    Text("Bills")
                }
            
            ReceiptsView()
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("Receipts")
                }
        }
        .preferredColorScheme(userTheme.colorScheme)
        .navigationBarBackButtonHidden(true)
        
    }
        
}

#Preview {
    HomePageView()
}

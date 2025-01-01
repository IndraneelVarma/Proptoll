//
//  NoticeBoardSearchview.swift
//  Proptoll
//
//  Created by Indraneel Varma on 19/08/24.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @Binding var isSearching: Bool
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack {
            TextField("Search...", text: $text)
                .focused($isTextFieldFocused)
                .padding(7)
                .padding(.horizontal, 25)
                .background(.mainTheme)
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(UIColor.systemGray4) )
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(Color(UIColor.systemGray4) )
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                
            
            
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.isSearching = false
                        self.text = ""
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            
        }
        .onAppear(){
            isTextFieldFocused = true
        }
    }
}


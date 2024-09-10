//
//  TopBar.swift
//  Proptoll
//
//  Created by Indraneel Varma on 16/08/24.
//

import SwiftUI

struct TopBarView: View {
    @Binding var showSheet: Bool
    @StateObject var viewModel = ProfileViewModel()
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.purple)
            .frame(width: 370, height: 30)
            .overlay(
                HStack{
                    Image(systemName: "chevron.down")
                        .foregroundStyle(.white)
                    Text("Plot No. \(viewModel.profile.first?.plotNumber ?? "xxxx")")
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                    Text("I.D.P.L. Employees Co-op. ")
                        .foregroundStyle(.white)
                }
                    .frame(width:330, alignment: .leading)
            )
            .onAppear(){
                Task{
                    await viewModel.fetchProfile(jsonQuery: [:])
                }
                
            }
            .padding(EdgeInsets(top: 15, leading: 10, bottom: 10, trailing: 10))
            .onTapGesture {
                showSheet.toggle()
            }
    }
    
}

#Preview {
    TopBarView(showSheet: .constant(false))
}

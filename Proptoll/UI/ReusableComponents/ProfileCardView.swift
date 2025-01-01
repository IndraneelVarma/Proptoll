//
//  ProfileCard.swift
//  Proptoll
//
//  Created by Indraneel Varma on 12/08/24.
//

import SwiftUI

struct ProfileCardView: View {
    var image: String
    var mainText: String
    var subText: String
    var body: some View {
        VStack{
            HStack{
                Image(systemName: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 22.5)
                    .padding()
                    .foregroundStyle(.primary)
                    
                
                Text(mainText)
                    .font(.custom("Montserrat-Regular", size: 16))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Circle()
                    .frame(width: 1, height: 1)
                    .foregroundStyle(.green)
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 22.5)
                    .padding()
                    .foregroundStyle(.primary)
            }
            
            Divider()
                .padding(.horizontal, 20)
        }
    }
}

#Preview {
    SettingsView(showSettings: .constant(true))
}

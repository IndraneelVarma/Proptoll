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
        HStack{
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(height: 30)
                .padding()
                .foregroundStyle(.orange)
            VStack(alignment: .leading){
                Text(mainText)
                    .font(.title)
                    .bold()
                    .foregroundStyle(.primary)
                Text(subText)
                    .font(.system(size: 13))
                    .foregroundStyle(.primary)
                HStack{
                    RoundedRectangle(cornerRadius: 10)
                }
                .frame(maxWidth: .infinity, maxHeight: 2)
            }
            Spacer()
        }
        .background(Color(UIColor.systemGray4) )
    }
}

#Preview {
    SettingsView()
}

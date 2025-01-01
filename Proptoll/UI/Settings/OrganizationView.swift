//
//  OrganizationView.swift
//  Proptoll
//
//  Created by Indraneel Varma on 24/10/24.
//

import SwiftUI

struct OrganizationView: View {
    @StateObject private var realmManager = OrgRealmManager()
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {  // Added spacing for better layout
            Text(UserDefaults.standard.string(forKey: "organization") ?? "")
                .padding(.bottom, 15)
                .font(.custom("Montserrat-Medium", size: 16))
            
            Group {
                Text("\(realmManager.organizations.first?.addressLine1 ?? "")")
                Text("\(realmManager.organizations.first?.addressLine2 ?? ""),")
                Text("\(realmManager.organizations.first?.city ?? ""), \(realmManager.organizations.first?.state ?? ""), \(realmManager.organizations.first?.country ?? "").")
                Text("\(realmManager.organizations.first?.postalCode ?? "")")
            }
            .font(.custom("Montserrat-Regular", size: 15))
            
            Divider()
                .padding(.horizontal, -15)
               
            
            Button {
                let telephone = "tel://"
                let formattedString = telephone + "9346833440"
                guard let url = URL(string: formattedString) else { return }
                UIApplication.shared.open(url)
            } label: {
                HStack {
                    Image(systemName: "phone")
                    Text("9876543210")
                        .underline()
                        .font(.custom("Montserrat-Medium", size: 16))
                        .padding(.leading, 5)
                }
                .tint(.primary)
            }
        }
        .padding()  // Add padding inside the border
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(UIColor.separator), lineWidth: 1)  // Same color as Divider
        )
    }
}

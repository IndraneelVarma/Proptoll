//
//  BillsSheetView.swift
//  Proptoll
//
//  Created by Indraneel Varma on 08/08/24.
//

import SwiftUI

struct BillsSheetView: View {
    var body: some View {
        VStack(alignment: .leading){
            Text("Choose a Plot")
                .font(.title)
                .bold()
                .padding(EdgeInsets(top: 15, leading: 10, bottom: 5, trailing: 0))
            Text("Select your prefered plot from the available \noptions")
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 20, trailing: 0))
            RoundedRectangle(cornerRadius: 15)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                .frame(width: 150,height: 100)
                .foregroundStyle(.gray)
                .overlay {
                    Text("Dummy Plot")
                        .font(.system(size: 15, weight: .bold))
                    
                }
        }
        Spacer()
    }
}

#Preview {
    BillsSheetView()
}

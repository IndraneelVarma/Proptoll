//
//  WelcomeView.swift
//  Proptoll
//
//  Created by Indraneel Varma on 12/08/24.
//

import SwiftUI

struct WelcomeView: View {
    var name: String
    var body: some View {
        Text(name)
    }
}

#Preview {
    WelcomeView(name: "Neel")
}

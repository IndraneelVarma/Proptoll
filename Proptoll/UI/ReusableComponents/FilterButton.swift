//
//  FilterButton.swift
//  Proptoll
//
//  Created by Indraneel Varma on 18/11/24.
//
import SwiftUI

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? Color.plotBar : .onMainTheme)
                .frame(width: CGFloat(title.count * 10 + 10), height: 30)
                .overlay(
                    HStack(spacing: 5) {
                        Text(title)
                            .font(.custom("Montserrat-Regular", size: 13))
                            .foregroundStyle(isSelected ? .specialText : .customPrimary)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.customPrimary, lineWidth: 0.25)
                )
        }
    }
}

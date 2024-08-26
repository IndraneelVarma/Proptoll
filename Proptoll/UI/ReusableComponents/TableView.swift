//
//  TableView.swift
//  Proptoll
//
//  Created by Indraneel Varma on 26/08/24.
//

import Foundation
import SwiftUI

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
    }
}

struct ProfessionalTableView: View {
    let items: [String]
    let rowCount: Int
    let columnCount: Int
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<rowCount, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<columnCount, id: \.self) { column in
                        let index = row * columnCount + column
                        if index < items.count {
                            CellView(text: items[index], isHeader: row == 0)
                        } else {
                            CellView(text: "", isHeader: false)
                        }
                    }
                }
            }
        }
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct CellView: View {
    let text: String
    let isHeader: Bool
    
    var body: some View {
        Text(text)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, minHeight: 30, alignment: .trailing)
            .background(isHeader ? Color(UIColor.systemGray4) : Color(UIColor.systemBackground))
            .foregroundColor(isHeader ? .primary : .secondary)
            .font(.system(size: 12, weight: isHeader ? .semibold : .regular))
            .overlay(
                Rectangle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
            )
    }
}

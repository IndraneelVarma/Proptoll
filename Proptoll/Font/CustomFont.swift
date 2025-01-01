//
//  CustomFont.swift
//  Proptoll
//
//  Created by Indraneel Varma on 08/10/24.
//
import Foundation
import SwiftUI

extension Font {
    static func customFont(name: String, size: CGFloat) -> Font {
        return Font.custom(name, size: size)
    }
}

//
//  Router.swift
//  Proptoll
//
//  Created by Indraneel Varma on 02/09/24.
//

import SwiftUI

//manual handling of nvigation paths specifically for notices deeplinks
class Router: ObservableObject{
    @Published var path = NavigationPath()
    
    func reset(){
        path = NavigationPath()
    }
}

//
//  NavigationRouterImp.swift
//  TodoList
//
//  Created by Nathan Molby on 5/9/25.
//

import Foundation

@Observable class BaseAppNavigationRouter: NavigationRouter {
    
    var sheetDisplayed: BaseAppSheetNavigationRoute? = nil
    
    var pushNavigationStack: [BaseAppPushNavigationRoute] = []
    
    func navigate(to route: BaseAppNavigationRoute) {
        switch route {
        case .addTodo:
            sheetDisplayed = .addTodo
        }
    }
}

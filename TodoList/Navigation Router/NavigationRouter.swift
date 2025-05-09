//
//  NavigationRouter.swift
//  TodoList
//
//  Created by Nathan Molby on 5/9/25.
//

import Foundation

/// Supports navigation to the associated NavigationRoutes
protocol NavigationRouter<NavigationRoute> {
    associatedtype NavigationRoute: TodoList.NavigationRoute
    
    func navigate(to route: NavigationRoute)
    
    var sheetDisplayed: NavigationRoute.SheetNavigationRoute? { get }
    
    var pushNavigationStack: [NavigationRoute.PushNavigationRoute] { get }
}

//
//  NavigationRouterProtocol.swift
//  TodoList
//
//  Created by Nathan Molby on 5/9/25.
//

import Foundation

/// Supports navigation to the associated NavigationRoutes
protocol NavigationRouterProtocol<NavigationRoute> {
    associatedtype NavigationRoute: TodoList.NavigationRouteProtocol
    
    func navigate(to route: NavigationRoute)
    
    var sheetDisplayed: NavigationRoute.SheetNavigationRoute? { get set }
    
    var pushNavigationStack: [NavigationRoute.PushNavigationRoute] { get set }
}

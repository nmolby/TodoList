//
//  NavigationRouterMock.swift
//  TodoListTests
//
//  Created by Nathan Molby on 5/9/25.
//

import Foundation
@testable import TodoList

class NavigationRouterMock<Route: NavigationRoute>: NavigationRouter {
    var sheetDisplayed: Route.SheetNavigationRoute? {
        fatalError("Do not use sheetDisplayed in MockNavigationRouter. Track navigated routes with navigatedRoute")
    }
    
    var pushNavigationStack: [Route.PushNavigationRoute] {
        fatalError("Do not use pushNavigationStack in MockNavigationRouter. Track navigated routes with navigatedRoute")
    }
    
    var navigatedRoute: Route?
    
    func navigate(to route: Route) {
        navigatedRoute = route
    }
}

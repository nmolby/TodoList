//
//  NavigationRouterMock.swift
//  TodoListTests
//
//  Created by Nathan Molby on 5/9/25.
//

import Foundation
@testable import TodoList

class NavigationRouterMock<Route: NavigationRouteProtocol>: NavigationRouterProtocol {
    var sheetDisplayed: Route.SheetNavigationRoute? {
        get {
            fatalError("Do not use sheetDisplayed in MockNavigationRouter. Track navigated routes with navigatedRoute")
        } set {
            fatalError("Do not use sheetDisplayed in MockNavigationRouter. Track navigated routes with navigatedRoute")
        }
    }
    
    var pushNavigationStack: [Route.PushNavigationRoute] {
        get {
            fatalError("Do not use pushNavigationStack in MockNavigationRouter. Track navigated routes with navigatedRoute")
        } set {
            fatalError("Do not use pushNavigationStack in MockNavigationRouter. Track navigated routes with navigatedRoute")
        }
    }
    
    var navigatedRoute: Route?
    
    func navigate(to route: Route) {
        navigatedRoute = route
    }
}

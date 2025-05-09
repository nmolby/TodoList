//
//  BaseAppNavigationRoute.swift
//  TodoList
//
//  Created by Nathan Molby on 5/9/25.
//


enum BaseAppNavigationRoute: NavigationRoute {
    typealias SheetNavigationRoute = BaseAppSheetNavigationRoute
    
    typealias PushNavigationRoute = BaseAppPushNavigationRoute
    
    case addTodo
}




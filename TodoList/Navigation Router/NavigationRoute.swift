//
//  NavigationRoute.swift
//  TodoList
//
//  Created by Nathan Molby on 5/9/25.
//


protocol NavigationRoute {
    associatedtype SheetNavigationRoute: Identifiable
    associatedtype PushNavigationRoute: Identifiable
}

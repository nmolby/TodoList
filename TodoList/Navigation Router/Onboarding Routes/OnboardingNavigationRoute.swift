//
//  OnboardingNavigationRoute.swift
//  TodoList
//
//  Created by Nathan Molby on 5/9/25.
//

import Foundation

// Please note the below routes are not implemented and are intended
// As an additional example of how the NavigationRoute architecture
// Would work
enum OnboardingNavigationRoute: NavigationRouteProtocol {
    typealias SheetNavigationRoute = OnboardingSheetNavigationRoute
    
    typealias PushNavigationRoute = OnboardingPushNavigationRoute
    
    case termsOfService
    case forgotPassword
    case createAccount
    case login
}




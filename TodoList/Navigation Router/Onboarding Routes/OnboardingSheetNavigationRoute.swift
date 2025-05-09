//
//  OnboardingSheetNavigationRoute.swift
//  TodoList
//
//  Created by Nathan Molby on 5/9/25.
//

// Please note the below routes are not implemented and are intended
// As an additional example of how the NavigationRoute architecture
// Would work
enum OnboardingSheetNavigationRoute: Identifiable {
    case termsOfService
    case forgotPassword
    
    var id: Self {
        self
    }
}

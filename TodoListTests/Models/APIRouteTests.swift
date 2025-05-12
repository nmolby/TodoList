//
//  APIRouteTests.swift
//  TodoListTests
//
//  Created by Nathan Molby on 5/11/25.
//

import Testing
@testable import TodoList

struct APIRouteTests {

    @Test func fetchTodosTests()  {
        let route = APIRoute.fetchTodos
        
        #expect(route.method == .get)
        #expect(route.path == "/todos")
    }

}

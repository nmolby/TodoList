//
//  APIClientMock.swift
//  TodoListTests
//
//  Created by Nathan Molby on 5/9/25.
//

import Foundation
@testable import TodoList

class APIClientMock<ResponseType: Decodable>: APIClient {
    var requestHelper: ((APIRoute) async throws -> ResponseType)? = nil

    func request<T>(_ route: TodoList.APIRoute) async throws -> T where T : Decodable {
        guard let requestHelper else {
            throw TestError.responseNotSet
        }
        
        let response = try await requestHelper(route)
        
        guard let response = response as? T else {
            throw TestError.invalidHelper
        }
        
        return response
    }
    
}

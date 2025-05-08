//
//  APIRoute.swift
//  TodoList
//
//  Created by Nathan Molby on 5/8/25.
//

import Foundation

enum APIRoute {
    case fetchTodos
    
    var method: HTTPMethod {
        switch self {
        case .fetchTodos: return .get
        }
    }
    
    var path: String {
        switch self {
        case .fetchTodos: return "/todos"
        }
    }
    
    func createRequest(baseURL: URL) -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }
}

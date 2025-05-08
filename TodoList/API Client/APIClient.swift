//
//  APIClient.swift
//  TodoList
//
//  Created by Nathan Molby on 5/8/25.
//

import Foundation

protocol APIClient {
    func request<T: Decodable>(_ route: APIRoute) async throws -> T
}

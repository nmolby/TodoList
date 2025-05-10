//
//  APIClientProtocol.swift
//  TodoList
//
//  Created by Nathan Molby on 5/8/25.
//

import Foundation

protocol APIClientProtocol {
    func request<T: Decodable>(_ route: APIRoute) async throws -> T
}

//
//  APIClientImp.swift
//  TodoList
//
//  Created by Nathan Molby on 5/8/25.
//

import Foundation

final class APIClientImp: APIClient {
    private let baseURL: URL
    
    // URLSession is broken on iOS 18.4 simulator: https://developer.apple.com/forums/thread/777999
    // THe fix is to use ephemeral storage
    #if targetEnvironment(simulator)
    private let session: URLSession = URLSession(configuration: .ephemeral)
    #else
    private let session: URLSession = URLSession()
    #endif
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    func request<T: Decodable>(_ route: APIRoute) async throws -> T {
        let request = route.createRequest(baseURL: baseURL)
        let (data, response) = try await session.data(for: request)
        try validate(response: response, data: data)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard 200..<300 ~= httpResponse.statusCode else {
            throw APIError(statusCode: httpResponse.statusCode, data: data)
        }
    }
}

extension APIClientImp {
    @MainActor static var preview: APIClient {
        APIClientImp(baseURL: URL(string: "https://jsonplaceholder.typicode.com")!)
    }
}

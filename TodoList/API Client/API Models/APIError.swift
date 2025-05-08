//
//  APIError.swift
//  TodoList
//
//  Created by Nathan Molby on 5/8/25.
//


import Foundation

struct APIError: Error {
    let statusCode: Int
    let data: Data
}

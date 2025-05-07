//
//  TestError.swift
//  TodoListTests
//
//  Created by Nathan Molby on 5/6/25.
//

import Foundation

enum TestError: Error, Equatable {
    case notImplemented
    case responseNotSet
    case uniqueTestError(UUID)
}

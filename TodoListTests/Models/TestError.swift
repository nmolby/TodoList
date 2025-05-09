//
//  TestError.swift
//  TodoListTests
//
//  Created by Nathan Molby on 5/6/25.
//

import Foundation

enum TestError: Error, Equatable {
    case responseNotSet
    case invalidHelper
    case uniqueTestError(UUID)
}

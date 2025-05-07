//
//  CoreDataManager+Ext.swift
//  TodoListTests
//
//  Created by Nathan Molby on 5/6/25.
//

import Foundation
@testable import TodoList

extension CoreDataManager {
    static func forUnitTests() -> CoreDataManager {
        return .init(inMemory: true)
    }
}

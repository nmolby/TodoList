//
//  MockErrorStore.swift
//  TodoListTests
//
//  Created by Nathan Molby on 5/8/25.
//

import Foundation
@testable import TodoList

class ErrorStoreMock: ErrorStoreProtocol {
    var errorString: String?
}

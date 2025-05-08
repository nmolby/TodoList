//
//  TodoListSortMethod.swift
//  TodoList
//
//  Created by Nathan Molby on 5/8/25.
//

import Foundation

enum SortMethod: CaseIterable {
    case newestFirst
    case oldestFirst
    case alphabeticalDescending
    case alphabeticalAscending
    
    var label: String {
        switch self {
        case .newestFirst:
            return "Newest First"
        case .oldestFirst:
            return "Oldest First"
        case .alphabeticalDescending:
            return "Z to A"
        case .alphabeticalAscending:
            return "A to Z"
        }
    }
}

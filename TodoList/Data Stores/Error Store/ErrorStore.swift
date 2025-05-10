//
//  ErrorStore.swift
//  TodoList
//
//  Created by Nathan Molby on 5/7/25.
//

import Foundation

@Observable class ErrorStore: ErrorStoreProtocol {
    var errorString: String? = nil {
        didSet {
            guard errorString != nil else { return }
            
            if let cancellationTask {
                cancellationTask.cancel()
                self.cancellationTask = nil
            }
            
            cancellationTask = Task {
                defer {
                    self.cancellationTask = nil
                }
                
                try? await Task.sleep(nanoseconds: 4_000_000_000)
                
                do {
                    try Task.checkCancellation()
                    errorString = nil
                } catch { }
            }
        }
    }
    
    @ObservationIgnored private var cancellationTask: Task<Void, Never>? = nil
}

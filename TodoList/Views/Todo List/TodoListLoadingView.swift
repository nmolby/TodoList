//
//  TodoListLoadingView.swift
//  TodoList
//
//  Created by Nathan Molby on 5/7/25.
//

import SwiftUI

struct TodoListLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .controlSize(.extraLarge)

            Text("Loading your to-dos...")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    TodoListLoadingView()
}

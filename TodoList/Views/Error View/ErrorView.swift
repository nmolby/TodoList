//
//  ErrorView.swift
//  TodoList
//
//  Created by Nathan Molby on 5/7/25.
//

import SwiftUI

struct ErrorView: View {
    let errorString: String
    
    var body: some View {
        Text(errorString)
            .font(.body)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.red)
                    .shadow(radius: 4)
            )
            .padding(.horizontal)
            .padding(.bottom)
    }
}

#Preview {
    ErrorView(errorString: "Couldn’t save your to-do. Try again.")
}

//
//  InputView.swift
//  BoulderBro
//
//  Created by Hazz on 15/08/2024.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    let title: String
    let placehodler: String
    var isSecureField = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .foregroundStyle(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            
            if isSecureField {
                SecureField(placehodler, text: $text)
                    .font(.system(size: 14))
            } else {
                TextField(placehodler, text: $text)
                    .font(.system(size: 14))
            }
            Divider()
        }
        .padding(.vertical, 4)
    }
}
    
    #Preview {
        InputView(text: .constant(""), title: "Email Address", placehodler: "name@example.com")
    }

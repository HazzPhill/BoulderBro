//
//  Menu.swift
//  BoulderBro
//
//  Created by Hazz on 19/08/2024.
//

import SwiftUI

// MenuItem struct
struct MenuItem: Hashable, Identifiable {
    let id = UUID()
    let icon: String
    let text: String?
}

// CapsuleMenu view
struct Menu: View {
    let menuItems: [MenuItem] = [
        MenuItem(icon: "house", text: "Home"),
        MenuItem(icon: "magnifyingglass", text: "Search"),
        MenuItem(icon: "plus.circle", text: nil),
        MenuItem(icon: "person", text: "Profile")
    ]

    var body: some View {
        Capsule()
            .fill(Color.gray)
            .frame(height: 50)
            .overlay(
                HStack {
                    ForEach(menuItems) { item in
                        Button(action: {
                            // Handle menu item tap
                        }) {
                            Image(systemName: item.icon)
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                            if let text = item.text {
                                Text(text)
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            )
    }
}
#Preview {
    Menu()
}

//
//  SettingsRowView.swift
//  BoulderBro
//
//  Created by Hazz on 15/08/2024.
//

import SwiftUI

struct SettingsRowView: View {
    @Environment(\.colorScheme) var colorScheme // To detect the current color
    let imageName: String
    let title: String
    let tintColor: Color
    
    var body: some View {
        HStack(spacing: 12){
            Image(systemName: imageName)
                .imageScale(.small)
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .foregroundStyle(tintColor)
            
            Text (title)
                .font(.subheadline)
                .foregroundStyle(Color(colorScheme == .dark ? Color.white : Color(hex: "#000000")))
        }
    }
}

#Preview {
    SettingsRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
}

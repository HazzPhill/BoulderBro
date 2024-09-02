//
//  GeneralSettingsView.swift
//  BoulderBro
//
//  Created by Hazz on 30/08/2024.
//

import SwiftUI

struct GeneralSettingsView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.2") // Replace with your actual version
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("General")
    }
}

#Preview {
    GeneralSettingsView()
}

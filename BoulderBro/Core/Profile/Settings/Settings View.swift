//
//  Settings View.swift
//  BoulderBro
//
//  Created by Hazz on 29/08/2024.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section {
                NavigationLink(destination: GeneralSettingsView()) {
                    Text("General")
                }
                .padding(.vertical, 8)
                
                NavigationLink(destination: AppearanceSettingView()) {
                    Text("Appearance")
                }
                .padding(.vertical, 8)
                
                NavigationLink(destination: PrivacyAndSecurityView()) {
                    Text("Privacy & Security")
                }
                .padding(.vertical, 8)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}

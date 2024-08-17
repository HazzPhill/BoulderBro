//
//  FitnessTabView.swift
//  BoulderBro
//
//  Created by Hazz on 17/08/2024.
//

import SwiftUI

struct FitnessTabView: View {
    @State var selectedTab = "Home"
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.stackedLayoutAppearance.selected.iconColor = .blue
        
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    var body: some View {
        TabView(selection:$selectedTab) {
            FitnessHome()
                .tag("Home")
                .tabItem {
            Image(systemName: "chart.xyaxis.line")
        }
            
            HistoricDataView()
                .tag("Home")
                .tabItem {
            Image(systemName: "book.fill")
        }
        }
    }
}

#Preview {
    FitnessTabView()
}

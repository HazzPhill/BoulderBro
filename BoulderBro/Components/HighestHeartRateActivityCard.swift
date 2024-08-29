//
//  HighestHeartRateActivityCard.swift
//  BoulderBro
//
//  Created by Hazz on 29/08/2024.
//

import SwiftUI

struct HighestHeartRateActivityCard: View {
    @State var highestHeartRates: [(date: Date, heartRate: Double)] = []
    @Environment(\.colorScheme) var colorScheme // To detect the current color scheme
    @EnvironmentObject var colorThemeManager: ColorThemeManager // Access the theme color
    
    var body: some View {
        ZStack {
            // Background color: white in light mode, dark gray in dark mode
            Color(colorScheme == .dark ? Color(hex: "#333333") : .white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Highest Heart Rate")
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .foregroundColor(.primary) // Adjusts automatically to light/dark mode
                        
                        Text("In past 5 climbs")
                            .foregroundColor(.secondary) // Adjusts automatically to light/dark mode
                    }
                    
                    Spacer()
                    
                    Image(systemName: "heart.circle.fill")
                        .foregroundStyle(colorThemeManager.currentThemeColor) // Use theme color
                }
                
                if highestHeartRates.isEmpty {
                    Text("No data available")
                        .font(.custom("Kurdis-ExtraWideBold", size: 20))
                        .foregroundStyle(colorThemeManager.currentThemeColor)
                        .padding()
                } else {
                    let highestHeartRate = highestHeartRates.map { $0.heartRate }.max() ?? 0
                    Text("\(Int(highestHeartRate)) bpm")
                        .font(.custom("Kurdis-ExtraWideBold", size: 20))
                        .foregroundStyle(colorThemeManager.currentThemeColor)
                        .padding()
                }
            }
            .padding()
        }
        .onAppear {
            // Fetch highest heart rates for the last 5 climbing workouts
            HealthManager.shared.fetchHighestHeartRateForLastClimbingWorkouts { result in
                switch result {
                case .success(let data):
                    self.highestHeartRates = data
                case .failure(let error):
                    print("Error fetching heart rate data: \(error)")
                }
            }
        }
    }
}

#Preview {
    HighestHeartRateActivityCard()
        .environmentObject(ColorThemeManager()) // Provide the ColorThemeManager for the preview
}

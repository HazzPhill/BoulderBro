//
//  HearRateActivityCard.swift
//  BoulderBro
//
//  Created by Hazz on 29/08/2024.
//

import SwiftUI

struct HeartRateActivityCard: View {
    @State var averageHeartRates: [(date: Date, heartRate: Double)] = []
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
                        Text("Average Heart Rate")
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .foregroundColor(.primary) // Adjusts automatically to light/dark mode
                        
                        Text("In past 5 climbs")
                            .foregroundColor(.secondary) // Adjusts automatically to light/dark mode
                    }
                    
                    Spacer()
                    
                    Image(systemName: "heart.fill")
                        .foregroundStyle(colorThemeManager.currentThemeColor) // Use theme color
                }
                
                if averageHeartRates.isEmpty {
                    Text("No data available")
                        .font(.custom("Kurdis-ExtraWideBold", size: 20))
                        .foregroundStyle(colorThemeManager.currentThemeColor)
                        .padding()
                } else {
                    let averageHeartRate = averageHeartRates.map { $0.heartRate }.reduce(0, +) / Double(averageHeartRates.count)
                    Text("\(Int(averageHeartRate)) bpm")
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .font(.custom("Kurdis-ExtraWideBold", size: 20))
                        .foregroundStyle(colorThemeManager.currentThemeColor)
                        .padding()
                }
            }
            .padding()
        }
        .onAppear {
            // Fetch average heart rates for the last 5 climbing workouts
            HealthManager.shared.fetchAverageHeartRateForLastClimbingWorkouts { result in
                switch result {
                case .success(let data):
                    self.averageHeartRates = data
                case .failure(let error):
                    print("Error fetching heart rate data: \(error)")
                }
            }
        }
    }
}

#Preview {
    HeartRateActivityCard()
        .environmentObject(ColorThemeManager()) // Provide the ColorThemeManager for the preview
}

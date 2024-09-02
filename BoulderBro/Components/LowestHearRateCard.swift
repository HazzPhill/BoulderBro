//
//  LowestHeartRateCard.swift
//  BoulderBro
//
//  Created by [Your Name] on [Date].
//

import SwiftUI

struct LowestHeartRateCard: View {
    @State var lowestHeartRates: [(date: Date, heartRate: Double)] = []
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
                        Text("Lowest Heart Rate")
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .foregroundColor(.primary) // Adjusts automatically to light/dark mode
                        
                        Text("In last 5 climbs")
                            .foregroundColor(.secondary) // Adjusts automatically to light/dark mode
                    }
                    
                    Spacer()
                    
                    Image(systemName: "heart.slash.circle.fill")
                        .foregroundStyle(colorThemeManager.currentThemeColor) // Use theme color
                }
                
                if lowestHeartRates.isEmpty {
                    Text("No data available")
                        .font(.custom("Kurdis-ExtraWideBold", size: 20))
                        .foregroundStyle(colorThemeManager.currentThemeColor)
                        .padding()
                } else {
                    let averageLowestHeartRate = lowestHeartRates.map { $0.heartRate }.reduce(0, +) / Double(lowestHeartRates.count)
                    Text("\(Int(averageLowestHeartRate)) bpm")
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
            // Fetch lowest heart rates for the last 5 climbing workouts
            HealthManager.shared.fetchLowestHeartRateForLastClimbingWorkouts { result in
                switch result {
                case .success(let data):
                    self.lowestHeartRates = data
                case .failure(let error):
                    print("Error fetching lowest heart rate data: \(error)")
                }
            }
        }
    }
}

#Preview {
    LowestHeartRateCard()
        .environmentObject(ColorThemeManager()) // Provide the ColorThemeManager for the preview
}

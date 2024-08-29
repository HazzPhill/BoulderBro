//
//  WeeklyClimbingDuration.swift
//  BoulderBro
//
//  Created by Hazz on 28/08/2024.
//

import SwiftUI
import Charts

struct WeeklyClimbingChartView: View {
    @State private var weeklyClimbingData: [(weekStart: Date, duration: Double)] = []
    @State private var isLoading = true
    @EnvironmentObject var colorThemeManager: ColorThemeManager // Access the theme color
    @Environment(\.colorScheme) var colorScheme // To detect the current color scheme

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading climbing data...")
            } else {
                Chart {
                    ForEach(weeklyClimbingData, id: \.weekStart) { data in
                        BarMark(
                            x: .value("Week", data.weekStart, unit: .weekOfYear),
                            y: .value("Minutes Climbed", data.duration)
                        )
                        .foregroundStyle(Color(colorThemeManager.currentThemeColor))
                        .annotation(position: .top) {
                            Text("\(Int(data.duration)) mins")
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .frame(height: 125)
                .padding()
                
            }
        }
        .onAppear {
            fetchWeeklyClimbingData()
        }
    }
    
    private func fetchWeeklyClimbingData() {
        isLoading = true
        HealthManager.shared.fetchWeeklyClimbingDuration { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.weeklyClimbingData = data
                    self.isLoading = false
                case .failure(let error):
                    print("Error fetching data: \(error)")
                    self.isLoading = false
                }
            }
        }
    }
}

#Preview {
    WeeklyClimbingChartView()
}

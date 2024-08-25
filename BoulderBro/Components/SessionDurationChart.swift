//
//  SessionDurationChart.swift
//  BoulderBro
//
//  Created by Hazz on 25/08/2024.
//
import SwiftUI
import Charts

struct DurationChart: View {
    @State private var workouts: [Workout] = []
    @State private var isLoading = true
    @State private var averageDuration: Double = 0.0
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading workouts...")
            } else if workouts.isEmpty {
                Text("No climbing workouts available.")
            } else {
                Chart(workouts) { workout in
                    LineMark(
                        x: .value("Date", workout.date),
                        y: .value("Duration", Double(workout.duration.replacingOccurrences(of: " mins", with: "")) ?? 0.0)
                    )
                    .foregroundStyle(Color(hex: "#FF5733"))
                    .symbol(Circle())
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisGridLine()
                            .foregroundStyle(Color.gray.opacity(0.1))
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine()
                            .foregroundStyle(Color.gray.opacity(0.1))
                    }
                }
                .frame(height: 150)
            }
        }
        .padding()
        .onAppear {
            fetchWorkoutData()
        }
    }
    
    private func fetchWorkoutData() {
        isLoading = true
        HealthManager.shared.fetchLastTenClimbingWorkouts { result in
            switch result {
            case .success(let workouts):
                self.workouts = Array(workouts.prefix(10))  // Take the last 10 workouts
                calculateAverageDuration()
            case .failure(let error):
                print("Failed to fetch workouts: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
    
    private func calculateAverageDuration() {
        let totalDuration = workouts.reduce(0) { $0 + (Double($1.duration.replacingOccurrences(of: " mins", with: "")) ?? 0) }
        averageDuration = workouts.isEmpty ? 0.0 : totalDuration / Double(workouts.count)
    }
}

#Preview {
    DurationChart()
}

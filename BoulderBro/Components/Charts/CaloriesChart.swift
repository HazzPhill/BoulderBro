import SwiftUI
import Charts

struct CaloriesChart: View {
    @State private var workouts: [Workout] = []
    @State private var isLoading = true
    @EnvironmentObject var colorThemeManager: ColorThemeManager // Access the theme color
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading workouts...")
            } else if workouts.isEmpty {
                Text("No climbing workouts available.")
            } else {
                Chart(workouts.prefix(5).reversed()) { workout in  // Reversed order to show oldest first
                    BarMark(
                        x: .value("Date", workout.date),
                        y: .value("Calories Burned", Double(workout.calories.replacingOccurrences(of: " kcal", with: "")) ?? 0.0)
                    )
                    .foregroundStyle(colorThemeManager.currentThemeColor) // Use theme color
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
                .frame(height: 140) // Set the height to half of the original
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
                self.workouts = Array(workouts.prefix(5))  // Take only the last 5 workouts
            case .failure(let error):
                print("Failed to fetch workouts: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
}

#Preview {
    CaloriesChart()
}

import SwiftUI
import Charts

struct HeartRateChart: View {
    @State private var averageHeartRates: [(date: String, heartRate: Double)] = []
    @State private var isLoading = true
    @EnvironmentObject var colorThemeManager: ColorThemeManager // Access the theme color
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading heart rate data...")
            } else if averageHeartRates.isEmpty {
                Text("No heart rate data available.")
            } else {
                Chart {
                    ForEach(averageHeartRates.reversed(), id: \.date) { data in
                        LineMark(
                            x: .value("Date", data.date),
                            y: .value("Average Heart Rate", data.heartRate)
                        )
                        .foregroundStyle(colorThemeManager.currentThemeColor) // Use theme color
                        .symbol(Circle()) // Adds circular points on the line
                        .lineStyle(StrokeStyle(lineWidth: 2))
                    }
                }
                .chartXAxis {
                    AxisMarks(position: .bottom) // X-axis at the bottom
                }
                .chartYAxis {
                    AxisMarks(position: .leading) // Y-axis at the leading (left) edge
                }
                .frame(height: 140) // Set an appropriate height for the chart
                .padding()
            }
        }
        .onAppear {
            fetchHeartRateData()
        }
    }
    
    private func fetchHeartRateData() {
        HealthManager.shared.fetchAverageHeartRateForLastClimbingWorkouts { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let heartRates):
                    self.averageHeartRates = heartRates
                case .failure(let error):
                    print("Failed to fetch heart rate data: \(error.localizedDescription)")
                }
                self.isLoading = false
            }
        }
    }
}

#Preview {
    HeartRateChart()
}

import SwiftUI
import Charts

struct HeartRateChart: View {
    @State private var averageHeartRates: [(date: Date, heartRate: Double)] = []
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
                    ForEach(sortedHeartRates(), id: \.date) { data in
                        LineMark(
                            x: .value("Date", formattedDate(data.date)),
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
    
    private func sortedHeartRates() -> [(date: Date, heartRate: Double)] {
        return averageHeartRates.sorted { $0.date < $1.date }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d" // Display format, e.g., "Aug 26"
        return dateFormatter.string(from: date)
    }
}

#Preview {
    HeartRateChart()
}

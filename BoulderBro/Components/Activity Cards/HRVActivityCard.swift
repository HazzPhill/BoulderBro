import SwiftUI

struct HRVActivityCard: View {
    @State var hrvValues: [(date: Date, hrv: Double)] = []
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
                        Text("Heart Rate Variability")
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .foregroundColor(.primary) // Adjusts automatically to light/dark mode
                        
                        Text("Stress & Focus")
                            .foregroundColor(.secondary) // Adjusts automatically to light/dark mode
                    }
                    
                    Spacer()
                    
                    Image(systemName: "waveform.path.ecg")
                        .foregroundStyle(colorThemeManager.currentThemeColor) // Use theme color
                }
                
                if hrvValues.isEmpty {
                    Text("No data available")
                        .lineLimit(1)
                        .minimumScaleFactor(0.2)
                        .font(.custom("Kurdis-ExtraWideBold", size: 20))
                        .foregroundStyle(colorThemeManager.currentThemeColor)
                        .padding()
                } else {
                    let averageHRV = hrvValues.map { $0.hrv }.reduce(0, +) / Double(hrvValues.count)
                    Text(String(format: "%.2f ms", averageHRV))
                        .lineLimit(1)
                        .minimumScaleFactor(0.2)
                        .font(.custom("Kurdis-ExtraWideBold", size: 20))
                        .foregroundStyle(colorThemeManager.currentThemeColor)
                        .padding()
                    
                    // Determine stress and focus level based on average HRV
                    if averageHRV < 50 {
                        Text("High Stress Detected")
                            .foregroundColor(.red)
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                    } else if averageHRV >= 50 && averageHRV < 80 {
                        Text("Medium Stress")
                            .foregroundColor(.orange)
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                    } else {
                        Text("Low Stress & High Focus")
                            .foregroundColor(.green)
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            // Fetch recent HRV data
            HealthManager.shared.fetchRecentHRVData { result in
                switch result {
                case .success(let data):
                    if data.isEmpty {
                        print("HRV data is empty despite successful fetch.")
                    } else {
                        print("HRV Data fetched successfully: \(data)")
                    }
                    self.hrvValues = data
                case .failure(let error):
                    print("Error fetching HRV data: \(error)")
                }
            }
        }
    }
}

#Preview {
    HRVActivityCard()
        .environmentObject(ColorThemeManager()) // Provide the ColorThemeManager for the preview
}

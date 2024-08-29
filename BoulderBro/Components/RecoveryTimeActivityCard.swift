import SwiftUI

struct RecoveryTimeActivityCard: View {
    @State var recoveryTimes: [(date: Date, recoveryTime: TimeInterval)] = []
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
                        Text("Recovery Time")
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .foregroundColor(.primary) // Adjusts automatically to light/dark mode
                        
                        Text("Suggested Recovery Time")
                            .foregroundColor(.secondary) // Adjusts automatically to light/dark mode
                    }
                    
                    Spacer()
                    
                    Image(systemName: "bed.double.fill")
                        .foregroundStyle(colorThemeManager.currentThemeColor) // Use theme color
                }
                
                if recoveryTimes.isEmpty {
                    Text("No data available")
                        .font(.custom("Kurdis-ExtraWideBold", size: 20))
                        .foregroundStyle(colorThemeManager.currentThemeColor)
                        .padding()
                } else {
                    let lastRecoveryTime = recoveryTimes.last?.recoveryTime ?? 0
                    let hours = Int(lastRecoveryTime) / 3600
                    let minutes = (Int(lastRecoveryTime) % 3600) / 60
                    
                    // Display the recovery time in hours and minutes
                    if hours > 0 {
                        Text("\(hours) hrs \(minutes) mins")
                            .font(.custom("Kurdis-ExtraWideBold", size: 20))
                            .foregroundStyle(colorThemeManager.currentThemeColor)
                            .padding()
                    } else {
                        Text("\(minutes) mins")
                            .font(.custom("Kurdis-ExtraWideBold", size: 20))
                            .foregroundStyle(colorThemeManager.currentThemeColor)
                            .padding()
                    }
                }
            }
            .padding()
        }
        .onAppear {
            // Fetch recovery times for the last 5 climbing workouts
            HealthManager.shared.estimateRecoveryTimeForLastClimbingWorkouts { result in
                switch result {
                case .success(let data):
                    self.recoveryTimes = data
                case .failure(let error):
                    print("Error fetching recovery time data: \(error)")
                }
            }
        }
    }
}

#Preview {
    RecoveryTimeActivityCard()
        .environmentObject(ColorThemeManager()) // Provide the ColorThemeManager for the preview
}

import SwiftUI

struct HangTimer: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isRunning = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var lastTime: TimeInterval = 0
    @State private var personalBest: TimeInterval = 0
    @State private var timer: Timer?
    @State private var countdown: Int?
    @EnvironmentObject var colorThemeManager: ColorThemeManager // Access the theme color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Rectangle()
                .frame(height: 165)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#333333") : .white))
                .overlay(
                    ZStack {
                        if let countdown = countdown {
                            Text(countdown > 0 ? "\(countdown)" : "Go!")
                                .font(.custom("Kurdis-ExtraWideBold", size: 60))
                                .foregroundStyle(colorThemeManager.currentThemeColor) // Use theme color
                        } else {
                            HStack {
                                // Timer display on the left with fixed width
                                Text(timeString(from: elapsedTime))
                                    .font(.custom("Kurdis-ExtraWideBold", size: 22))
                                    .foregroundStyle(Color(colorScheme == .dark ? .white : .black))
                                    .frame(width: 150, alignment: .leading)  // Fixed width for timer display
                                
                                Spacer()
                                
                                // Play/Stop button in the middle
                                Button(action: {
                                    if !isRunning {
                                        startCountdown()
                                    } else {
                                        toggleTimer()
                                    }
                                }) {
                                    Image(systemName: isRunning ? "stop.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundStyle(colorThemeManager.currentThemeColor) // Use theme color
                                }
                                
                                Spacer()
                                
                                // Personal Best and Last Time on the right
                                VStack(alignment: .trailing, spacing: 8) {
                                    VStack(alignment: .trailing) {
                                        Text("Personal Best")
                                            .font(.custom("Kurdis-regular", size: 11))
                                            .foregroundStyle(Color.gray)
                                        Text(timeString(from: personalBest))
                                            .font(.custom("Kurdis-ExtraWideBold", size: 10))
                                            .foregroundStyle(Color.primary)
                                    }
                                    VStack(alignment: .trailing) {
                                        Text("Last Time")
                                            .font(.custom("Kurdis-regular", size: 11))
                                            .foregroundStyle(Color.gray)
                                        Text(timeString(from: lastTime))
                                            .font(.custom("Kurdis-ExtraWideBold", size: 10))
                                            .foregroundStyle(Color.primary)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                )
        }
    }

    // Helper function to format time as minutes:seconds:milliseconds
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        let milliseconds = Int((timeInterval - floor(timeInterval)) * 100)
        return String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
    }

    // Function to toggle the timer state
    private func toggleTimer() {
        if isRunning {
            timer?.invalidate()
            timer = nil
            isRunning = false
            lastTime = elapsedTime
            if elapsedTime > personalBest {
                personalBest = elapsedTime
            }
            elapsedTime = 0
        } else {
            isRunning = true
            startTimer()
        }
    }

    // Function to start the timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            elapsedTime += 0.01
        }
    }

    // Function to start the countdown
    private func startCountdown() {
        countdown = 3 // Start countdown from 3
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if countdown == 0 {
                countdown = nil
                toggleTimer() // Start the timer after the countdown
                timer.invalidate()
            } else {
                countdown? -= 1
            }
        }
    }
}

#Preview {
    HangTimer()
}

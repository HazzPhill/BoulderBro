import SwiftUI

// RestTimer View
struct RestTimer: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var remainingTime: TimeInterval = 150 // 2:30 minutes in seconds
    @State private var isRunning = false
    @State private var timer: Timer?
    @State private var countdown: Int?
    @State private var tipIndex: Int = 0
    @State private var tipTimer: Timer?
    
    @AppStorage("restTimerCountdownLength") private var restTimerCountdownLength: Int = 3 // Default to 3 seconds
    @EnvironmentObject var colorThemeManager: ColorThemeManager // Access the theme color

    // List of tips for resting between climbs
    let tips = [
        "Shake out your arms and legs to relax your muscles.",
        "Focus on deep, slow breathing.",
        "Visualize your next climb or moves.",
        "Stay hydrated—drink some water.",
        "Stretch gently to stay limber.",
        "Check your chalk and reapply if necessary."
    ]
    
    @State private var showNextTip = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#333333") : .white))
                .overlay(
                    ZStack {
                        if let countdown = countdown {
                            // Countdown display
                            Text(countdown > 0 ? "\(countdown)" : "Rest!")
                                .font(.custom("Kurdis-ExtraWideBold", size: 60))
                                .foregroundStyle(colorThemeManager.currentThemeColor)
                                .padding(.horizontal, 20)
                        } else {
                            VStack(spacing: 8) {
                                HStack {
                                    // Timer display on the left
                                    Text(timeString(from: remainingTime))
                                        .font(.custom("Kurdis-ExtraWideBold", size: 30))
                                        .foregroundStyle(Color(colorScheme == .dark ? .white : .black))
                                        .frame(alignment: .leading)
                                    
                                    Spacer()

                                    // Play/Stop button in the middle
                                    Button(action: {
                                        if !isRunning {
                                            startCountdown()
                                        } else {
                                            resetTimer()
                                        }
                                    }) {
                                        Image(systemName: isRunning ? "stop.circle.fill" : "play.circle.fill")
                                            .font(.system(size: 40))
                                            .foregroundStyle(colorThemeManager.currentThemeColor)
                                    }
                                    .padding(.trailing, 20) // Adjust padding on the right side
                                }
                                .padding(.horizontal, 20) // Adjust horizontal padding for better spacing
                                
                                // Rotating tip text with scrolling animation
                                if isRunning {
                                    ZStack {
                                        ForEach(0..<tips.count, id: \.self) { index in
                                            if index == tipIndex || index == (tipIndex + 1) % tips.count {
                                                Text(tips[index])
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.5)
                                                    .font(.custom("Kurdis-regular", size: 16))
                                                    .padding(.horizontal)
                                                    .foregroundStyle(Color.gray)
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                                    .offset(y: index == tipIndex ? (showNextTip ? -20 : 0) : (showNextTip ? 0 : 20))
                                                    .opacity(index == tipIndex ? (showNextTip ? 0 : 1) : (showNextTip ? 1 : 0))
                                            }
                                        }
                                    }
                                    .frame(height: 20)
                                    .animation(.easeInOut(duration: 0.6), value: showNextTip)
                                }
                            }
                        }
                    }
                )
        }
        .onAppear {
            startTipRotation()
        }
        .onDisappear {
            stopTipRotation()
        }
    }
    
    // Helper function to format time as minutes:seconds
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Function to start the countdown
    private func startCountdown() {
        countdown = restTimerCountdownLength // Use the user-defined countdown length
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if countdown == 0 {
                countdown = nil
                startTimer()
                timer.invalidate()
            } else {
                countdown? -= 1
            }
        }
    }
    
    // Function to start the timer
    private func startTimer() {
        isRunning = true
        startTipRotation() // Start rotating tips when the main timer starts
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                resetTimer()
            }
        }
    }
    
    // Function to reset the timer
    private func resetTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        remainingTime = 150 // Reset to 2:30 minutes
        stopTipRotation()
    }
    
    // Function to start rotating tips
    private func startTipRotation() {
        stopTipRotation() // Stop any existing timer
        tipTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            withAnimation {
                showNextTip = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                tipIndex = (tipIndex + 1) % tips.count
                showNextTip = false
            }
        }
    }
    
    // Function to stop rotating tips
    private func stopTipRotation() {
        tipTimer?.invalidate()
        tipTimer = nil
    }
}

// Preview the RestTimer View
struct RestTimer_Previews: PreviewProvider {
    static var previews: some View {
        RestTimer()
            .environmentObject(ColorThemeManager()) // Assuming you have a color theme manager
    }
}

#Preview {
    RestTimer()
}

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// HangTimer View with Firebase Integration
struct HangTimer: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authViewModel: AuthViewModel // Inject AuthViewModel
    
    @State private var isRunning = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var lastTime: TimeInterval = 0
    @State private var personalBest: TimeInterval = 0
    @State private var monthlyBest: TimeInterval = 0
    @State private var timer: Timer?
    @State private var countdown: Int?
    @EnvironmentObject var colorThemeManager: ColorThemeManager // Access the theme color
    @AppStorage("hangTimerCountdownLength") private var hangTimerCountdownLength: Int = 3 // Default countdown length for HangTimer
    
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
                                .foregroundStyle(colorThemeManager.currentThemeColor)
                        } else {
                            HStack {
                                // Timer display on the left with fixed width
                                Text(timeString(from: elapsedTime))
                                    .font(.custom("Kurdis-ExtraWideBold", size: 22))
                                    .foregroundStyle(Color(colorScheme == .dark ? .white : .black))
                                    .frame(width: 150, alignment: .leading)
                                
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
                                        .foregroundStyle(colorThemeManager.currentThemeColor)
                                }
                                
                                Spacer()
                                
                                // Personal Best, Monthly Best, and Last Time on the right
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
                                        Text("Monthly Best")
                                            .font(.custom("Kurdis-regular", size: 11))
                                            .foregroundStyle(Color.gray)
                                        Text(timeString(from: monthlyBest))
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
        .onAppear {
            fetchPersonalBests()
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
                savePersonalBest()
            }
            let currentMonth = Calendar.current.component(.month, from: Date())
            if elapsedTime > monthlyBest && isCurrentMonth(currentMonth) {
                monthlyBest = elapsedTime
                saveMonthlyBest()
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
        countdown = hangTimerCountdownLength // Start countdown based on user selection for HangTimer
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

    // Function to check if the current month is the same as the stored month
    private func isCurrentMonth(_ storedMonth: Int) -> Bool {
        let currentMonth = Calendar.current.component(.month, from: Date())
        return storedMonth == currentMonth
    }

    // Function to save the personal best to Firestore
    private func savePersonalBest() {
        guard let userId = authViewModel.userSession?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData([
            "personalBest": personalBest
        ], merge: true) { error in
            if let error = error {
                print("Error saving personal best: \(error)")
            } else {
                print("Personal best saved successfully!")
            }
        }
    }

    // Function to save the monthly best to Firestore and Leaderboard
    private func saveMonthlyBest() {
        guard let userId = authViewModel.userSession?.uid else { return }
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        let leaderboardId = "\(currentYear)_\(currentMonth)"
        
        let db = Firestore.firestore()
        
        // Get the current user's username from the AuthViewModel
        let username = authViewModel.currentUser?.username ?? "Anonymous"

        // Save to user's document
        db.collection("users").document(userId).setData([
            "monthlyBest": [
                "month": currentMonth,
                "bestTime": monthlyBest
            ]
        ], merge: true) { error in
            if let error = error {
                print("Error saving monthly best: \(error)")
            } else {
                print("Monthly best saved successfully!")
            }
        }

        // Save to leaderboard
        db.collection("leaderboards").document(leaderboardId).setData([
            userId: [
                "username": username,
                "bestTime": monthlyBest
            ]
        ], merge: true) { error in
            if let error = error {
                print("Error saving to leaderboard: \(error)")
            } else {
                print("Leaderboard updated successfully!")
            }
        }
    }

    // Function to fetch the personal bests from Firestore
    private func fetchPersonalBests() {
        guard let userId = authViewModel.userSession?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching personal bests: \(error)")
            } else if let document = document, document.exists {
                if let data = document.data() {
                    self.personalBest = data["personalBest"] as? TimeInterval ?? 0
                    if let monthlyBestData = data["monthlyBest"] as? [String: Any],
                       let month = monthlyBestData["month"] as? Int,
                       self.isCurrentMonth(month) {
                        self.monthlyBest = monthlyBestData["bestTime"] as? TimeInterval ?? 0
                    }
                }
            }
        }
    }
}

// Preview the HangTimer View
struct HangTimer_Previews: PreviewProvider {
    static var previews: some View {
        HangTimer()
            .environmentObject(AuthViewModel()) // Inject AuthViewModel into the preview
            .environmentObject(ColorThemeManager()) // Assuming you have a color theme manager
    }
}

#Preview {
    HangTimer()
}

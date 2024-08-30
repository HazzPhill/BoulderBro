//
//  HangTimerLeaderBoard.swift
//  BoulderBro
//
//  Created by Hazz on 30/08/2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// Model for Leaderboard Entries
struct LeaderboardEntry {
    let username: String
    let bestTime: TimeInterval
}

// Leaderboard View
struct LeaderboardView: View {
    @State private var leaderboard: [LeaderboardEntry] = []

    var body: some View {
        List(leaderboard, id: \.username) { entry in
            HStack {
                Text(entry.username)
                    .font(.headline)
                Spacer()
                Text(timeString(from: entry.bestTime))
                    .font(.subheadline)
            }
        }
        .onAppear {
            fetchLeaderboard { leaderboardEntries in
                self.leaderboard = leaderboardEntries
            }
        }
        .navigationTitle("Leaderboard")
    }

    // Helper function to format time as minutes:seconds:milliseconds
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        let milliseconds = Int((timeInterval - floor(timeInterval)) * 100)
        return String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
    }

    // Fetch the leaderboard from Firestore
    private func fetchLeaderboard(completion: @escaping ([LeaderboardEntry]) -> Void) {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        let leaderboardId = "\(currentYear)_\(currentMonth)"
        
        let db = Firestore.firestore()
        
        db.collection("leaderboards").document(leaderboardId).getDocument { document, error in
            if let error = error {
                print("Error fetching leaderboard: \(error)")
                completion([])
            } else if let document = document, document.exists {
                if let data = document.data() {
                    let leaderboardEntries = data.compactMap { (userId, value) -> LeaderboardEntry? in
                        if let userData = value as? [String: Any],
                           let username = userData["username"] as? String,
                           let bestTime = userData["bestTime"] as? Double {
                            return LeaderboardEntry(username: username, bestTime: bestTime)
                        }
                        return nil
                    }
                    .sorted(by: { $0.bestTime > $1.bestTime }) // Sort by best time
                    completion(leaderboardEntries)
                } else {
                    completion([])
                }
            }
        }
    }
}


#Preview {
    LeaderboardView()
}

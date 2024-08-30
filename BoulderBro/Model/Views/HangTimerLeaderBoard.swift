import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// Model for Leaderboard Entries
struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let username: String
    let bestTime: TimeInterval
    let position: Int // Added position property to store original position
}

// Leaderboard View
struct LeaderboardView: View {
    @State private var leaderboard: [LeaderboardEntry] = []
    @State private var searchText: String = ""
    @State private var isSearchBarVisible: Bool = false // State variable to toggle search bar visibility
    @Environment(\.colorScheme) var colorScheme // To detect the current color scheme
    @EnvironmentObject var colorThemeManager: ColorThemeManager // Access the theme color
    
    // Filtered leaderboard with original positions retained
    var filteredLeaderboard: [LeaderboardEntry] {
        if searchText.isEmpty {
            return leaderboard
        } else {
            return leaderboard.filter { $0.username.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        ZStack {
            // Use customizable MovingCircles component as the background
            MovingCircles(
                topCircleColor: colorThemeManager.currentThemeColor,
                bottomCircleColor: colorThemeManager.currentThemeColor,
                topCircleOpacity: 0.2,
                bottomCircleOpacity: 0.2,
                backgroundColor: colorScheme == .dark ? Color(hex: "#1f1f1f") : Color(hex: "#f1f0f5")
            )
            .zIndex(-1) // Ensure the circles and background are behind other content
            
            VStack(alignment: .center, spacing: 16) {
                Text("Learboard")
                    .font(.custom("Kurdis-ExtraWideBold", size: 32))
                    .padding(.top, 16)
                Text("Leaderboard of longest hang time this month")
                    .font(.custom("Kurdis-Regular", size: 16))
                
                // Search Bar Toggle
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            isSearchBarVisible.toggle() // Toggle search bar visibility
                        }
                    }) {
                        Image(systemName: isSearchBarVisible ? "xmark.circle.fill" : "magnifyingglass")
                            .font(.title)
                            .foregroundColor(colorThemeManager.currentThemeColor)
                    }
                    .padding(.trailing, 16)
                }
                
                // Expandable Search Bar
                if isSearchBarVisible {
                    HStack {
                        TextField("Search by username", text: $searchText)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .transition(.move(edge: .top)) // Smooth transition for appearance
                }
                
                // Scrollable Leaderboard
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(filteredLeaderboard) { entry in
                            if entry.position <= 3 {
                                TopThreeLeaderboardRow(entry: entry, position: entry.position)
                            } else {
                                RegularLeaderboardRow(entry: entry, position: entry.position)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                Spacer()
            }
            .onAppear {
                fetchLeaderboard { leaderboardEntries in
                    self.leaderboard = leaderboardEntries.enumerated().map { index, entry in
                        LeaderboardEntry(username: entry.username, bestTime: entry.bestTime, position: index + 1)
                    }
                }
            }
        }
        .background(Color.clear.ignoresSafeArea()) // Ensures MovingCircles background is visible
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
                            return LeaderboardEntry(username: username, bestTime: bestTime, position: 0) // Temporary position
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

// Top 3 Leaderboard Row
struct TopThreeLeaderboardRow: View {
    let entry: LeaderboardEntry
    let position: Int
    @Environment(\.colorScheme) var colorScheme // To detect the current color scheme
    @EnvironmentObject var colorThemeManager: ColorThemeManager // Access the theme color
    
    var positionColor: Color {
        switch position {
        case 1: return colorThemeManager.currentThemeColor
        case 2: return colorThemeManager.currentThemeColor.opacity(0.8)
        case 3: return colorThemeManager.currentThemeColor.opacity(0.5)
        default: return Color.gray
        }
    }
    
    var positionLabel: String {
        switch position {
        case 1: return "1ST"
        case 2: return "2ND"
        case 3: return "3RD"
        default: return "\(position)TH"
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Position Box
            Text(positionLabel)
                .font(.custom("Kurdis-ExtraWideBold", size: positionLabelFontSize))
                .foregroundColor(.primary)
                .frame(width: 60, height: 50, alignment: .center) // Fixed width box for position
                .background(positionColor)
                .cornerRadius(12)
                .minimumScaleFactor(0.2)
                .lineLimit(1)
            
            // Name and Time Box
            HStack(spacing: 0) {
                Text(entry.username.uppercased())
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .font(.custom("Kurdis-ExtraWideBold", size: 16))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                    .padding(.trailing, 8) // Padding between name and separator
                
                Divider()
                    .frame(width: 1, height: 25)
                    .background(Color.white)
                
                Text(timeString(from: entry.bestTime))
                    .font(.custom("Kurdis-ExtraWideBold", size: 16))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 16)
            }
            .frame(height: 50)
            .background(positionColor)
            .cornerRadius(12)
        }
    }
    
    var positionLabelFontSize: CGFloat {
        return positionLabel.count > 3 ? 14 : 16
    }
}

// Regular Leaderboard Row
struct RegularLeaderboardRow: View {
    let entry: LeaderboardEntry
    let position: Int
    @Environment(\.colorScheme) var colorScheme // To detect the current color scheme
    @EnvironmentObject var colorThemeManager: ColorThemeManager // Access the theme color
    
    var body: some View {
        HStack(spacing: 16) {
            // Position Box
            Text("\(position)TH")
                .font(.custom("Kurdis-ExtraWideBold", size: positionFontSize(for: position)))
                .foregroundColor(.primary)
                .frame(width: 60, height: 50, alignment: .center) // Fixed width box for position
                .background(Color(colorScheme == .dark ? Color(hex: "#333333") : .white))
                .cornerRadius(12)
                .minimumScaleFactor(0.2)
                .lineLimit(1)
            
            // Name and Time Box
            HStack(spacing: 0) {
                Text(entry.username.uppercased())
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .font(.custom("Kurdis-ExtraWideBold", size: 16))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                    .padding(.trailing, 8) // Padding between name and separator
                
                Divider()
                    .frame(width: 1, height: 25)
                    .background(Color.white)
                
                Text(timeString(from: entry.bestTime))
                    .font(.custom("Kurdis-ExtraWideBold", size: 16))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 16)
            }
            .frame(height: 50)
            .background(Color(colorScheme == .dark ? Color(hex: "#333333") : .white))
            .cornerRadius(12)
        }
    }
    
    func positionFontSize(for position: Int) -> CGFloat {
        return "\(position)TH".count > 3 ? 14 : 16
    }
}

// Helper function to format time as minutes:seconds:milliseconds
private func timeString(from timeInterval: TimeInterval) -> String {
    let minutes = Int(timeInterval) / 60
    let seconds = Int(timeInterval) % 60
    let milliseconds = Int((timeInterval - floor(timeInterval)) * 100)
    return String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
}

// Preview the Leaderboard View
#Preview {
    LeaderboardView()
}

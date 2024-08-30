import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import HealthKit

// Model for Leaderboard Entries (Minutes Climbed)
struct MinutesClimbedLeaderboardEntry: Identifiable {
    let id = UUID()
    let username: String
    let totalMinutes: Double
    let position: Int
}

// Leaderboard View for Minutes Climbed
struct MinutesClimbedLeaderboardView: View {
    @State private var leaderboard: [MinutesClimbedLeaderboardEntry] = []
    @State private var searchText: String = ""
    @State private var isSearchBarVisible: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var colorThemeManager: ColorThemeManager
    
    // Filtered leaderboard with original positions retained
    var filteredLeaderboard: [MinutesClimbedLeaderboardEntry] {
        if searchText.isEmpty {
            return leaderboard
        } else {
            return leaderboard.filter { $0.username.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        ZStack {
            // Custom background
            MovingCircles(
                topCircleColor: colorThemeManager.currentThemeColor,
                bottomCircleColor: colorThemeManager.currentThemeColor,
                topCircleOpacity: 0.2,
                bottomCircleOpacity: 0.2,
                backgroundColor: colorScheme == .dark ? Color(hex: "#1f1f1f") : Color(hex: "#f1f0f5")
            )
            .zIndex(-1)
            
            VStack(alignment: .center, spacing: 16) {
                VStack (alignment: .leading, spacing: 16) {
                Text("Learboard")
                    .frame(alignment: .leading)
                    .font(.custom("Kurdis-ExtraWideBold", size: 32))
                    .padding(.top, 16)
                Text("Leaderboard of minutes climbed this month")
                    .font(.custom("Kurdis-Regular", size: 16))
                    .frame(alignment: .leading)
            }
                
                // Search Bar Toggle
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            isSearchBarVisible.toggle()
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
                    .transition(.move(edge: .top))
                }
                
                // Scrollable Leaderboard
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(filteredLeaderboard) { entry in
                            if entry.position <= 3 {
                                TopThreeMinutesClimbedRow(entry: entry, position: entry.position)
                            } else {
                                RegularMinutesClimbedRow(entry: entry, position: entry.position)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                Spacer()
            }
            .onAppear {
                // Update climbing minutes for the current user
                if let currentUser = Auth.auth().currentUser {
                    HealthManager.shared.fetchAndStoreMonthlyClimbingMinutes(for: currentUser.uid)
                }
                fetchLeaderboard()
            }
        }
        .background(Color.clear.ignoresSafeArea())
    }
    
    // Fetch the leaderboard from Firestore and calculate positions
    private func fetchLeaderboard() {
        let db = Firestore.firestore()
        
        db.collection("users").getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching users: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No user documents found.")
                return
            }
            
            var leaderboardEntries: [MinutesClimbedLeaderboardEntry] = []
            
            for document in documents {
                let username = document.data()["username"] as? String ?? "Unknown User"
                let totalMinutes = document.data()["monthlyClimbingMinutes"] as? Double ?? 0
                
                let entry = MinutesClimbedLeaderboardEntry(username: username, totalMinutes: totalMinutes, position: 0)
                leaderboardEntries.append(entry)
            }
            
            // Sort the leaderboard by totalMinutes in descending order
            leaderboardEntries.sort { $0.totalMinutes > $1.totalMinutes }
            
            // Assign positions
            leaderboard = leaderboardEntries.enumerated().map { index, entry in
                MinutesClimbedLeaderboardEntry(username: entry.username, totalMinutes: entry.totalMinutes, position: index + 1)
            }
        }
    }
}

// Top 3 Leaderboard Row for Minutes Climbed
struct TopThreeMinutesClimbedRow: View {
    let entry: MinutesClimbedLeaderboardEntry
    let position: Int
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var colorThemeManager: ColorThemeManager
    
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
            Text(positionLabel)
                .font(.custom("Kurdis-ExtraWideBold", size: positionLabelFontSize))
                .foregroundColor(.primary)
                .frame(width: 60, height: 50, alignment: .center)
                .background(positionColor)
                .cornerRadius(12)
                .minimumScaleFactor(0.2)
                .lineLimit(1)
            
            HStack(spacing: 0) {
                Text(entry.username.uppercased())
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .font(.custom("Kurdis-ExtraWideBold", size: 16))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                    .padding(.trailing, 8)
                
                Divider()
                    .frame(width: 1, height: 25)
                    .background(Color.white)
                
                Text("\(Int(entry.totalMinutes)) MIN")
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

// Regular Leaderboard Row for Minutes Climbed
struct RegularMinutesClimbedRow: View {
    let entry: MinutesClimbedLeaderboardEntry
    let position: Int
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var colorThemeManager: ColorThemeManager
    
    var body: some View {
        HStack(spacing: 16) {
            Text("\(position)TH")
                .font(.custom("Kurdis-ExtraWideBold", size: positionFontSize(for: position)))
                .foregroundColor(.primary)
                .frame(width: 60, height: 50, alignment: .center)
                .background(Color(colorScheme == .dark ? Color(hex: "#333333") : .white))
                .cornerRadius(12)
                .minimumScaleFactor(0.2)
                .lineLimit(1)
            
            HStack(spacing: 0) {
                Text(entry.username.uppercased())
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .font(.custom("Kurdis-ExtraWideBold", size: 16))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                    .padding(.trailing, 8)
                
                Divider()
                    .frame(width: 1, height: 25)
                    .background(Color.white)
                
                Text("\(Int(entry.totalMinutes)) MIN")
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

// Preview the Leaderboard View
#Preview {
    MinutesClimbedLeaderboardView()
}

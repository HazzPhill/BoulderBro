import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Charts

struct MyClimbsView: View {
    @Environment(\.colorScheme) var colorScheme

    @EnvironmentObject var viewModel: AuthViewModel
    @State private var climbs: [Climb] = []
    @State private var isLoading = true // Track loading state
    @EnvironmentObject var colorThemeManager: ColorThemeManager // Access the theme color
    
    var body: some View {
        if let user = viewModel.currentUser {
            NavigationStack {
                ZStack {
                    // Use customizable MovingCircles
                    MovingCircles(
                        topCircleColor: colorThemeManager.currentThemeColor,
                        bottomCircleColor: colorThemeManager.currentThemeColor,
                        topCircleOpacity: 0.3,
                        bottomCircleOpacity: 0.3,
                        backgroundColor: Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color(hex: "#f1f0f5"))
                    )
                    .ignoresSafeArea()

                    // Content of the view
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(" \(user.firstName)'s Personal Logbook")
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .font(.custom("Kurdis-ExtraWideBlack", size: 30))
                                .fontWeight(.bold)
                                .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))
                                .opacity(0.7)
                                .padding(.top, 30)

                            CurrentLevel()
                            
                            Text("Difficulty Progress")
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .font(.custom("Kurdis-ExtraWideBold", size: 20))
                                .fontWeight(.bold)
                                .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))
                                .opacity(0.7)
                                .padding(.top, 5)
                            
                            Text("Last 20 completed climbs with their V rating")
                                .font(.custom("Kurdis-Regular", size: 11))
                                .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))
                                .opacity(0.7)

                            if isLoading {
                                ProgressView() // Activity indicator while loading
                            } else {
                                // Rectangle with a chart inside showing last 20 climbs
                                Rectangle()
                                    .fill(Color(colorScheme == .dark ? Color(hex: "#333333") : .white))
                                    .cornerRadius(12)
                                    .overlay(
                                        Chart {
                                            ForEach(Array(climbs.suffix(20).enumerated()), id: \.element.id) { index, climb in
                                                LineMark(
                                                    x: .value("Climb Number", index + 1),
                                                    y: .value("V Rating", parseVRating(climb.vRating))
                                                )
                                                .foregroundStyle(colorThemeManager.currentThemeColor)
                                                .symbol(Circle()) // Adding symbol to each data point

                                                // Label for each point
                                                .annotation(position: .top) {
                                                    Text("\(parseVRating(climb.vRating))")
                                                        .font(.caption)
                                                        .foregroundColor(.black)
                                                }
                                            }
                                        }
                                        .padding() // Adjust padding for better chart layout
                                    )
                                    .frame(height: 150)
                                    .padding(.bottom, 10) // Optional: Add some padding below the chart
                                
                                Rectangle()
                                    .fill(Color(colorScheme == .dark ? Color(hex: "#333333") : .white))
                                    .cornerRadius(12)
                                    .overlay(
                                        WeeklyClimbingChartView()
                                            .padding()
                                    )
                                    .frame(height: 150) // Adjust the height as needed
                                    .padding(.bottom, 10) // Optional: Add some padding below the chart
                                
                                Text(" \(user.firstName)'s Climbs")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .font(.custom("Kurdis-ExtraWideBold", size: 20))
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))
                                    .opacity(0.7)
                                    .padding(.top, 5)
                                    .padding(.bottom, 5)

                                // List of uploaded climbs (limited to last 10)
                                ForEach(climbs.suffix(3)) { climb in
                                    NavigationLink(destination: TheClimb(climb: climb)) {
                                        PersonalClimb(climb: climb)
                                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                    }
                                }
                                NavigationLink(destination: AllClimbsView(climbs: climbs)) {
                                    Text("Show More")
                                        .font(.custom("Kurdis-ExtraWideBold", size: 16))
                                        .foregroundStyle(Color.white)
                                        .padding()
                                }
                                .background(Color.gray)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom,40)
                    }
                }
                .onAppear(perform: fetchClimbs)
            }
        }
    }

    // Function to parse V rating from String to Int
    func parseVRating(_ rating: String) -> Int {
        // Assuming the rating format is like "V5", extract the number
        return Int(rating.trimmingCharacters(in: CharacterSet.letters)) ?? 0
    }

    // Fetch the climbs from Firestore
    func fetchClimbs() {
        isLoading = true

        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: User is not logged in.")
            isLoading = false
            return
        }

        let db = Firestore.firestore()
        db.collection("climbs").whereField("userId", isEqualTo: uid).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching documents: \(error)")
                isLoading = false
                return
            }
            if let snapshot = snapshot {
                climbs = snapshot.documents.map { doc in
                    Climb(
                        id: doc.documentID,
                        name: doc["name"] as? String ?? "No Name",
                        climbtype: doc["climbtype"] as? String ?? "No Climb Type",
                        difficulty: doc["difficulty"] as? String ?? "No Difficulty",
                        vRating: doc["vRating"] as? String ?? "No V Rating",
                        mediaURL: doc["mediaURL"] as? String ?? ""
                    )
                }
            }
            isLoading = false
        }
    }
}

#Preview {
    MyClimbsView()
        .environmentObject(AuthViewModel()) // Ensure the environment object is provided for the preview
}

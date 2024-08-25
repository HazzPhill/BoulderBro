import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct MyClimbsView: View {
    @Environment(\.colorScheme) var colorScheme

    @EnvironmentObject var viewModel: AuthViewModel
    @State private var climbs: [Climb] = []
    @State private var isLoading = true // Track loading state

    var body: some View {
        if let user = viewModel.currentUser {
            NavigationStack {
                ZStack {
                    // Use customizable MovingCircles
                    MovingCircles(
                        topCircleColor: Color(hex: "#FF5733"),
                        bottomCircleColor: Color(hex: "#FF5733"),
                        topCircleOpacity: 0.3,
                        bottomCircleOpacity: 0.3,
                        backgroundColor: Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color(hex: "#f1f0f5"))
                        
                    )
                    .ignoresSafeArea()

                    // Content of the view
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(" \(user.firstName)'s Climbs")
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .font(.custom("Kurdis-ExtraWideBlack", size: 30))
                                .fontWeight(.bold)
                                .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))
                                .opacity(0.7)
                                .padding(.top, 30)
                                .padding(.bottom, 15)

                            CurrentLevel()

                            HStack {
                                NavigationLink(destination: MyClimbsViewController()) {
                                    Image(systemName: "plus.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(Color(hex:"#0093AA"))
                                        .frame(width: 45, height: 45)
                                }

                                Image(systemName: "heart.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color(hex:"#0093AA"))
                                    .frame(width: 45, height: 45)

                                Spacer()

                                Button {
                                    print("View All")
                                } label: {
                                    Text("View all")
                                        .font(.custom("Kurdis-ExtraWideBold", size: 16))
                                        .foregroundStyle(Color.white)
                                        .padding()
                                        .background(Color.gray)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                            }

                            if isLoading {
                                ProgressView() // Activity indicator while loading
                            } else {
                                // List of uploaded climbs
                                ForEach(climbs) { climb in
                                    NavigationLink(destination: TheClimb(climb: climb)) {
                                        PersonalClimb(climb: climb)
                                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .onAppear(perform: fetchClimbs)
            }
        }
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
                        location: doc["location"] as? String ?? "No Location",
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

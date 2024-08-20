import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct MyClimbsView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var topCircleOffset = CGSize(width: 150, height: -300)
    @State private var bottomCircleOffset = CGSize(width: -150, height: 250)
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var climbs: [Climb] = [] // State for storing the list of climbs
    
    var body: some View {
        if let user = viewModel.currentUser {
            NavigationStack {
                ZStack {
                    // Background color
                    Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color(hex: "#f1f0f5"))
                        .ignoresSafeArea()
                        .zIndex(-2)
                    
                    // Top circle
                    Circle()
                        .fill(Color(hex: "#FF5733")).opacity(0.3)
                        .frame(width: 350, height: 350)
                        .blur(radius: 60)
                        .offset(topCircleOffset)
                        .opacity(0.5)
                        .zIndex(-1)
                    
                    // Bottom circle
                    Circle()
                        .fill(Color(hex: "#FF5733")).opacity(0.3)
                        .frame(width: 350, height: 500)
                        .blur(radius: 60)
                        .offset(bottomCircleOffset)
                        .opacity(0.5)
                        .zIndex(-1)
                    
                    // Animate circle offsets
                    .onReceive(timer) { _ in
                        withAnimation(.linear(duration: 0.9)) {
                            let newTopOffset = CGSize(
                                width: max(50, min(UIScreen.main.bounds.width - 300, topCircleOffset.width + CGFloat.random(in: -50...50))),
                                height: max(-250, min(-50, topCircleOffset.height + CGFloat.random(in: -25...25)))
                            )
                            let newBottomOffset = CGSize(
                                width: max(-200, min(UIScreen.main.bounds.width - 300, bottomCircleOffset.width + CGFloat.random(in: -50...50))),
                                height: max(50, min(UIScreen.main.bounds.height - 450, bottomCircleOffset.height + CGFloat.random(in: -25...25)))
                            )
                            
                            topCircleOffset = newTopOffset
                            bottomCircleOffset = newBottomOffset
                        }
                    }
                    
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
                            
                            // List of uploaded climbs
                            ForEach(climbs) { climb in
                                NavigationLink(destination: TheClimb(climb: climb)) {
                                    PersonalClimb(climb: climb)
                                        .padding(.horizontal)
                                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black) // Force text color
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onAppear(perform: fetchClimbs) // Fetch climbs when view appears
                }
            }
        }
    }
    
    // Fetch the climbs from Firestore
    func fetchClimbs() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error: User is not logged in.")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("climbs").whereField("userId", isEqualTo: uid).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching documents: \(error)")
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
        }
    }
}

#Preview {
    MyClimbsView()
}

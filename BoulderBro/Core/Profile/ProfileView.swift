import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme // To detect the current color scheme
    @State private var showMembershipCard = false // State to show membership card view

    var body: some View {
        if let user = viewModel.currentUser {
            ZStack {
                // MovingCircles at the back
                MovingCircles(
                    topCircleColor: Color.white,
                    bottomCircleColor: Color.white,
                    topCircleOpacity: 0.2,
                    bottomCircleOpacity: 0.2,
                    backgroundColor: Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color(hex: "#f1f0f5"))
                )
                .ignoresSafeArea() // Ensures circles cover the entire screen

                VStack {
                    List {
                        Section {
                            HStack {
                                Text(user.initals)
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.white)
                                    .frame(width: 72, height: 72)
                                    .background(Color(.systemGray3))
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.fullname)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding(.top, 4)
                                    Text(user.email)
                                        .font(.footnote)
                                        .foregroundStyle(Color(.gray))
                                }
                            }
                            .padding(.vertical, 8) // Add some vertical padding for better spacing
                        }
                        
                        
                        Section("General") {
                            HStack {
                                SettingsRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
                                Spacer()
                                
                                Text("1.0.0")
                                    .font(.subheadline)
                                    .foregroundStyle(Color(colorScheme == .dark ? Color.white : Color.black))
                            }
                            .padding(.vertical, 8)
                        }
                        
                        Section("Account") {
                            Button {
                                viewModel.signout()
                            } label: {
                                SettingsRowView(imageName: "arrow.left.circle.fill",
                                                title: "Sign Out", tintColor: .red)
                                    .foregroundStyle(Color(colorScheme == .dark ? Color.white : Color.black))
                            }
                            .padding(.vertical, 8)
                            
                            Button {
                                print("Delete Account...")
                            } label: {
                                SettingsRowView(imageName: "xmark.circle.fill",
                                                title: "Delete Account", tintColor: .red)
                                    .foregroundStyle(Color(colorScheme == .dark ? Color.white : Color.black))
                            }
                            .padding(.vertical, 8)
                        }
                        
                        Section("Membership") {
                            Button {
                                showMembershipCard.toggle()
                            } label: {
                                SettingsRowView(imageName: "creditcard.fill",
                                                title: "See My Membership Card", tintColor: Color(.systemBlue))
                                    .foregroundStyle(Color(colorScheme == .dark ? Color.white : Color.black))
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .background(Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color(hex: "#f1f0f5")))
                    .listStyle(InsetGroupedListStyle()) // Adjust the list style as needed
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.inline) // Adjust title display mode
                    .sheet(isPresented: $showMembershipCard) {
                        MembershipCardView()
                    }
                }
                .padding(.top, 50)
                .background(Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color(hex: "#f1f0f5")))
                .ignoresSafeArea() // Ensure the background color covers the entire area
            }
            .background(Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color(hex: "#f1f0f5")))
            .ignoresSafeArea()
        } else {
            Text("Loading...") // Fallback if user data isn't available
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color(hex: "#f1f0f5")))
                .edgesIgnoringSafeArea(.all)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel()) // Provide the necessary environment object for preview
}

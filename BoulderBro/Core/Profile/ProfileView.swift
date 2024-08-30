import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showMembershipCard = false
    @AppStorage("selectedThemeMode") private var themeMode: ThemeMode = .system

    var body: some View {
        NavigationView {
            if let user = viewModel.currentUser {
                ZStack {
                    MovingCircles(
                        topCircleColor: .blue,
                        bottomCircleColor: .blue,
                        topCircleOpacity: 0.2,
                        bottomCircleOpacity: 0.2,
                        backgroundColor: colorScheme == .dark ? Color(hex: "#1f1f1f") : Color.blue.opacity(0.1)
                    )
                    .ignoresSafeArea()

                    VStack {
                        List {
                            Section {
                                HStack {
                                    Text(user.initals)
                                        .font(.title)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color.white)
                                        .frame(width: 72, height: 72)
                                        .background(Color(.systemGray))
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
                                .padding(.vertical, 8)
                            }
                            
                            Section("Membership") {
                                Button {
                                    showMembershipCard.toggle()
                                } label: {
                                    SettingsRowView(imageName: "creditcard.fill", title: "See My Membership Card", tintColor: Color(.systemBlue))
                                        .foregroundStyle(Color(colorScheme == .dark ? Color.white : Color.black))
                                }
                                .padding(.vertical, 8)
                            }
                            
                            Section("General") {
                                NavigationLink(destination: SettingsView()) {
                                    SettingsRowView(imageName: "gear", title: "Settings", tintColor: Color(.systemGray))
                                }
                                .padding(.vertical, 8)
                                
                                NavigationLink(destination: ContactSupportView()) {
                                    SettingsRowView(imageName: "envelope.fill", title: "Contact Support", tintColor: Color(.systemBlue))
                                }
                                .padding(.vertical, 8)

                                NavigationLink(destination: ReportBugView()) {
                                    SettingsRowView(imageName: "exclamationmark.triangle.fill", title: "Report Bug", tintColor: Color(.systemYellow))
                                }
                                .padding(.vertical, 8)
                            }
                            
                            Section("Account") {
                                Button {
                                    viewModel.signout()
                                } label: {
                                    SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
                                        .foregroundStyle(Color(colorScheme == .dark ? Color.white : Color.black))
                                }
                                .padding(.vertical, 8)
                                
                                Button {
                                    Task { // Wrap the async call in a Task
                                        try await viewModel.deleteAccount()
                                    }
                                } label: {
                                    SettingsRowView(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: .red)
                                        .foregroundStyle(Color(colorScheme == .dark ? Color.white : Color.black))
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .background(Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color(hex: "#f1f0f5")))
                        .listStyle(InsetGroupedListStyle())
                        .navigationBarHidden(true) // Hide the navigation bar title
                        .sheet(isPresented: $showMembershipCard) {
                            MembershipCardView()
                        }
                    }
                    .padding(.top, 50)
                    .background(Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color.blue.opacity(0.1)))
                    .ignoresSafeArea()
                }
                .background(Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color.blue.opacity(0.1)))
                .ignoresSafeArea()
            } else {
                Text("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color(hex: "#f1f0f5")))
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .navigationBarHidden(true) // Hide the navigation bar title when profile view is displayed
    }
}


// Preview
#Preview {
    ProfileView()
        .environmentObject(AuthViewModel()) // Provide the necessary environment object for preview
}

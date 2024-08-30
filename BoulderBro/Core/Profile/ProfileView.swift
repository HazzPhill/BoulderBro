import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var selectedVideoURL: URL? // Although not used here, it's part of the ImagePicker
    @State private var showMembershipCard = false
    @State private var showEditAccount = false
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
                            // Profile Section
                            Section {
                                HStack {
                                    if let profileImageUrl = viewModel.profileImageUrl {
                                        AsyncImage(url: profileImageUrl) { phase in
                                            switch phase {
                                            case .empty:
                                                Color.gray
                                                    .frame(width: 72, height: 72)
                                                    .clipShape(Circle())
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 72, height: 72)
                                                    .clipShape(Circle())
                                            case .failure:
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 72, height: 72)
                                                    .foregroundColor(.red)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 72, height: 72)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(user.fullname)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .padding(.top, 4)
                                        Text(user.email)
                                            .font(.footnote)
                                            .foregroundStyle(Color(.gray))
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        showEditAccount.toggle()
                                    }) {
                                        Image(systemName: "pencil.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                    }
                                    .sheet(isPresented: $showEditAccount) {
                                        EditAccountView(user: user)
                                            .environmentObject(viewModel)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            
                            // Membership Section
                            Section("Membership") {
                                Button {
                                    showMembershipCard.toggle()
                                } label: {
                                    SettingsRowView(imageName: "creditcard.fill", title: "See My Membership Card", tintColor: Color(.systemBlue))
                                        .foregroundStyle(Color(colorScheme == .dark ? Color.white : Color.black))
                                }
                                .padding(.vertical, 8)
                            }
                            
                            // General Section
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
                            
                            // Account Section
                            Section("Account") {
                                Button {
                                    viewModel.signout()
                                } label: {
                                    SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
                                        .foregroundStyle(Color(colorScheme == .dark ? Color.white : Color.black))
                                }
                                .padding(.vertical, 8)
                                
                                Button {
                                    Task {
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
    }
}

// Preview
#Preview {
    let mockUser = User(id: "123", fullname: "John Doe", email: "johndoe@example.com", username: "johndoe")
    ProfileView()
        .environmentObject(AuthViewModel()) // Provide the necessary environment object for preview
}

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme // To detect the current color
    var body: some View {
        if let user = viewModel.currentUser {
            VStack{
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
                                                    .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#000000") : Color.white)) // Existing color logic
                                                Spacer()
                                                
                                                Text("1.0.0")
                                                    .font(.subheadline)
                                                    .foregroundStyle(Color(colorScheme == .dark ? Color.white : Color(hex: "#000000"))) // **Modify this line**
                                            }
                                            .padding(.vertical, 8)
                                        }
                                        
                                        Section("Account") {
                                            Button {
                                                viewModel.signout()
                                            } label: {
                                                SettingsRowView(imageName: "arrow.left.circle.fill",
                                                                title: "Sign Out", tintColor:
                                                        .red)
                                                .foregroundStyle(Color(colorScheme == .dark ? Color.white : Color(hex: "#000000"))) // **Modify this line**
                                                
                                            }
                                            .padding(.vertical, 8)
                                            
                                            Button {
                                                print("Delete Account...")
                                                
                                            } label: {
                                                SettingsRowView(imageName: "xmark.circle.fill",
                                                                title: "Delete Account", tintColor: .red)
                                                .foregroundStyle(Color(colorScheme
                                                                       == .dark ? Color.white : Color(hex: "#000000"))) // **Modify this line**
                                            }
                                            .padding(.vertical, 8)
                                        }
                }
                .listStyle(InsetGroupedListStyle()) // Adjust the list style as needed
                .navigationTitle("Profile") // Set a title if needed
                .navigationBarTitleDisplayMode(.inline) // Adjust title display mode
            }
            .padding(.top,50)
        } else {
            Text("Loading...") // Fallback if user data isn't available
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                .edgesIgnoringSafeArea(.all)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel()) // Provide the necessary environment object for preview
}

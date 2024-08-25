import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var colorThemeManager: ColorThemeManager
    @Environment(\.colorScheme) var colorScheme
    @State private var showMembershipCard = false
    @State private var showColorPicker = false // To show color picker

    var body: some View {
        if let user = viewModel.currentUser {
            ZStack {
                // Use the theme color for MovingCircles and background
                MovingCircles(
                    topCircleColor: colorThemeManager.currentThemeColor,
                    bottomCircleColor: colorThemeManager.currentThemeColor,
                    topCircleOpacity: 0.2,
                    bottomCircleOpacity: 0.2,
                    backgroundColor: colorScheme == .dark ? Color(hex: "#1f1f1f") : colorThemeManager.currentThemeColor.opacity(0.1)
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
                        
                        Section("General") {
                            HStack {
                                SettingsRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
                                Spacer()
                                Text("1.0.0")
                                    .font(.subheadline)
                                    .foregroundStyle(Color(colorScheme == .dark ? Color.white : Color.black))
                            }
                            .padding(.vertical, 8)
                            
                            Button {
                                showColorPicker.toggle()
                            } label: {
                                SettingsRowView(imageName: "paintbrush.fill", title: "Change Theme Color", tintColor: colorThemeManager.currentThemeColor)
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
                                print("Delete Account...")
                            } label: {
                                SettingsRowView(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: .red)
                                    .foregroundStyle(Color(colorScheme == .dark ? Color.white : Color.black))
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
                    }
                    .background(Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color(hex: "#f1f0f5")))
                    .listStyle(InsetGroupedListStyle())
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.inline)
                    .sheet(isPresented: $showMembershipCard) {
                        MembershipCardView()
                    }
                    .sheet(isPresented: $showColorPicker) {
                        ThemeColorPickerView()
                    }
                }
                .padding(.top, 50)
                .background(Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : colorThemeManager.currentThemeColor.opacity(0.1)))
                .ignoresSafeArea()
            }
            .background(Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : colorThemeManager.currentThemeColor.opacity(0.1)))
            .ignoresSafeArea()
        } else {
            Text("Loading...")
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

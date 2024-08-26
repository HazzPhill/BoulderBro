import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showMembershipCard = false
    @State private var showColorPicker = false
    @AppStorage("selectedThemeMode") private var themeMode: ThemeMode = .system

    var body: some View {
        if let user = viewModel.currentUser {
            ZStack {
                MovingCircles(
                    topCircleColor: .blue, // Adjust these as per your design
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
                        
                        Section("Appearance") {
                            Menu {
                                Button(action: {
                                    themeMode = .light
                                    applyThemeMode(.light)
                                }) {
                                    Label("Light Mode", systemImage: "sun.max.fill")
                                }
                                
                                Button(action: {
                                    themeMode = .dark
                                    applyThemeMode(.dark)
                                }) {
                                    Label("Dark Mode", systemImage: "moon.fill")
                                }
                                
                                Button(action: {
                                    themeMode = .system
                                    applyThemeMode(.system)
                                }) {
                                    Label("System Default", systemImage: "gear")
                                }
                            } label: {
                                HStack {
                                    Label(currentThemeText(), systemImage: currentThemeIcon())
                                        .font(.subheadline)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 8)
                            }
                            
                            Button {
                                showColorPicker.toggle()
                            } label: {
                                SettingsRowView(imageName: "paintbrush.fill", title: "Change Theme Color", tintColor: .blue) // Adjust based on your current theme color
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
                .background(Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color.blue.opacity(0.1))) // Adjust based on your theme
                .ignoresSafeArea()
            }
            .background(Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color.blue.opacity(0.1))) // Adjust based on your theme
            .ignoresSafeArea()
        } else {
            Text("Loading...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color(hex: "#f1f0f5")))
                .edgesIgnoringSafeArea(.all)
        }
    }

    private func applyThemeMode(_ mode: ThemeMode) {
        // Store the selected theme mode in UserDefaults
        UserDefaults.standard.set(mode.rawValue, forKey: "selectedThemeMode")
        
        // Apply the theme mode
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            switch mode {
            case .light:
                window.overrideUserInterfaceStyle = .light
            case .dark:
                window.overrideUserInterfaceStyle = .dark
            case .system:
                window.overrideUserInterfaceStyle = .unspecified
            }
        }
    }
    
    private func currentThemeText() -> String {
        switch themeMode {
        case .light:
            return "Light Mode"
        case .dark:
            return "Dark Mode"
        case .system:
            return "System Default"
        }
    }
    
    private func currentThemeIcon() -> String {
        switch themeMode {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .system:
            return "gear"
        }
    }
}

// ThemeMode enum to represent the available theme options
enum ThemeMode: String, CaseIterable {
    case light, dark, system
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }
    
    var iconName: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "gear"
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel()) // Provide the necessary environment object for preview
}

import SwiftUI

struct AppearanceSettingView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showColorPicker = false
    @AppStorage("selectedThemeMode") private var themeMode: ThemeMode = .system
    @AppStorage("countdownLength") private var countdownLength: Int = 3 // Default is 3 seconds

    var body: some View {
        List {
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
                .sheet(isPresented: $showColorPicker) {
                    ThemeColorPickerView()
                }
                
                // Countdown Length Picker
                Section("Countdown Length") {
                    Stepper(value: $countdownLength, in: 1...10) {
                        Text("Countdown: \(countdownLength) seconds")
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .background(Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color(hex: "#f1f0f5")))
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
    AppearanceSettingView()
}

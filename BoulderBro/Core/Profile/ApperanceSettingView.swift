import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct AppearanceSettingView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showColorPicker = false
    @AppStorage("selectedThemeMode") private var themeMode: ThemeMode = .system
    @AppStorage("hangTimerCountdownLength") private var hangTimerCountdownLength: Int = 3
    @AppStorage("restTimerCountdownLength") private var restTimerCountdownLength: Int = 3
    
    private var db = Firestore.firestore()

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
                    SettingsRowView(imageName: "paintbrush.fill", title: "Change Theme Color", tintColor: .blue)
                }
                .padding(.vertical, 8)
                .sheet(isPresented: $showColorPicker) {
                    ThemeColorPickerView()
                }
            }
            
            Section("Countdown Lengths") {
                Stepper(value: $hangTimerCountdownLength, in: 1...10, onEditingChanged: { _ in
                    savePreferences()
                }) {
                    Text("Hang Timer Countdown: \(hangTimerCountdownLength) seconds")
                }
                .padding(.vertical, 8)
                
                Stepper(value: $restTimerCountdownLength, in: 1...10, onEditingChanged: { _ in
                    savePreferences()
                }) {
                    Text("Rest Timer Countdown: \(restTimerCountdownLength) seconds")
                }
                .padding(.vertical, 8)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .background(Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color(hex: "#f1f0f5")))
        .onAppear(perform: loadPreferences) // Load preferences when the view appears
    }

    private func applyThemeMode(_ mode: ThemeMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: "selectedThemeMode")
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
        savePreferences() // Save to Firebase when theme changes
    }

    private func savePreferences() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        let preferences: [String: Any] = [
            "themeMode": themeMode.rawValue,
            "hangTimerCountdownLength": hangTimerCountdownLength,
            "restTimerCountdownLength": restTimerCountdownLength
        ]

        db.collection("users").document(userId).setData(preferences, merge: true) { error in
            if let error = error {
                print("Error saving preferences: \(error)")
            } else {
                print("Preferences saved successfully")
            }
        }
    }

    private func loadPreferences() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                if let themeModeRawValue = data?["themeMode"] as? String,
                   let mode = ThemeMode(rawValue: themeModeRawValue) {
                    themeMode = mode
                }
                hangTimerCountdownLength = data?["hangTimerCountdownLength"] as? Int ?? 3
                restTimerCountdownLength = data?["restTimerCountdownLength"] as? Int ?? 3
            } else {
                print("Error loading preferences: \(error?.localizedDescription ?? "Unknown error")")
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

//
//  BoulderBroApp.swift
//  BoulderBro
//
//  Created by Hazz on 12/08/2024.
//

import SwiftUI
import FirebaseCore
import StreamChat

class AppDelegate: NSObject, UIApplicationDelegate {
    var chatClient: ChatClient!

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()

        // Initialize Stream Chat client
        let config = ChatClientConfig(apiKey: .init("8nqgrrymjefq")) // Replace with your actual API key
        chatClient = ChatClient(config: config)

        return true
    }
}

@main
struct BoulderBroApp: App {
    @StateObject var viewModel = AuthViewModel()
    @StateObject var colorThemeManager = ColorThemeManager()
    @AppStorage("selectedThemeMode") private var themeMode: ThemeMode = .system
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(colorThemeManager)
                .onAppear {
                    applyThemeMode(themeMode)
                }
                .environment(\.chatClient, delegate.chatClient) // Use a custom environment key for ChatClient
        }
    }

    private func applyThemeMode(_ mode: ThemeMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: "selectedThemeMode")

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
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
    }
}

// Extension to initialize Color from a hex string
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0) // Default to white color
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Create a custom environment key for ChatClient
private struct ChatClientKey: EnvironmentKey {
    static let defaultValue: ChatClient? = nil
}

extension EnvironmentValues {
    var chatClient: ChatClient? {
        get { self[ChatClientKey.self] }
        set { self[ChatClientKey.self] = newValue }
    }
}

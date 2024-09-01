//
//  BoulderBroApp.swift
//  BoulderBro
//
//  Created by Hazz on 12/08/2024.
//

import SwiftUI
import FirebaseCore
import CometChatUIKitSwift

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Initialize CometChat UIKit with proper settings
        let uikitSettings = UIKitSettings()
            .set(appID: "262632aa520f3f63")  // Replace with your CometChat App ID
            .set(authKey: "600288556ad28b846412ea0e12f09291d0ac58d7")  // Replace with your CometChat Auth Key
            .set(region: "eu")  // Replace with your CometChat Region
            .subscribePresenceForAllUsers()
            .build()
        
        CometChatUIKit.init(uiKitSettings: uikitSettings) { result in
            switch result {
            case .success(let success):
                debugPrint("CometChatUIKit initialization completed successfully: \(success)")
            case .failure(let error):
                debugPrint("CometChatUIKit initialization failed with exception: \(error.localizedDescription)")
            }
        }
        
        return true
    }
}

@main
struct BoulderBroApp: App {
    
    @StateObject var viewModel = AuthViewModel()
    @StateObject var colorThemeManager = ColorThemeManager()
    @AppStorage("selectedThemeMode") private var themeMode: ThemeMode = .system // Store theme mode in AppStorage
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        applyThemeMode(themeMode) // Apply the theme mode when the app launches
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(colorThemeManager)
                .onAppear {
                    applyThemeMode(themeMode) // Ensure the theme mode is applied on the app's main view appearance
                }
        }
    }
    
    private func applyThemeMode(_ mode: ThemeMode) {
        // Store the selected theme mode in UserDefaults
        UserDefaults.standard.set(mode.rawValue, forKey: "selectedThemeMode")
        
        // Apply the theme mode
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

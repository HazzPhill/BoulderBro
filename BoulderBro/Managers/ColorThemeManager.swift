//
//  ColorThemeManager.swift
//  BoulderBro
//
//  Created by Hazz on 25/08/2024.
//

import SwiftUI

class ColorThemeManager: ObservableObject {
    @Published var currentThemeColor: Color
    
    init() {
        // Use a static method to load the saved color or set a default
        self.currentThemeColor = ColorThemeManager.loadColorFromDefaults() ?? Color(hex: "#FF5733")
    }
    
    func updateThemeColor(to color: Color) {
        currentThemeColor = color
        saveColorToDefaults(color: color)
    }
    
    // Check if the color is considered light or dark
    var isLightColor: Bool {
        let uiColor = UIColor(currentThemeColor)
        var white: CGFloat = 0
        uiColor.getWhite(&white, alpha: nil)
        return white > 0.7
    }
    
    private func saveColorToDefaults(color: Color) {
        if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(color), requiringSecureCoding: false) {
            UserDefaults.standard.set(colorData, forKey: "themeColor")
        }
    }
    
    // Make this method static so it can be called without needing `self`
    private static func loadColorFromDefaults() -> Color? {
        if let colorData = UserDefaults.standard.data(forKey: "themeColor"),
           let uiColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor {
            return Color(uiColor)
        }
        return nil
    }
}

import SwiftUI

struct CurrentLevel: View {
    @EnvironmentObject var colorThemeManager: ColorThemeManager // Access the theme color
    
    var body: some View {
        Rectangle()
            .frame(height: 85)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .foregroundStyle(colorThemeManager.currentThemeColor) // Use theme color
            .overlay(
                HStack(alignment: .center, spacing: 0) {
                    Text("Current Level")
                        .lineLimit(2)
                        .font(.custom("Kurdis-ExtraWideBold", size: 24))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)

                    Spacer() // Pushes elements to the sides

                    ZStack {
                        Rectangle()
                            .frame(width: 155, height: 65)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                        
                        Text("V5")
                            .lineLimit(2)
                            .font(.custom("Kurdis-ExtraWideBold", size: 24))
                            .foregroundStyle(colorThemeManager.currentThemeColor) // Use theme color
                            .frame(maxWidth: .infinity)
                    }
                }
            )
            .padding(.top)
            .padding(.bottom)
    }
    
    // Helper method to determine text color based on the theme color brightness
    private func textColor() -> Color {
        return colorThemeManager.isLightColor ? .black : .white
    }
}

#Preview {
    CurrentLevel()
        .environmentObject(ColorThemeManager()) // Provide ColorThemeManager for the preview
}

import SwiftUI

struct ThemeColorPickerView: View {
    @EnvironmentObject var colorThemeManager: ColorThemeManager
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme // To detect the current color scheme
    
    let lightModeColors: [Color] = [
        Color(hex: "#FF5733"), // Orange
        Color(hex: "#33FF57"), // Green
        Color(hex: "#3357FF"), // Blue
        Color(hex: "#FF33A8"), // Pink
        Color(hex: "#FFB533"), // Yellow
        Color(hex: "#8E44AD"), // Purple
        Color(hex: "#E74C3C"), // Red
        Color(hex: "#3498DB"), // Sky Blue
        Color(hex: "#2C3E50"), // Navy Blue
        Color(hex: "#1ABC9C"), // Turquoise
        Color(hex: "#2ECC71"), // Emerald Green
    ]
    
    let darkModeColors: [Color] = [
        Color(hex: "#D4D4D4"), // Light Gray
        Color(hex: "#FF5733"), // Orange
        Color(hex: "#33FF57"), // Green
        Color(hex: "#3357FF"), // Blue
        Color(hex: "#FF33A8"), // Pink
        Color(hex: "#3498DB"), // Sky Blue
        Color(hex: "#FFB533"), // Yellow
        Color(hex: "#F1C40F"), // Sunflower Yellow
        Color(hex: "#33FFD5") // Cyan
    ]
    
    @State private var selectedColor: Color? = nil
    
    var body: some View {
        VStack {
            Text("Select a Theme Color")
                .font(.headline)
                .padding()
            
            // Choose the color array based on the current color scheme
            let predefinedColors = colorScheme == .dark ? darkModeColors : lightModeColors
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 20) {
                ForEach(predefinedColors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .stroke(selectedColor == color ? Color.black : Color.clear, lineWidth: 2)
                        )
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }
            .padding()
            
            Button("Save") {
                if let color = selectedColor {
                    colorThemeManager.updateThemeColor(to: color)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
            .background(selectedColor ?? Color.gray)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(selectedColor == nil) // Disable the button if no color is selected
        }
        .padding()
    }
}

#Preview {
    ThemeColorPickerView()
}

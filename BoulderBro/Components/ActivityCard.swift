import SwiftUI

struct ActivityCard: View {
    @State var activity: Activity
    @Environment(\.colorScheme) var colorScheme // To detect the current color scheme
    @EnvironmentObject var colorThemeManager: ColorThemeManager // Access the theme color
    
    var body: some View {
        ZStack {
            // Background color: white in light mode, dark gray in dark mode
            Color(colorScheme == .dark ? Color(hex: "#333333") : .white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(activity.title)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .foregroundColor(.primary) // Adjusts automatically to light/dark mode
                        
                        Text(activity.subtitle)
                            .foregroundColor(.secondary) // Adjusts automatically to light/dark mode
                    }
                    
                    Spacer()
                    
                    Image(systemName: activity.image)
                        .foregroundStyle(colorThemeManager.currentThemeColor) // Use theme color
                }
                
                Text(activity.amount)
                    .font(.custom("Kurdis-ExtraWideBold", size: 20))
                    .foregroundStyle(colorThemeManager.currentThemeColor) // Use theme color
                    .padding()
            }
            .padding()
        }
    }
}

#Preview {
    ActivityCard(
        activity: Activity(
            title: "Today's Steps",
            subtitle: "Goal 12,000",
            image: "figure.walk",
            tintColor: Color(hex: "#FF5733"),
            amount: "9,431"
        )
    )
    .environmentObject(ColorThemeManager()) // Provide the ColorThemeManager for the preview
}

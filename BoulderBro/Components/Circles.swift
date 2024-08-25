import SwiftUI

struct MovingCircles: View {
    @State private var topCircleOffset = CGSize(width: 150, height: -300)
    @State private var bottomCircleOffset = CGSize(width: -150, height: 250)

    // Customization parameters
    var topCircleColor: Color
    var bottomCircleColor: Color
    var topCircleOpacity: Double
    var bottomCircleOpacity: Double
    var backgroundColor: Color // New parameter for background color

    // Timer for animation
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    @EnvironmentObject var colorThemeManager: ColorThemeManager // Access the theme color
 
    var body: some View {
        ZStack {
            // Background color
            backgroundColor
                .ignoresSafeArea()
                .zIndex(-3)

            // Top circle
            Circle()
                .fill(topCircleColor)
                .opacity(topCircleOpacity)
                .frame(width: 350, height: 350)
                .blur(radius: 60)
                .offset(topCircleOffset)
                .zIndex(-2)

            // Bottom circle
            Circle()
                .fill(bottomCircleColor)
                .opacity(bottomCircleOpacity)
                .frame(width: 350, height: 500)
                .blur(radius: 60)
                .offset(bottomCircleOffset)
                .zIndex(-1)
        }
        .onReceive(timer) { _ in
            withAnimation(.linear(duration: 0.9)) {
                // Update the offsets with slight random variations
                topCircleOffset = CGSize(
                    width: max(50, min(UIScreen.main.bounds.width - 300, topCircleOffset.width + CGFloat.random(in: -50...50))),
                    height: max(-250, min(-50, topCircleOffset.height + CGFloat.random(in: -25...25)))
                )
                bottomCircleOffset = CGSize(
                    width: max(-200, min(UIScreen.main.bounds.width - 300, bottomCircleOffset.width + CGFloat.random(in: -50...50))),
                    height: max(50, min(UIScreen.main.bounds.height - 450, bottomCircleOffset.height + CGFloat.random(in: -25...25)))
                )
            }
        }
    }
}

#Preview {
    MovingCircles(
        topCircleColor: .red,
        bottomCircleColor: .blue,
        topCircleOpacity: 0.5,
        bottomCircleOpacity: 0.5,
        backgroundColor: Color(hex: "#FF5733") // Example background color
    )
}

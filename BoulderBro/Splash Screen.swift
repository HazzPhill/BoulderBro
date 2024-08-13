//
//  SplashScreen.swift
//  BoulderBro
//
//  Created by Hazz on 12/08/2024.
//

import SwiftUI

struct SplashScreen: View {

    // Circle variables
    @State private var topCircleOffset = CGSize(width: 150, height: -300)
    @State private var bottomCircleOffset = CGSize(width: -150, height: 250)

    // Use a timer for animation
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect() // Adjust the interval as needed

    let easingFactor: CGFloat = 0.5 // Adjust this to control the smoothness

    var body: some View {
        ZStack {
            // Background color (placed at the bottom of the ZStack)
            Color(hex: "#FF5733") // Light gray background, adjust as needed
                .ignoresSafeArea() // Extend background behind safe areas
                .zIndex(-2) // Ensure it's behind the circles

            // Top circle
            Circle()
                .fill(Color.white).opacity(0.3)
                .frame(width: 350, height: 350)
                .blur(radius: 60)
                .offset(topCircleOffset) // Use the state variable for offset
                .zIndex(-1) // Keep circles above the background

            // Bottom circle
            Circle()
                .fill(Color.white).opacity(0.3)
                .frame(width: 350, height: 500)
                .blur(radius: 60)
                .offset(bottomCircleOffset) // Use the state variable for offset
                .zIndex(-1) // Keep circles above the background

            // Animate circle offsets
            .onReceive(timer) { _ in
                withAnimation(.linear(duration: 0.9)) {
                    // Calculate new target offsets with slight random variations, but keep them within bounds
                    let newTopOffset = CGSize(
                        width: max(50, min(UIScreen.main.bounds.width - 300, topCircleOffset.width + CGFloat.random(in: -50...50))),
                        height: max(-250, min(-50, topCircleOffset.height + CGFloat.random(in: -25...25)))
                    )
                    let newBottomOffset = CGSize(
                        width: max(-200, min(UIScreen.main.bounds.width - 300, bottomCircleOffset.width + CGFloat.random(in: -50...50))),
                        height: max(50, min(UIScreen.main.bounds.height - 450, bottomCircleOffset.height + CGFloat.random(in: -25...25)))
                    )

                    topCircleOffset = newTopOffset
                    bottomCircleOffset = newBottomOffset
                }
            }
            VStack{
                Text ("Hello,Harry!")
                    .foregroundStyle(Color.white)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            }
        }
    }

}


#Preview {
    SplashScreen()
}

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
        NavigationStack {
            ZStack {
                // Background color
                Color(hex: "#FF5733")
                    .ignoresSafeArea()
                    .zIndex(-2) // Ensure it's behind the circles
                
                // Top circle
                Circle()
                    .fill(Color.white).opacity(0.3)
                    .frame(width: 350, height: 350)
                    .blur(radius: 60)
                    .offset(topCircleOffset)
                    .zIndex(-1)
                
                // Bottom circle
                Circle()
                    .fill(Color.white).opacity(0.3)
                    .frame(width: 350, height: 500)
                    .blur(radius: 60)
                    .offset(bottomCircleOffset)
                    .zIndex(-1)
                
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
                
                VStack(spacing: 20) { // Added spacing between elements
                    Text("Hello, Harry!")
                        .foregroundStyle(Color.white)
                        .fontWeight(.bold)
                        .font(.title)
                    
                    // Customized NavigationLink
                    NavigationLink {
                        Insights()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        Text("View Insights")
                            .fontWeight(.bold)
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#FF5733"))
                            .frame(maxWidth: .infinity, minHeight: 50) // Full width, fixed height
                            .background(Color.white)
                            .cornerRadius(10) // Rounded corners
                    }
                    .padding(.horizontal) // Padding on the left and right
                }
                .padding(.horizontal, 20) // Optional additional padding around the VStack
            }
        }
    }
}

#Preview {
    SplashScreen()
}


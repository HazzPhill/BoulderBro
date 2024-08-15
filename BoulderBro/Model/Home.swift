import SwiftUI

// Create a custom view for each block
struct EditableBlock<Content: View>: View {
    var content: Content

    // Initializer to accept custom content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 163, height: 163)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(Color.white)


            // Display custom content passed to the block
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
        .frame(width: 163, height: 163) // Ensure content stays within the box size
        .clipShape(RoundedRectangle(cornerRadius: 10)) // Clip content to stay within rounded corners
    }
}

struct Home: View {

    // Circle variables
    @State private var topCircleOffset = CGSize(width: 150, height: -300)
    @State private var bottomCircleOffset = CGSize(width: -150, height: 250)

    // Use a timer for animation
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect() // Adjust the interval as needed

    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                Color(hex: "#f2f1f6")
                    .ignoresSafeArea()
                    .zIndex(-2) // Ensure it's behind the circles

                // Top circle
                Circle()
                    .fill(Color(hex: "#FF5733")).opacity(0.3)
                    .frame(width: 350, height: 350)
                    .blur(radius: 60)
                    .offset(topCircleOffset)
                    .opacity(0.5)
                    .zIndex(-1)

                // Bottom circle
                Circle()
                    .fill(Color(hex: "#FF5733")).opacity(0.3)
                    .frame(width: 350, height: 500)
                    .blur(radius: 60)
                    .offset(bottomCircleOffset)
                    .opacity(0.5)
                    .zIndex(-1)

                // Animate circle offsets
                .onReceive(timer) { _ in
                    withAnimation(.linear(duration: 0.9)) {
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
                ScrollView{
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Overall Progress")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(hex: "#FF5733"))
                        
                        Rectangle()
                            .frame(height: 163)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(Color.white)
                        
                        Text("My Climbs")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(hex: "#FF5733"))
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                // Customize each block with different content
                                EditableBlock {
                                    VStack {
                                        Image(systemName: "star.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.yellow)
                                        Text("Star")
                                    }
                                }
                                .padding(.trailing, 5)
                                
                                EditableBlock {
                                    VStack {
                                        Image(systemName: "flame.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.orange)
                                        Text("Flame")
                                    }
                                }

                                .padding(.trailing, 5)
                                
                                EditableBlock {
                                    VStack {
                                        Image(systemName: "bolt.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.blue)
                                        Text("Bolt")
                                    }
                                }

                                .padding(.trailing, 5)
                                
                                EditableBlock {
                                    VStack {
                                        Text("Custom")
                                            .font(.headline)
                                        Text("Text Layout")
                                            .font(.subheadline)
                                    }
                                }
   
                                .padding(.trailing, 5)
                                
                                EditableBlock {
                                    VStack {
                                        Image(systemName: "heart.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.red)
                                        Text("Heart")
                                    }
                                }

                                .padding(.trailing, 5)
                                
                                Spacer()
                                    .frame(width: 5)
                            }
                            
                            .padding(.top)
                            .padding(.bottom)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    Home()
}

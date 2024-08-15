import SwiftUI

@MainActor

// EditableBlock with flexible height (for "My Climbs" section)
struct EditableBlock<Content: View>: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 163, height: 163) // Original height
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(Color.white)

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
        .frame(width: 163, height: 163)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// EditableBlock with fixed height of 65 (for the bottom grid)
struct FixedHeightEditableBlock<Content: View>: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: 65)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(Color.white)

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
        .frame(height: 65)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct Home: View {
    @Binding var showSignInView: Bool

    // Circle variables
    @State private var topCircleOffset = CGSize(width: 150, height: -300)
    @State private var bottomCircleOffset = CGSize(width: -150, height: 250)

    // Use a timer for animation
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                Color(hex: "#f2f1f6")
                    .ignoresSafeArea()
                    .zIndex(-2)

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

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Overall Progress")
                            .font(.custom("Kurdis-ExtraWideBold", size: 24))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(hex: "#FF5733"))

                        Rectangle()
                            .frame(height: 163)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(Color.white)

                        Text("My Climbs")
                            .font(.custom("Kurdis-ExtraWideBold", size: 24))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(hex: "#FF5733"))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                // Use the original EditableBlock for this section
                                EditableBlock {
                                    VStack {
                                        Image(systemName: "star.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.yellow)
                                        Text("Star")
                                    }
                                }
                                .padding(.trailing, 5)

                                // ... (Rest of your EditableBlock views for "My Climbs")

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

                        Text("Stats")
                          .font(.custom("Kurdis-ExtraWideBold", size: 24))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(hex: "#FF5733"))

                        // Optimized grid layout with fixed height for the bottom grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            // Use FixedHeightEditableBlock for the bottom grid
                            FixedHeightEditableBlock {
                                // Custom content for the first rectangle
                                VStack {
                                    Text("First Rectangle")
                                        .font(.headline)
                                    // Add more views as needed
                                }
                            }

                            FixedHeightEditableBlock {
                                // Custom content for the second rectangle
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.red)
                                    Text("Second Rectangle")
                                }
                            }

                            // Add more FixedHeightEditableBlock views with custom content as needed
                            FixedHeightEditableBlock {
                                // Custom content for the third rectangle
                                VStack {
                                    Text("Third Rectangle")
                                        .font(.headline)
                                    // Add more views as needed
                                }
                            }

                            FixedHeightEditableBlock {
                                // Custom content for the fourth rectangle
                                HStack {
                                    Image(systemName: "staroflife.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.blue)
                                    Text("Fourth Rectangle")
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    Home(showSignInView: .constant(false))
}

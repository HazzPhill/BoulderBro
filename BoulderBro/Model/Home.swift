import SwiftUI

// EditableBlock with flexible height (for "My Climbs" section)
struct EditableBlock<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme // To detect the current color
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 163, height: 163)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#333333") : .white))

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
    @Environment(\.colorScheme) var colorScheme // To detect the current color
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: 65)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#333333") : .white))

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
        }
        .frame(height: 65)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct Home: View {
    
    
    
    init() {
        UITabBar.appearance().isHidden = true
    }

    @Environment(\.colorScheme) var colorScheme // To detect the current color
    
    // Circle variables
    @State private var topCircleOffset = CGSize(width: 150, height: -300)
    @State private var bottomCircleOffset = CGSize(width: -150, height: 250)

    // Use a timer for animation
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                Color(colorScheme == .dark ? Color(hex: "#1f1f1f") :Color(hex: "#f1f0f5"))
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
                        Text("Overview")
                            .font(.custom("Kurdis-ExtraWideBlack", size: 30))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))
                            .opacity(0.7)

                        Rectangle()
                            .frame(height: 163)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#333333") : .white))

                        Text("My Climbs")
                            .font(.custom("Kurdis-ExtraWideBold", size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))
                            .padding(.top)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                EditableBlock {
                                    VStack {
                                        Image(systemName: "star.fill")
                                            .font(.largeTitle)
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

                        Text("Stats")
                            .font(.custom("Kurdis-ExtraWideBold", size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))
                            .padding(.top)
                            .padding(.top)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            FixedHeightEditableBlock {
                                VStack {
                                    Text("First Rectangle")
                                        .font(.headline)
                                }
                            }
                            
                            FixedHeightEditableBlock {
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.red)
                                    Text("Second Rectangle")
                                }
                            }
                            
                            FixedHeightEditableBlock {
                                VStack {
                                    Text("Third Rectangle")
                                        .font(.headline)
                                }
                            }
                            
                            FixedHeightEditableBlock {
                                HStack {
                                    Image(systemName: "staroflife.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.blue)
                                    Text("Fourth Rectangle")
                                }
                            }
                        }
                        
                        
                        Text("HangTimer")
                            .font(.custom("Kurdis-ExtraWideBold", size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))
                            .padding(.top)
                            .padding(.top)
                        
                        HangTimer()
                        
                        
                        Text("Climb of the week")
                            .font(.custom("Kurdis-ExtraWideBold", size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))
                            .padding(.top)
                            .padding(.top)

                        Rectangle()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#333333") : .white))
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

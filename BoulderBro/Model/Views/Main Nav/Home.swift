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
    
    // Circle variables for animated background circles
    @State private var topCircleOffset = CGSize(width: 150, height: -300)
    @State private var bottomCircleOffset = CGSize(width: -150, height: 250)

    // Use a timer for animation
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    @EnvironmentObject var colorThemeManager: ColorThemeManager // Access the theme color
    
    @StateObject var viewModel = FitnessHomeViewModel()
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Use customizable MovingCircles component
                MovingCircles(
                    topCircleColor: colorThemeManager.currentThemeColor,
                    bottomCircleColor: colorThemeManager.currentThemeColor,
                    topCircleOpacity: 0.3,
                    bottomCircleOpacity: 0.3,
                    backgroundColor: Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color(hex: "#f1f0f5"))
                )
                .zIndex(-1) // Ensure the circles and background are behind other content

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Overview")
                            .font(.custom("Kurdis-ExtraWideBlack", size: 30))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))
                            .opacity(0.7)

                        // Overview section with the calorie chart
                        VStack(alignment: .leading) {
                            Text("Minutes climbed this week")
                                .font(.custom("Kurdis-ExtraWideBold", size: 16))
                                .padding(.top)
                            
                            Rectangle()
                                .fill(Color(colorScheme == .dark ? Color(hex: "#333333") : .white))
                                .cornerRadius(12)
                                .overlay(
                                    WeeklyClimbingChartView()
                                        .padding()
                                )
                                .frame(height: 150) // Adjust the height as needed
                                .padding(.bottom, 10) // Optional: Add some padding below the chart
                        }

                        Text("My Climbs")
                            .font(.custom("Kurdis-ExtraWideBold", size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))

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
                        }

                

                        Text("Recent Workouts")
                            .font(.custom("Kurdis-ExtraWideBold", size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))
                        
                        Spacer()

                        LazyVStack {
                            ForEach(viewModel.workouts.prefix(3), id: \.calories) { workout in
                                WorkoutCard(workout: workout)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    // Function to parse V rating from String to Int
    func parseVRating(_ rating: String) -> Int {
        return Int(rating.trimmingCharacters(in: CharacterSet.letters)) ?? 0
    }

    // Helper method to determine text color based on the theme color brightness
    private func textColor() -> Color {
        return colorThemeManager.isLightColor ? .black : .white
    }
}

#Preview {
    Home()
        .environmentObject(ColorThemeManager())
        .environmentObject(FitnessHomeViewModel())
}

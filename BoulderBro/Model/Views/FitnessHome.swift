import SwiftUI

struct FitnessHome: View {
    @EnvironmentObject var colorThemeManager: ColorThemeManager // Access the theme color
    @StateObject var viewModel = FitnessHomeViewModel()
    @Environment(\.colorScheme) var colorScheme // To detect the current color
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                // Use customizable MovingCircles
                MovingCircles(
                    topCircleColor: colorThemeManager.currentThemeColor,
                    bottomCircleColor: colorThemeManager.currentThemeColor,
                    topCircleOpacity: 0.0,
                    bottomCircleOpacity: 0.05,
                    backgroundColor: Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color(hex: "#f1f0f5"))
                )
                .zIndex(-3) // Ensure MovingCircles stay in the background
                .ignoresSafeArea()

                // Content layer that respects safe area
                ScrollView(showsIndicators: false) {
                    VStack {
                        Text("Welcome")
                            .font(.custom("Kurdis-ExtraWideBold", size: 24))
                            .padding()

                        HStack {
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Calories")
                                        .font(.custom("Kurdis-ExtraWideBold", size: 15))
                                        .foregroundStyle(Color.red)
                                    Text("\(viewModel.calories)")
                                }
                                .padding(.bottom)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Active")
                                        .font(.custom("Kurdis-ExtraWideBold", size: 15))
                                        .foregroundStyle(Color.green)
                                    Text("\(viewModel.exercise)")
                                }
                                .padding(.bottom)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Stand")
                                        .font(.custom("Kurdis-ExtraWideBold", size: 15))
                                        .foregroundStyle(Color.blue)
                                    Text("\(viewModel.stand)")
                                }
                            }
                            
                            Spacer()
                            
                            ZStack {
                                ProgressCircleView(progress: $viewModel.calories, goal: 600, color: .red)
                                    .zIndex(1) // Bring the progress circles to the front

                                ProgressCircleView(progress: $viewModel.exercise, goal: 60, color: .green)
                                    .padding(.all, 20)
                                    .zIndex(1) // Bring the progress circles to the front

                                ProgressCircleView(progress: $viewModel.stand, goal: 12, color: .blue)
                                    .padding(.all, 40)
                                    .zIndex(1) // Bring the progress circles to the front
                            }
                            .zIndex(2) // Bring the progress circles to the front
                        }
                        .padding(.horizontal, 16) // Ensuring the original padding is maintained
                        
                        Spacer()
                        
                        HStack {
                            Text("Fitness Activity")
                                .font(.custom("Kurdis-ExtraWideBold", size: 16))
                            Spacer()
                            
                            Button {
                                print("Show More")
                            } label: {
                                Text("Show More")
                                    .padding(.all, 10)
                                    .foregroundColor(textColor()) // Dynamic text color for button
                                    .background(colorThemeManager.currentThemeColor) // Use theme color for background
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        if !viewModel.activities.isEmpty {
                            LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2)) {
                                ForEach(viewModel.activities, id: \.title) { activity in
                                    ActivityCard(activity: activity)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        CurrentLevel()
                            .padding(.horizontal)
                        
                        HStack {
                            Text("Calories Burnt")
                                .font(.custom("Kurdis-ExtraWideBold", size: 16))
                            Spacer()
                            
                            NavigationLink {
                                DeepInsightsView()
                            } label: {
                                Text("Show More")
                                    .padding(.all, 10)
                                    .foregroundColor(textColor()) // Dynamic text color for button
                                    .background(colorThemeManager.currentThemeColor) // Use theme color for background
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#333333") : .white))
                                .shadow(radius: 5)
                                .frame(height: 165) // Adjust the height based on content

                            CaloriesChart()
                        }
                        .padding(.horizontal)
            
                        
                        HStack {
                            Text("Recent Workouts")
                                .font(.custom("Kurdis-ExtraWideBold", size: 16))
                            Spacer()
                            
                            NavigationLink {
                                EmptyView()
                            } label: {
                                Text("Show More")
                                    .padding(.all, 10)
                                    .foregroundColor(textColor()) // Dynamic text color for button
                                    .background(colorThemeManager.currentThemeColor) // Use theme color for background
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        LazyVStack {
                            ForEach(viewModel.workouts, id: \.calories) { workout in
                                WorkoutCard(workout: workout)
                            }
                        }
                        .padding()
                    }
                    .padding(.bottom, 50)
                }
            }
        }
    }
    
    // Helper method to determine text color based on the theme color brightness
    private func textColor() -> Color {
        return colorThemeManager.isLightColor ? .black : .white
    }
}

#Preview {
    FitnessHome()
        .environmentObject(ColorThemeManager()) // Provide ColorThemeManager for the preview
        .environmentObject(FitnessHomeViewModel()) // Provide FitnessHomeViewModel for the preview
}

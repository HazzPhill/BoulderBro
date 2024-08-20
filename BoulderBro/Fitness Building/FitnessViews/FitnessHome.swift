import SwiftUI

struct FitnessHome: View {
    @StateObject var viewModel = FitnessHomeViewModel()
    @Environment(\.colorScheme) var colorScheme // To detect the current color
    var body: some View {
        NavigationStack {
            ZStack {
                // Background layer that ignores safe area
                Color(colorScheme == .dark ? Color(hex: "#1f1f1f") :Color(hex: "#f1f0f5"))
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
                                
                                ProgressCircleView(progress: $viewModel.exercise, goal: 60, color: .green)
                                    .padding(.all, 20)
                                
                                ProgressCircleView(progress: $viewModel.stand, goal: 12, color: .blue)
                                    .padding(.all, 40)
                            }
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
                                    .foregroundStyle(Color.white)
                                    .background(Color(hex: "#FF5733"))
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
                        
                        HStack {
                            Text("Recent Workouts")
                                .font(.custom("Kurdis-ExtraWideBold", size: 16))
                            Spacer()
                            
                            NavigationLink {
                                EmptyView()
                            } label: {
                                Text("Show More")
                                    .padding(.all, 10)
                                    .foregroundStyle(Color.white)
                                    .background(Color(hex: "#FF5733"))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top)
                        
                        LazyVStack {
                            ForEach(viewModel.workouts, id: \.calories) { workout in
                                WorkoutCard(workout: workout)
                            }
                        }
                        .padding()
                    }
                    .padding(.bottom,50)
                }
            }
        }
    }
}

#Preview {
    FitnessHome()
}

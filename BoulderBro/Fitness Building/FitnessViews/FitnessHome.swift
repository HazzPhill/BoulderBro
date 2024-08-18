//
//  FitnessHome.swift
//  BoulderBro
//
//  Created by Hazz on 17/08/2024.
//

import SwiftUI

struct FitnessHome: View {
    @StateObject var viewModel = FitnessHomeViewModel()
 
    var body: some View {
        NavigationStack {
            ScrollView (showsIndicators: false) {
                VStack{
                    Text ("Welcome")
                        .font(.custom("Kurdis-ExtraWideBold", size: 24))
                        .padding()
                    
                    HStack{
                        
                        Spacer()
                        
                        VStack (alignment: .leading,spacing: 8) {
                            VStack(alignment: .leading,spacing: 8) {
                                Text ("Calrories")
                                    .font(.custom("Kurdis-ExtraWideBold", size: 15))
                                    .foregroundStyle(Color.red)
                                Text ("\(viewModel.calories)")
                            }
                            .padding(.bottom)
                            
                            VStack(alignment: .leading,spacing: 8) {
                                Text ("Active")
                                    .font(.custom("Kurdis-ExtraWideBold", size: 15))
                                    .foregroundStyle(Color.green)
                                Text ("\(viewModel.exercise)")
                            }
                            .padding(.bottom)
                            
                            VStack(alignment: .leading,spacing: 8) {
                                Text ("Stand")
                                    .font(.custom("Kurdis-ExtraWideBold", size: 15))
                                    .foregroundStyle(Color.blue)
                                Text ("\(viewModel.stand)")
                            }
                            
                        }
                        
                        Spacer()
                        
                        ZStack{
                            ProgressCircleView(progress: $viewModel.calories, goal: 600, color: .red)
                            
                            ProgressCircleView(progress: $viewModel.exercise, goal: 60, color: .green)
                                .padding(.all,20)
                            
                            ProgressCircleView(progress: $viewModel.stand, goal: 12, color: .blue)
                                .padding(.all,40)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    HStack{
                        Text ("Fitness Activity")
                            .font(.custom("Kurdis-ExtraWideBold", size: 16))
                        Spacer()
                        
                        Button {
                            print("Show More")
                        } label: {
                            Text("Show More")
                                .padding(.all,10)
                                .foregroundStyle(Color.white)
                                .background(Color(hex: "#FF5733"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.horizontal)
                
                    if !viewModel.activities.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(spacing: 20),count: 2)) {
                            ForEach(viewModel.activities, id: \.title) { activity in // Use activityCard here
                                ActivityCard(activity: activity) // Access the activity property
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    
                    
                    HStack{
                        Text ("Recent Workouts")
                            .font(.custom("Kurdis-ExtraWideBold", size: 16))
                        Spacer()
                        
                        NavigationLink {
                            EmptyView()
                        } label: {
                            Text("Show More")
                                .padding(.all,10)
                                .foregroundStyle(Color.white)
                                .background(Color(hex: "#FF5733"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    LazyVStack{
                        ForEach(viewModel.mockWorkouts, id: \.workout.id) { workoutCard in
                            WorkoutCard(workout: workoutCard.workout)
                        }
                    }
                }

            }
        }
    }
}

#Preview {
    FitnessHome()
}

//
//  FitnessHomeViewModel.swift
//  BoulderBro
//
//  Created by Hazz on 17/08/2024.
//

import SwiftUI
import HealthKit
import HealthKitUI

class FitnessHomeViewModel: ObservableObject {
    
    let healthManager = HealthManager.shared
    
    @Published var calories: Int = 0
    @Published var exercise: Int = 0
    @Published var stand: Int = 0
    @Published var activities = [Activity]()
    
    var mockactivities = [
        ActivityCard(activity: Activity(title: "Today's Steps", subtitle: "Goal 9,000", image: "figure.walk", tintColor:Color(hex: "#FF5733"), amount: "521")),
        ActivityCard(activity: Activity(title: "Today's Steps", subtitle: "Goal 19,000", image: "figure.walk", tintColor:Color(hex: "#FF5733"), amount: "532")),
        ActivityCard(activity: Activity(title: "Today's Steps", subtitle: "Goal 2,000", image: "figure.walk", tintColor:Color(hex: "#FF5733"), amount: "321")),
        ActivityCard(activity: Activity(title: "Today's Steps", subtitle: "Goal 12,931", image: "figure.run", tintColor:Color(hex: "#FF5733"), amount: "5321"))
    ]
    
    var mockWorkouts = [
        WorkoutCard(workout: Workout(id: 0, title: "Climbing", image: "figure.run", duration: "24 mins", tintColor: Color(hex: "#FF5733"), date: " August 1", calories: "642 kcal")),
        WorkoutCard(workout: Workout(id: 1, title: "Running", image: "figure.run", duration: "43 mins", tintColor: Color(hex: "#FF5733"), date: " August 2", calories: "235 kcal")),
        WorkoutCard(workout: Workout(id: 2, title: "Climbing", image: "figure.run", duration: "62 mins", tintColor: Color(hex: "#FF5733"), date: " August 3", calories: "242 kcal")),
        WorkoutCard(workout: Workout(id: 3, title: "Climbing", image: "figure.run", duration: "92 mins", tintColor: Color(hex: "#FF5733"), date: " August 4", calories: "743 kcal"))
    ]
    
    init() {
        Task {
            do {
                try await healthManager.requestHealthKitAccess()
                // Only fetch data if authorization is successful
                fetchTodayCalories()
                fetchTodayStandHours()
                fetchTodayExerciseTime()
                fetchTodaysSteps()
                fetchCurrentWeekActivities()
            } catch {
                print("Error requesting HealthKit access: \(error.localizedDescription)")
                // Consider displaying an error message to the user here
            }
        }
    }
    
    func fetchTodayCalories() {
        healthManager.fetchTodayCaloriesBurned { result in
            switch result {
            case .success(let calories):
                DispatchQueue.main.async {
                    self.calories = Int(calories)
                    let activity = Activity(title: "Calories Burned", subtitle: "today", image: "flame", tintColor: .red, amount: calories.formattedNumberString())
                    self.activities.append(activity)
                }
            case .failure(let failure):
                print (failure.localizedDescription)
            }
        }
    }
    
    func fetchTodayExerciseTime() {
        healthManager.fetchTodayExceriseTime { result in
            switch result {
            case .success(let exercise):
                DispatchQueue.main.async {
                    self.exercise = Int(exercise)
                }
            case .failure(let failure):
                print (failure.localizedDescription)
            }
        }
    }
    
    func fetchTodayStandHours() {
        healthManager.fetchTodayStandHours { result in
            switch result {
            case .success(let hours):
                DispatchQueue.main.async {
                    self.stand = hours
                }
            case .failure(let failure):
                print (failure.localizedDescription)
            }
        }
    }
    
    //MARK: Fitness Activity
    func fetchTodaysSteps() {
        healthManager.fetchTodaySteps { result in
            switch result {
            case .success(let activity):
                DispatchQueue.main.async {
                    self.activities.append(activity)
                }
            case .failure(let failure):
                print (failure.localizedDescription)
            }
        }
    }
    
    func fetchCurrentWeekActivities() {
        healthManager.fetchCurrentWeekWorkoutStats { result in
            switch result {
            case .success(let activities):
                DispatchQueue.main.async {
                    self.activities.append(contentsOf: activities)
                }
            case .failure(let failure):
                print (failure.localizedDescription)
            }
        }
    }
}

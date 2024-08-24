//
//  HealthManager.swift
//  BoulderBro
//
//  Created by Hazz on 18/08/2024.
//

import Foundation
import HealthKit
import SwiftUI

extension Date {
    static var startOfDay: Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: Date())
    }
    
    static var startOfWeek: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 2
        return calendar.date(from: components) ?? Date()
    }
    
    func fetchMonthStartAndEndDate () -> (Date,Date) {
        let calendar = Calendar.current
        let startDateComponent = calendar.dateComponents([.year,.month], from: calendar.startOfDay(for: self))
        let startDate = calendar.date(from: startDateComponent) ?? self
        let endDate = calendar.date(byAdding: DateComponents(month:1, day: -1), to: startDate) ?? self
        
        return (startDate, endDate)
    }
    
    func formatWorkoutDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }
}

extension Double {
    
    func formattedNumberString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        
        return formatter.string(from:NSNumber(value: self)) ?? "0"
    }
    
}

class HealthManager {
    static let shared = HealthManager()
    
    private let healthStore = HKHealthStore()
    
    private init () {
        
        Task {
            do {
                try await requestHealthKitAccess()
            } catch {
                print (error.localizedDescription)
            }
        }
    }
    
    func requestHealthKitAccess() async throws {
        let calories = HKQuantityType(.activeEnergyBurned)
        let exercise = HKQuantityType(.appleExerciseTime)
        let stand = HKCategoryType(.appleStandHour)
        let steps = HKQuantityType(.stepCount)
        let workouts = HKSampleType.workoutType()
        
        let healthTypes: Set = [calories, exercise, stand, steps, workouts]
        try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
    }
    
    func fetchTodayCaloriesBurned(completion: @escaping(Result<Double,Error>)->Void) {
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart:.startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(NSError()))
                return
            }
            
            let calorieCount = quantity.doubleValue(for: .kilocalorie())
            completion(.success(calorieCount))
        }
        
        healthStore.execute(query)
    }
    
    func fetchTodayExceriseTime(completion: @escaping(Result<Double,Error>) -> Void) {
        let exercise = HKQuantityType(.appleExerciseTime)
        let predicate = HKQuery.predicateForSamples(withStart:.startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: exercise, quantitySamplePredicate: predicate) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(NSError()))
                return
            }
            
            let exceriseTime = quantity.doubleValue(for: .minute())
            completion(.success(exceriseTime))
        }
        
        healthStore.execute(query)
    }
    
    func fetchTodayStandHours(completion: @escaping(Result<Int,Error>)->Void) {
        let stand = HKCategoryType(.appleStandHour)
        let predicate = HKQuery.predicateForSamples(withStart:.startOfDay, end: Date())
        let query = HKSampleQuery(sampleType: stand, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _,  results, error in
            guard let samples = results as? [HKCategorySample], error == nil else {
                completion(.failure(NSError()))
                return
            }
            print (samples)
            print (samples.map({$0.value}))
            let standCount = samples.filter({ $0.value == 0 }).count
            completion(.success(standCount))
        }
        
        
        healthStore.execute(query)
    }
    
    //MARK: Fitness Activity
    
    func fetchTodaySteps(completion: @escaping(Result<Activity,Error>)->Void) {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart:.startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(NSError()))
                return
            }
            
            let steps = quantity.doubleValue(for: .count())
            let activity = Activity(title: "Steps", subtitle: "Today", image: "figure.walk", tintColor: .green, amount: steps.formattedNumberString())
            completion(.success(activity))
        }
        
        healthStore.execute(query)
    }
    
    func fetchCurrentWeekWorkoutStats(completion: @escaping (Result<[Activity],Error>)->Void) {
        let workouts = HKSampleType.workoutType()
        let predicate = HKQuery.predicateForSamples(withStart:.startOfWeek, end: Date())
        let query = HKSampleQuery(sampleType: workouts, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, results, error in
            guard let workouts = results as? [HKWorkout], let self = self, error == nil else {
                completion(.failure(URLError(.badURL)))
                return
            }
            
            var climbingCount: Int = 0
            
            for workout in workouts{
                let duration = Int(workout.duration)/60
                if workout.workoutActivityType == .climbing {
                    climbingCount += duration
                }
            }
            completion(.success(self.generateActivitiesFromDurations(climbing: climbingCount)))
        }
        healthStore.execute(query)
    }
    
    private func generateActivitiesFromDurations(climbing: Int) -> [Activity] {
        return [
            Activity(title: "Climbing", subtitle: "This week", image: "figure.climbing", tintColor: .green, amount: "\(climbing) mins")
            
        ]
    }
    
    //MARK:  Recent Workouts
    
    func fetchWorkoutsForMonth(month:Date,completion: @escaping (Result<[Workout],Error>)->Void) {
        let workouts = HKSampleType.workoutType()
        let (startDate,endDate) = month.fetchMonthStartAndEndDate()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate,ascending:
                                                false)
        
        let query = HKSampleQuery(sampleType:
                                    workouts, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, result, error in
            guard let workouts = result as? [HKWorkout], error == nil else {
                completion(.failure(URLError(.badURL)))
                return
            }
            
            // Filter for climbing workouts
            let climbingWorkouts = workouts.filter { $0.workoutActivityType == .climbing }
            
            let workoutArray = climbingWorkouts.map { workout -> Workout in
                let energyBurned = workout.statistics(for: HKQuantityType(.activeEnergyBurned))?.sumQuantity()?.doubleValue(for: .kilocalorie())
                
                return Workout(
                    id: 0,
                    title: workout.workoutActivityType.name,
                    image: "figure.climbing",
                    duration: "\(Int(workout.duration)/60) mins",
                    tintColor: Color(hex: "#FF5733"),
                    date: workout.startDate.formatWorkoutDate(),
                    calories: (energyBurned?.formattedNumberString() ?? "-") + "kcal")
            }
            
            completion(.success(workoutArray))
        }
        healthStore.execute(query)
    }
    
    func fetchLastTenClimbingWorkouts(completion: @escaping (Result<[Workout], Error>) -> Void) {
        let workouts = HKSampleType.workoutType()
        let predicate = HKQuery.predicateForSamples(withStart: nil, end: Date())
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: workouts, predicate: predicate, limit: 10, sortDescriptors: [sortDescriptor]) { _, result, error in
            guard let workouts = result as? [HKWorkout], error == nil else {
                completion(.failure(URLError(.badURL)))
                return
            }
            
            // Filter for climbing workouts
            let climbingWorkouts = workouts.filter { $0.workoutActivityType == .climbing }
            
            let workoutArray = climbingWorkouts.map { workout -> Workout in
                let energyBurned = workout.statistics(for: HKQuantityType(.activeEnergyBurned))?.sumQuantity()?.doubleValue(for: .kilocalorie())
                
                return Workout(
                    id: 0,
                    title: workout.workoutActivityType.name,
                    image: "figure.climbing",
                    duration: "\(Int(workout.duration)/60) mins",
                    tintColor: Color(hex: "#FF5733"),
                    date: workout.startDate.formatWorkoutDate(),
                    calories: (energyBurned?.formattedNumberString() ?? "0") + " kcal"
                )
            }
            
            completion(.success(workoutArray))
        }
        
        healthStore.execute(query)
    }
}



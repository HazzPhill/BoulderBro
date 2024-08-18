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
            let activity = Activity(title: "Today Steps", subtitle: "Goal: 800", image: "figure.walk", tintColor: .green, amount: steps.formattedNumberString())
            completion(.success(activity))
        }
        
        healthStore.execute(query)
    }
    
    func fetchCurrentWeekWorkoutStats(completion: @escaping (Result<[Activity],Error>)->Void) {
            let workouts = HKSampleType.workoutType()
            let predicate = HKQuery.predicateForSamples(withStart:.startOfWeek, end: Date())
            let query = HKSampleQuery(sampleType: workouts, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, results, error in
                guard let workouts = results as? [HKWorkout], let self = self, error == nil else {
                    completion(.failure(NSError()))
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
                Activity(title: "Climbing", subtitle: "This Week", image: "figure.climbing", tintColor: .green, amount: "\(climbing) mins")
                
            ]
        }
    }


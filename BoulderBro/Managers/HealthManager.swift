import Foundation
import HealthKit
import SwiftUI
import FirebaseFirestore



// MARK: - Fetch Resting Heart Rate for Last 5 Climbing Workouts
extension HealthManager {
    func fetchRestingHeartRateForLastClimbingWorkouts(limit: Int = 5, completion: @escaping (Result<[(date: Date, restingHeartRate: Double)], Error>) -> Void) {
        let workouts = HKSampleType.workoutType()
        let predicate = HKQuery.predicateForSamples(withStart: nil, end: Date())
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: workouts, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { [weak self] _, result, error in
            guard let workouts = result as? [HKWorkout], error == nil else {
                completion(.failure(error ?? URLError(.badURL)))
                return
            }
            
            // Filter for climbing workouts and limit to the last `limit` workouts
            let climbingWorkouts = workouts.filter { $0.workoutActivityType == .climbing }.prefix(limit)
            
            guard !climbingWorkouts.isEmpty else {
                completion(.success([]))
                return
            }
            
            var restingHeartRates: [(date: Date, restingHeartRate: Double)] = []
            let group = DispatchGroup()
            
            for workout in climbingWorkouts {
                group.enter()
                self?.fetchRestingHeartRate(for: workout) { result in
                    switch result {
                    case .success(let restingHeartRate):
                        restingHeartRates.append((date: workout.startDate, restingHeartRate: restingHeartRate))
                    case .failure(let error):
                        print("Error fetching resting heart rate for workout: \(error)")
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                let sortedHeartRates = restingHeartRates.sorted { $0.date < $1.date }
                completion(.success(sortedHeartRates))
            }
        }
        
        healthStore.execute(query)
    }

    private func fetchRestingHeartRate(for workout: HKWorkout, completion: @escaping (Result<Double, Error>) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForObjects(from: workout)
        
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteMin) { _, result, error in
            guard let result = result, let minQuantity = result.minimumQuantity() else {
                completion(.failure(error ?? URLError(.badURL)))
                return
            }
            let restingHeartRate = minQuantity.doubleValue(for: HKUnit(from: "count/min"))
            completion(.success(restingHeartRate))
        }
        
        healthStore.execute(query)
    }
}

// MARK: - Fetch Lowest Heart Rate for Last 5 Climbing Workouts
extension HealthManager {
    func fetchLowestHeartRateForLastClimbingWorkouts(limit: Int = 5, completion: @escaping (Result<[(date: Date, heartRate: Double)], Error>) -> Void) {
        let workouts = HKSampleType.workoutType()
        let predicate = HKQuery.predicateForSamples(withStart: nil, end: Date())
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: workouts, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { [weak self] _, result, error in
            guard let workouts = result as? [HKWorkout], error == nil else {
                completion(.failure(error ?? URLError(.badURL)))
                return
            }
            
            // Filter for climbing workouts and limit to the last `limit` workouts
            let climbingWorkouts = workouts.filter { $0.workoutActivityType == .climbing }.prefix(limit)
            
            guard !climbingWorkouts.isEmpty else {
                completion(.success([]))
                return
            }
            
            var lowestHeartRates: [(date: Date, heartRate: Double)] = []
            let group = DispatchGroup()
            
            for workout in climbingWorkouts {
                group.enter()
                self?.fetchLowestHeartRate(for: workout) { result in
                    switch result {
                    case .success(let lowestHeartRate):
                        lowestHeartRates.append((date: workout.startDate, heartRate: lowestHeartRate))
                    case .failure(let error):
                        print("Error fetching lowest heart rate for workout: \(error)")
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                let sortedHeartRates = lowestHeartRates.sorted { $0.date < $1.date }
                completion(.success(sortedHeartRates))
            }
        }
        
        healthStore.execute(query)
    }

    private func fetchLowestHeartRate(for workout: HKWorkout, completion: @escaping (Result<Double, Error>) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForObjects(from: workout)
        
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteMin) { _, result, error in
            guard let result = result, let minQuantity = result.minimumQuantity() else {
                completion(.failure(error ?? URLError(.badURL)))
                return
            }
            let lowestHeartRate = minQuantity.doubleValue(for: HKUnit(from: "count/min"))
            completion(.success(lowestHeartRate))
        }
        
        healthStore.execute(query)
    }
}


// MARK: - Date Extension
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
    
    func fetchMonthStartAndEndDate() -> (Date, Date) {
        let calendar = Calendar.current
        let startDateComponent = calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: self))
        let startDate = calendar.date(from: startDateComponent) ?? self
        let endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startDate) ?? self
        
        return (startDate, endDate)
    }
    
    func formatWorkoutDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }
}

//MARK: - Weekly Climb Duration

extension HealthManager {
    // Fetch weekly climbing durations for the past 5 weeks
    func fetchWeeklyClimbingDuration(completion: @escaping (Result<[(weekStart: Date, duration: Double)], Error>) -> Void) {
        let workouts = HKSampleType.workoutType()
        let calendar = Calendar.current
        let endDate = Date()
        
        var durations: [(weekStart: Date, duration: Double)] = []
        var startDateComponents = DateComponents()
        startDateComponents.weekOfYear = -5

        // Calculate start date 5 weeks ago
        guard let startDate = calendar.date(byAdding: startDateComponents, to: calendar.startOfDay(for: endDate)) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        let query = HKSampleQuery(sampleType: workouts, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, result, error in
            guard let workouts = result as? [HKWorkout], error == nil else {
                completion(.failure(error ?? URLError(.badURL)))
                return
            }
            
            // Group workouts by week
            let groupedWorkouts = Dictionary(grouping: workouts.filter { $0.workoutActivityType == .climbing }) { workout -> Date in
                return calendar.dateInterval(of: .weekOfYear, for: workout.startDate)!.start
            }

            // Calculate total duration for each week
            for (weekStart, weekWorkouts) in groupedWorkouts {
                let totalDuration = weekWorkouts.reduce(0) { $0 + $1.duration / 60 }
                durations.append((weekStart, totalDuration))
            }

            // Ensure the array has exactly 5 entries, filling in empty weeks if necessary
            let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: endDate)!.start
            for i in 0..<5 {
                let weekStart = calendar.date(byAdding: .weekOfYear, value: -i, to: currentWeekStart)!
                if !durations.contains(where: { calendar.isDate($0.weekStart, inSameDayAs: weekStart) }) {
                    durations.append((weekStart, 0))
                }
            }
            
            // Sort by week start date and return the result
            let sortedDurations = durations.sorted { $0.weekStart < $1.weekStart }
            completion(.success(sortedDurations))
        }

        healthStore.execute(query)
    }
}

// MARK: - Double Extension
extension Double {
    func formattedNumberString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }
}

// MARK: - HealthManager Class
class HealthManager {
    static let shared = HealthManager()
    
    private let healthStore = HKHealthStore()
    
    private init() {
        Task {
            do {
                try await requestHealthKitAccess()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Request HealthKit Access
    func requestHealthKitAccess() async throws {
        let calories = HKQuantityType(.activeEnergyBurned)
        let exercise = HKQuantityType(.appleExerciseTime)
        let stand = HKCategoryType(.appleStandHour)
        let steps = HKQuantityType(.stepCount)
        let workouts = HKSampleType.workoutType()
        let heartRate = HKQuantityType(.heartRate)
        let hrv = HKQuantityType(.heartRateVariabilitySDNN) // Heart Rate Variability
        
        let healthTypes: Set = [calories, exercise, stand, steps, workouts, heartRate, hrv]
        try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
    }
    
    // MARK: - Fetch Recent HRV Data
    func fetchRecentHRVData(limit: Int = 5, completion: @escaping (Result<[(date: Date, hrv: Double)], Error>) -> Void) {
        let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let predicate = HKQuery.predicateForSamples(withStart: nil, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: hrvType, predicate: predicate, limit: limit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            if let error = error {
                print("Error fetching HRV data: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let samples = samples as? [HKQuantitySample], !samples.isEmpty else {
                print("No HRV data available.")
                completion(.success([]))
                return
            }
            
            let hrvValues = samples.map { sample in
                let hrv = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
                return (date: sample.startDate, hrv: hrv)
            }
            completion(.success(hrvValues))
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Fetch Average Heart Rate for Last 5 Climbing Workouts
    func fetchAverageHeartRateForLastClimbingWorkouts(limit: Int = 5, completion: @escaping (Result<[(date: Date, heartRate: Double)], Error>) -> Void) {
        let workouts = HKSampleType.workoutType()
        let predicate = HKQuery.predicateForSamples(withStart: nil, end: Date())
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: workouts, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { [weak self] _, result, error in
            guard let workouts = result as? [HKWorkout], error == nil else {
                completion(.failure(error ?? URLError(.badURL)))
                return
            }
            
            // Filter for climbing workouts and limit to the last `limit` workouts
            let climbingWorkouts = workouts.filter { $0.workoutActivityType == .climbing }.prefix(limit)
            
            guard !climbingWorkouts.isEmpty else {
                completion(.success([]))
                return
            }
            
            var averageHeartRates: [(date: Date, heartRate: Double)] = []
            let group = DispatchGroup()
            
            for workout in climbingWorkouts {
                group.enter()
                self?.fetchAverageHeartRate(for: workout) { result in
                    switch result {
                    case .success(let averageHeartRate):
                        averageHeartRates.append((date: workout.startDate, heartRate: averageHeartRate))
                    case .failure(let error):
                        print("Error fetching heart rate for workout: \(error)")
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                let sortedHeartRates = averageHeartRates.sorted { $0.date < $1.date }
                completion(.success(sortedHeartRates))
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchAverageHeartRate(for workout: HKWorkout, completion: @escaping (Result<Double, Error>) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForObjects(from: workout)
        
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, error in
            guard let result = result, let averageQuantity = result.averageQuantity() else {
                completion(.failure(error ?? URLError(.badURL)))
                return
            }
            let averageHeartRate = averageQuantity.doubleValue(for: HKUnit(from: "count/min"))
            completion(.success(averageHeartRate))
        }
        
        healthStore.execute(query)
    }
    
    
    
    // MARK: - Fetch Highest Heart Rate for Last 5 Climbing Workouts
    func fetchHighestHeartRateForLastClimbingWorkouts(limit: Int = 5, completion: @escaping (Result<[(date: Date, heartRate: Double)], Error>) -> Void) {
        let workouts = HKSampleType.workoutType()
        let predicate = HKQuery.predicateForSamples(withStart: nil, end: Date())
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: workouts, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { [weak self] _, result, error in
            guard let workouts = result as? [HKWorkout], error == nil else {
                completion(.failure(error ?? URLError(.badURL)))
                return
            }
            
            // Filter for climbing workouts and limit to the last `limit` workouts
            let climbingWorkouts = workouts.filter { $0.workoutActivityType == .climbing }.prefix(limit)
            
            guard !climbingWorkouts.isEmpty else {
                completion(.success([]))
                return
            }
            
            var highestHeartRates: [(date: Date, heartRate: Double)] = []
            let group = DispatchGroup()
            
            for workout in climbingWorkouts {
                group.enter()
                self?.fetchHighestHeartRate(for: workout) { result in
                    switch result {
                    case .success(let highestHeartRate):
                        highestHeartRates.append((date: workout.startDate, heartRate: highestHeartRate))
                    case .failure(let error):
                        print("Error fetching heart rate for workout: \(error)")
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                let sortedHeartRates = highestHeartRates.sorted { $0.date < $1.date }
                completion(.success(sortedHeartRates))
            }
        }
        
        healthStore.execute(query)
    }
    
    private func fetchHighestHeartRate(for workout: HKWorkout, completion: @escaping (Result<Double, Error>) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForObjects(from: workout)
        
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteMax) { _, result, error in
            guard let result = result, let maxQuantity = result.maximumQuantity() else {
                completion(.failure(error ?? URLError(.badURL)))
                return
            }
            let highestHeartRate = maxQuantity.doubleValue(for: HKUnit(from: "count/min"))
            completion(.success(highestHeartRate))
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Fetch Calories Burned Today
    func fetchTodayCaloriesBurned(completion: @escaping (Result<Double, Error>) -> Void) {
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(error ?? URLError(.badURL)))
                return
            }
            
            let calorieCount = quantity.doubleValue(for: .kilocalorie())
            completion(.success(calorieCount))
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Fetch Exercise Time Today
    func fetchTodayExerciseTime(completion: @escaping (Result<Double, Error>) -> Void) {
        let exercise = HKQuantityType(.appleExerciseTime)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: exercise, quantitySamplePredicate: predicate) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(error ?? URLError(.badURL)))
                return
            }
            
            let exerciseTime = quantity.doubleValue(for: .minute())
            completion(.success(exerciseTime))
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Fetch Stand Hours Today
    func fetchTodayStandHours(completion: @escaping (Result<Int, Error>) -> Void) {
        let stand = HKCategoryType(.appleStandHour)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKSampleQuery(sampleType: stand, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, error in
            guard let samples = results as? [HKCategorySample], error == nil else {
                completion(.failure(error ?? URLError(.badURL)))
                return
            }
            
            let standCount = samples.filter { $0.value == 0 }.count
            completion(.success(standCount))
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Fetch Today's Step Count
    func fetchTodaySteps(completion: @escaping (Result<Activity, Error>) -> Void) {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, results, error in
            guard let quantity = results?.sumQuantity(), error == nil else {
                completion(.failure(error ?? URLError(.badURL)))
                return
            }
            
            let steps = quantity.doubleValue(for: .count())
            let activity = Activity(title: "Steps", subtitle: "Today", image: "figure.walk", tintColor: .green, amount: steps.formattedNumberString())
            completion(.success(activity))
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Fetch Current Week's Climbing Workout Stats
    func fetchCurrentWeekWorkoutStats(completion: @escaping (Result<[Activity], Error>) -> Void) {
        let workouts = HKSampleType.workoutType()
        let predicate = HKQuery.predicateForSamples(withStart: .startOfWeek, end: Date())
        let query = HKSampleQuery(sampleType: workouts, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, results, error in
            guard let workouts = results as? [HKWorkout], let self = self, error == nil else {
                completion(.failure(error ?? URLError(.badURL)))
                return
            }
            
            var climbingCount: Int = 0
            
            for workout in workouts {
                let duration = Int(workout.duration) / 60
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
    
    
    // MARK: - Fetch Workouts for the Month
    func fetchWorkoutsForMonth(month: Date, completion: @escaping (Result<[Workout], Error>) -> Void) {
        let workouts = HKSampleType.workoutType()
        let (startDate, endDate) = month.fetchMonthStartAndEndDate()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: workouts, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, result, error in
            guard let workouts = result as? [HKWorkout], error == nil else {
                completion(.failure(error ?? URLError(.badURL)))
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
                    duration: "\(Int(workout.duration) / 60) mins",
                    date: workout.startDate.formatWorkoutDate(),
                    calories: (energyBurned?.formattedNumberString() ?? "-") + " kcal"
                )
            }
            
            completion(.success(workoutArray))
        }
        healthStore.execute(query)
    }
    
    // MARK: - Fetch Last Ten Climbing Workouts
    func fetchLastTenClimbingWorkouts(completion: @escaping (Result<[Workout], Error>) -> Void) {
        let workouts = HKSampleType.workoutType()
        let predicate = HKQuery.predicateForSamples(withStart: nil, end: Date())
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: workouts, predicate: predicate, limit: 10, sortDescriptors: [sortDescriptor]) { _, result, error in
            guard let workouts = result as? [HKWorkout], error == nil else {
                completion(.failure(error ?? URLError(.badURL)))
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
                    duration: "\(Int(workout.duration) / 60) mins",
                    date: workout.startDate.formatWorkoutDate(),
                    calories: (energyBurned?.formattedNumberString() ?? "0") + " kcal"
                )
            }
            
            completion(.success(workoutArray))
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Estimate Recovery Time Based on Heart Rate and Intensity
    func estimateRecoveryTimeForLastClimbingWorkouts(limit: Int = 5, completion: @escaping (Result<[(date: Date, recoveryTime: TimeInterval)], Error>) -> Void) {
        let workouts = HKSampleType.workoutType()
        let predicate = HKQuery.predicateForSamples(withStart: nil, end: Date())
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: workouts, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { [weak self] _, result, error in
            guard let workouts = result as? [HKWorkout], error == nil else {
                completion(.failure(error ?? URLError(.badURL)))
                return
            }
            
            // Filter for climbing workouts and limit to the last `limit` workouts
            let climbingWorkouts = workouts.filter { $0.workoutActivityType == .climbing }.prefix(limit)
            
            guard !climbingWorkouts.isEmpty else {
                completion(.success([]))
                return
            }
            
            var recoveryTimes: [(date: Date, recoveryTime: TimeInterval)] = []
            let group = DispatchGroup()
            
            for workout in climbingWorkouts {
                group.enter()
                self?.calculateRecoveryTime(for: workout) { result in
                    switch result {
                    case .success(let recoveryTime):
                        recoveryTimes.append((date: workout.startDate, recoveryTime: recoveryTime))
                    case .failure(let error):
                        print("Error calculating recovery time for workout: \(error)")
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                let sortedRecoveryTimes = recoveryTimes.sorted { $0.date < $1.date }
                completion(.success(sortedRecoveryTimes))
            }
        }
        
        healthStore.execute(query)
    }

    private func calculateRecoveryTime(for workout: HKWorkout, completion: @escaping (Result<TimeInterval, Error>) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForObjects(from: workout)
        
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: [.discreteMax, .discreteAverage]) { _, result, error in
            guard let result = result,
                  let maxQuantity = result.maximumQuantity(),
                  let avgQuantity = result.averageQuantity() else {
                completion(.failure(error ?? URLError(.badURL)))
                return
            }
            
            let maxHeartRate = maxQuantity.doubleValue(for: HKUnit(from: "count/min"))
            let avgHeartRate = avgQuantity.doubleValue(for: HKUnit(from: "count/min"))
            
            // Simplified model for recovery time (in seconds)
            // The recovery time could be estimated using a more complex model in a real application
            let recoveryTime = workout.duration * maxHeartRate / avgHeartRate
            completion(.success(recoveryTime))
        }
        
        healthStore.execute(query)
    }
    
    func fetchAndStoreMonthlyClimbingMinutes(for userId: String) {
            fetchMonthlyClimbingMinutes { result in
                switch result {
                case .success(let totalMinutes):
                    // Store totalMinutes in Firestore
                    let db = Firestore.firestore()
                    let userRef = db.collection("users").document(userId)
                    
                    userRef.updateData([
                        "monthlyClimbingMinutes": totalMinutes
                    ]) { error in
                        if let error = error {
                            print("Error updating Firestore: \(error)")
                        } else {
                            print("Climbing minutes successfully updated in Firestore.")
                        }
                    }
                    
                case .failure(let error):
                    print("Error fetching climbing minutes: \(error)")
                }
            }
        }
        
        // Fetch Monthly Climbing Minutes from HealthKit
        func fetchMonthlyClimbingMinutes(completion: @escaping (Result<Double, Error>) -> Void) {
            let workouts = HKSampleType.workoutType()
            let (startDate, endDate) = Date().fetchMonthStartAndEndDate()
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            
            let query = HKSampleQuery(sampleType: workouts, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, result, error in
                guard let workouts = result as? [HKWorkout], error == nil else {
                    completion(.failure(error ?? URLError(.badURL)))
                    return
                }
                
                let totalMinutes = workouts
                    .filter { $0.workoutActivityType == .climbing }
                    .reduce(0) { $0 + ($1.duration / 60) }
                
                completion(.success(totalMinutes))
            }
            
            healthStore.execute(query)
        }
    
    // Function to fetch all Climbing workouts
       func fetchClimbingWorkouts(completion: @escaping (Result<[Workout], Error>) -> Void) {
           let workoutType = HKSampleType.workoutType()
           
           // Predicate to filter for Climbing workouts
           let climbingPredicate = HKQuery.predicateForWorkouts(with: .climbing)
           let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
           
           let query = HKSampleQuery(sampleType: workoutType, predicate: climbingPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, result, error in
               guard let hkWorkouts = result as? [HKWorkout], error == nil else {
                   completion(.failure(error ?? URLError(.badURL)))
                   return
               }
               
               let workoutArray = hkWorkouts.map { workout -> Workout in
                   let energyBurned = workout.statistics(for: HKQuantityType(.activeEnergyBurned))?.sumQuantity()?.doubleValue(for: .kilocalorie())
                   
                   return Workout(
                       id: workout.uuid.hashValue,
                       title: "Climbing", // Assuming all results are climbing
                       image: "figure.climbing",  // Replace with the correct image
                       duration: "\(Int(workout.duration) / 60) mins",
                       date: workout.startDate.formatWorkoutDate(),
                       calories: (energyBurned?.formattedNumberString() ?? "0") + " kcal"
                   )
               }
               
               completion(.success(workoutArray))
           }
           
           healthStore.execute(query)
       }
   }


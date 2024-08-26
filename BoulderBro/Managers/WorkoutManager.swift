//
//  WorkoutManager.swift
//  BoulderBro
//
//  Created by Hazz on 26/08/2024.
//

import SwiftUI
import Combine

class WorkoutManager: ObservableObject {
    @Published var isClimbingWorkoutActive: Bool = false
    
    func startWorkout() {
        isClimbingWorkoutActive = true
    }
    
    func stopWorkout() {
        isClimbingWorkoutActive = false
    }
}

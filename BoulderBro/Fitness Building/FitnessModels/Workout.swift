//
//  Workout.swift
//  BoulderBro
//
//  Created by Hazz on 17/08/2024.
//

import SwiftUI

struct Workout: Identifiable {
    let id: Int           // Use your existing Int id as the identifier
    let title: String
    let image: String
    let duration: String
    let tintColor: Color
    let date: String
    let calories: String
}

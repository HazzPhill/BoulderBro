//
//  Climb.swift
//  BoulderBro
//
//  Created by Hazz on 20/08/2024.
//

import Foundation

struct Climb: Identifiable {
    var id: String
    var name: String
    var climbtype: String
    var difficulty: String
    var vRating: String
    var mediaURL: String
    var isFavorite: Bool = false // Add this property
}

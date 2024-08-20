//
//  Climb.swift
//  BoulderBro
//
//  Created by Hazz on 20/08/2024.
//

import Foundation

struct Climb: Identifiable {
    var id: String // Firestore document ID
    var name: String
    var location: String
    var difficulty: String
    var vRating: String
    var mediaURL: String // Image or video URL
}

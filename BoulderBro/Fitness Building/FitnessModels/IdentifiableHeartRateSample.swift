//
//  IdentifiableHeartRateSample.swift
//  BoulderBro
//
//  Created by Hazz on 25/08/2024.
//

import HealthKit

struct IdentifiableHeartRateSample: Identifiable {
    let id = UUID()
    let startDate: Date
    let heartRate: Double
    
    init(sample: HKQuantitySample) {
        self.startDate = sample.startDate
        self.heartRate = sample.quantity.doubleValue(for: .count().unitDivided(by: .minute()))
    }
}

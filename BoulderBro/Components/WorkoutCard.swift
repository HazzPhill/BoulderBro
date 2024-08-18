//
//  WorkoutCard.swift
//  BoulderBro
//
//  Created by Hazz on 17/08/2024.
//

import SwiftUI

struct WorkoutCard: View {
    @State var workout: Workout
    @Environment(\.colorScheme) var colorScheme // To detect the current color
    var body: some View {
        HStack {
            Image(systemName:workout.image)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height:48)
                .foregroundStyle(workout.tintColor)
                .padding()
                .background(Color(colorScheme == .dark ? Color(hex: "#333333") : .white))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack (alignment: .leading) {
                HStack {
                    Text (workout.title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Spacer()
                    Text (workout.duration)
                }
                
                HStack {
                    Text (workout.date)
                    Spacer()
                    Text (workout.calories)
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    WorkoutCard(workout: Workout(id: 0, title: "Climbing", image: "figure.run", duration: "24 mins", tintColor: Color(hex: "#FF5733"), date: " August 4", calories: "461 kcal"))
}

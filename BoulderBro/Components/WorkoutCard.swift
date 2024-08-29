//
//  WorkoutCard.swift
//  BoulderBro
//
//  Created by Hazz on 17/08/2024.
//

import SwiftUI

struct WorkoutCard: View {
    @State var workout: Workout
    @Environment(\.colorScheme) var colorScheme // To detect the current color scheme
    @EnvironmentObject var colorThemeManager: ColorThemeManager // Access the theme color
    
    var body: some View {
        HStack {
            Image(systemName: workout.image)
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .foregroundStyle(colorThemeManager.currentThemeColor) // Use theme color
                .padding()
                .background(Color(colorScheme == .dark ? Color(hex: "#212121") : Color(hex: "#ECECEC")))
                .clipShape(Circle())
                .padding(.trailing, 8) // Adjust padding to your preference
            
            VStack(alignment: .leading, spacing: 4) { // Adjust spacing between texts
                HStack {
                    Text(workout.title)
                        .font(.custom("Kurdis-ExtraWideBold", size: 16))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Spacer()
                    Text(workout.duration)
                        .font(.subheadline)
                        .foregroundColor(.secondary) // Optional: Make the duration text less prominent
                }
                
                HStack {
                    Text(workout.date)
                        .font(.subheadline)
                        .foregroundColor(.secondary) // Optional: Make the date text less prominent
                    Spacer()
                    Text(workout.calories)
                        .font(.subheadline)
                        .foregroundColor(.secondary) // Optional: Make the calories text less prominent
                }
            }
        }
        .padding()
        .background(Color(colorScheme == .dark ? Color(hex: "#333333") : .white))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    let colorThemeManager = ColorThemeManager() // Create an instance of ColorThemeManager
    WorkoutCard(workout: Workout(id: 0, title: "Climbing", image: "figure.run", duration: "24 mins", date: "August 4", calories: "461 kcal"))
        .environmentObject(colorThemeManager) // Inject the colorThemeManager into the environment
}

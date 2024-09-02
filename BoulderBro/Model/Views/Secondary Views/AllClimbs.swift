//
//  AllClimbs.swift
//  BoulderBro
//
//  Created by Hazz on 27/08/2024.
//

import SwiftUI
import Charts

struct AllClimbsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var colorThemeManager: ColorThemeManager

    var climbs: [Climb]

    var body: some View {
        ZStack {
            // Use customizable MovingCircles
            MovingCircles(
                topCircleColor: colorThemeManager.currentThemeColor,
                bottomCircleColor: colorThemeManager.currentThemeColor,
                topCircleOpacity: 0.3,
                bottomCircleOpacity: 0.3,
                backgroundColor: Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color(hex: "#f1f0f5"))
            )
            .ignoresSafeArea()

            // Content of the view
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("All Climbs")
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .font(.custom("Kurdis-ExtraWideBlack", size: 30))
                        .fontWeight(.bold)
                        .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))
                        .opacity(0.7)
                        .padding(.top, 30)
                        .padding(.bottom, 15)
                    
                    HStack {
                        
                        NavigationLink(destination: LogClimbView()) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(Color(hex:"#0093AA"))
                                .frame(width: 45, height: 45)
                        }
                        
                        Image(systemName: "heart.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color(hex:"#0093AA"))
                            .frame(width: 45, height: 45)
                        
                        Spacer()

                        NavigationLink(destination: AllClimbsView(climbs: climbs)) {
                            Text("Show More")
                                .font(.custom("Kurdis-ExtraWideBold", size: 16))
                                .foregroundStyle(Color.white)
                                .padding()
                                .background(Color.gray)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                    }
                    
                    // List of all climbs
                    ForEach(climbs) { climb in
                        NavigationLink(destination: TheClimb(climb: climb)) {
                            PersonalClimb(climb: climb)
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // Function to parse V rating from String to Int
    func parseVRating(_ rating: String) -> Int {
        return Int(rating.trimmingCharacters(in: CharacterSet.letters)) ?? 0
    }
}

#Preview {
    AllClimbsView(climbs: [Climb(id: "1", name: "Climb 1", climbtype: "OverHang", difficulty: "V5", vRating: "V5", mediaURL: "")])
        .environmentObject(AuthViewModel()) // Ensure the environment object is provided for the preview
}

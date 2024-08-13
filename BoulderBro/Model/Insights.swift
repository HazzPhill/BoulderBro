//
//  Insights.swift
//  BoulderBro
//
//  Created by Hazz on 13/08/2024.
//

import SwiftUI

struct Insights: View {
    var body: some View {
        ZStack {
            // Sticky Gradient Background
            GeometryReader { geometry in
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#FF5733"), .white]),
                    startPoint: .top,
                    endPoint: UnitPoint(x: 0.5, y: 0.25) // Custom endPoint
                )
                .frame(height: 900) // Adjust height of the gradient
                .ignoresSafeArea(edges: .top)
                .position(x: geometry.size.width / 2, y: 100) // Keep the gradient at the top center
            }
            .frame(height: 200) // Make sure the gradient only occupies the top area
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Summary")
                        .padding(.top, 12) // Padding top
                        .padding(.bottom, 15) // Padding bottom
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.black))
                    
                    Rectangle()
                        .frame(height: 163)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(Color(.white))
                        .shadow(radius: 20)
                    
                    HStack {
                        Rectangle()
                            .frame(height: 163)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(Color(.white))
                            .zIndex(1)
                        
                        Rectangle()
                            .frame(height: 163)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(Color(.white))
                            .zIndex(1)
                    }
                    .shadow(radius: 20)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.black))
                    .padding(.top, 15)
                    .padding(.bottom)
                    
                    Text ("Hang Timer")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.black))
                        .padding(.top,5)
                        .padding(.bottom, 15)
                    
                    Rectangle()
                        .frame(height: 125)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(Color(.white))
                        .shadow(radius: 20)
                    
                    Text("Previous 5 climb workouts")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.black))
                        .padding(.top, 15)
                        .padding(.bottom, 15)
                    
                    // Box for smaller boxes
                    ZStack {
                        Rectangle()
                            .frame(height: 208)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(Color(.white))
                            .shadow(radius: 20)
                        
                        // Grid of 4 customizable boxes with consistent sizes
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(minimum: 0, maximum: 165)), // Column width controlled by grid
                                GridItem(.flexible(minimum: 0, maximum: 165))
                            ],
                            spacing: 10
                        ) {
                            CustomBox1()
                            CustomBox2()
                            CustomBox3()
                            CustomBox4()
                        }
                        .padding(10) // Padding inside the larger box
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
        }
    }
}

// Custom Box 1
struct CustomBox1: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Avg. Session")
                .font(.headline)
                .foregroundColor(.black)
            Text("49 Min")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color(hex: "#FF5733"))
        }
        .padding()
        .frame(width: 165, height: 90) // Fixed size for consistency
        .background(Color(.white))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 5)
    }
}

// Custom Box 2
struct CustomBox2: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Avg. Heart Rate")
                .font(.headline)
                .foregroundColor(.black)
            Text("113 Bpm")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color(hex: "#FF5733"))
        }
        .padding()
        .frame(width: 165, height: 90) // Fixed size for consistency
        .background(Color(.white))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 5)
    }
}

// Custom Box 3
struct CustomBox3: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Total Calories")
                .font(.headline)
                .foregroundColor(.black)
            Text("837")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color(hex: "#FF5733"))
        }
        .padding()
        .frame(width: 165, height: 90) // Fixed size for consistency
        .background(Color(.white))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 5)
    }
}

// Custom Box 4
struct CustomBox4: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Active Calories")
                .font(.headline)
                .foregroundColor(.black)
            Text("632")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color(hex: "#FF5733"))
        }
        .padding()
        .frame(width: 165, height: 90) // Fixed size for consistency
        .background(Color(.white))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 5)
    }
}

// SwiftUI preview
#Preview {
    Insights()
}

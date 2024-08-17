//
//  ProgressCircleView.swift
//  BoulderBro
//
//  Created by Hazz on 17/08/2024.
//

import SwiftUI

struct ProgressCircleView: View {
    
    @Binding var progress: Int
    var goal: Int
    var color: Color
    private let width: CGFloat = 20
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 20) // Apply stroke directly to the first Circle
            
            Circle()
                .trim(from: 0, to: CGFloat(progress)/CGFloat(goal))
                .stroke(color, style:StrokeStyle(lineWidth: 20, lineCap: .round)) // Apply stroke directly to the second Circle
                .rotationEffect(.degrees(-90))
        }
        .padding()
    }
}

#Preview {
    ProgressCircleView(progress: .constant(100), goal: 200, color: .red)
}

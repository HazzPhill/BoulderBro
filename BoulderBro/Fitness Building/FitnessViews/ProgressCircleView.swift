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
                .stroke(color.opacity(0.1), lineWidth: 20)

            // Calculate progress, ensuring it's never 0 to avoid division by zero
            let safeProgress = max(progress, 1) // Or any other suitable minimum value > 0
            let progressRatio = CGFloat(safeProgress) / CGFloat(goal)

            Circle()
                .trim(from: 0, to: progressRatio)
                .stroke(color, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .padding()
    }
}

#Preview {
    ProgressCircleView(progress: .constant(100), goal: 200, color: .red)
}

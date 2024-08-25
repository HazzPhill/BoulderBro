import SwiftUI

struct ProgressCircleView: View {
    @Binding var progress: Int
    var goal: Int
    var color: Color
    private let width: CGFloat = 20

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.1), lineWidth: width)

            // Calculate progress ratio, ensuring it stays between 0 and 1
            let progressRatio = min(max(CGFloat(progress) / CGFloat(goal), 0), 1)

            Circle()
                .trim(from: 0, to: progressRatio)
                .stroke(color, style: StrokeStyle(lineWidth: width, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .padding()
    }
}

#Preview {
    ProgressCircleView(progress: .constant(0), goal: 200, color: .red)
}

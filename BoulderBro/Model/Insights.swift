import SwiftUI
import HealthKit
import HealthKitUI

struct Insights: View {
    @State private var activeCalories: Double = 0
    @State private var totalCalories: Double = 0
    @State private var avgSessionDuration: TimeInterval = 0
    @State private var avgHeartRate: Double = 0

    private let healthStore = HKHealthStore()

    @State private var isTimerRunning = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State private var lastScore: TimeInterval = 0
    @State private var personalBest: TimeInterval = 0

    var body: some View {
        ZStack {
            // Sticky Gradient Background
            GeometryReader { geometry in
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#FF5733"), .white]),
                    startPoint: .top,
                    endPoint: UnitPoint(x: 0.5, y: 0.25)
                )
                .frame(height: 900)
                .ignoresSafeArea(edges: .top)
                .position(x: geometry.size.width / 2, y: 100)
            }
            .frame(height: 200)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Summary")
                        .padding(.top, 12)
                        .padding(.bottom, 15)
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

                    Text("Hang Timer")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.black))
                        .padding(.top, 5)
                        .padding(.bottom, 15)

                    Rectangle()
                        .frame(height: 125)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(Color(.white))
                        .shadow(radius: 20)
                        .overlay(
                            VStack {
                                HStack {
                                    Text(elapsedTime.formattedDurationWithMilliseconds())
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color(hex: "#FF5733"))
                                    
                                    Button(action: {
                                        isTimerRunning.toggle()
                                        if !isTimerRunning {
                                            lastScore = elapsedTime
                                            if lastScore > personalBest {
                                                personalBest = lastScore
                                            }
                                            elapsedTime = 0
                                        }
                                    }) {
                                        Image(systemName: isTimerRunning ? "pause.circle.fill" : "play.circle.fill")
                                            .resizable()         // Make the image resizable
                                                .scaledToFit()       // Scale the image to fit the frame while maintaining aspect ratio
                                                .frame(width: 30, height: 30) // Set a large frame size
                                            .foregroundStyle(((isTimerRunning ? Color.red : Color(hex: "#FF5733"))))
                                        
                                    }
                                    
                                    Spacer()
                                    
                                    VStack {
                                        VStack(alignment: .leading) {
                                            Text("Last:")
                                                .font(.subheadline)
                                            Text(lastScore.formattedDurationWithMilliseconds())
                                                .font(.footnote)
                                        }
                                        Spacer()
                                        VStack(alignment: .leading) {
                                            Text("PB:")
                                                .font(.subheadline)
                                            Text(personalBest.formattedDurationWithMilliseconds())
                                                .font(.footnote)
                                        }
                                    }
                                }

                                
                                .font(.headline)
                                .padding(.horizontal)
                            }
                            .padding()
                        )

                    Text("Previous 5 climb workouts")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.black))
                        .padding(.top, 15)
                        .padding(.bottom, 15)

                    ZStack {
                        Rectangle()
                            .frame(height: 208)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(Color(.white))
                            .shadow(radius: 20)

                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(minimum: 0, maximum: 165)),
                                GridItem(.flexible(minimum: 0, maximum: 165))
                            ],
                            spacing: 10
                        ) {
                            MetricView(
                                title: "Active Calories",
                                value: activeCalories,
                                unit: "cal"
                            )

                            MetricView(
                                title: "Total Calories",
                                value: totalCalories,
                                unit: "cal"
                            )

                            MetricView(
                                title: "Avg. Session",
                                value: avgSessionDuration,
                                unit: ""
                            )

                            MetricView(
                                title: "Avg. Heart Rate",
                                value: avgHeartRate,
                                unit: "bpm"
                            )
                        }
                        .padding(10)
                        .onAppear {
                            fetchWorkoutData()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
        }
        .onReceive(timer) { _ in
            if isTimerRunning {
                elapsedTime += 0.01
            }
        }
    }

    private func fetchWorkoutData() {
        // ... (Your existing fetchWorkoutData function)
    }
}

struct MetricView: View {
    var title: String
    var value: Double
    var unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)

            
            if unit == "" {
                Text(value.formattedDurationWithMilliseconds())
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "#FF5733"))
            } else {
                Text("\(value, specifier: "%.0f") \(unit)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "#FF5733"))
            }
        }
        .padding()
        .frame(width: 165, height: 90)
        .background(Color(.white))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 5)
    }
}

extension TimeInterval {
    func formattedDurationWithMilliseconds() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        formatter.unitsStyle = .positional

        let formattedString = formatter.string(from: self) ?? ""
        let milliseconds = Int((self.truncatingRemainder(dividingBy: 1)) * 100)
        return "\(formattedString).\(String(format: "%02d", milliseconds))"
    }
}

#Preview {
    Insights()
}

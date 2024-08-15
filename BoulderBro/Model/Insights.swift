import SwiftUI
import HealthKit
import HealthKitUI
import Charts

// MARK: - Data Model

struct WorkoutData: Identifiable {
    let id = UUID()
    let date: Date
    let caloriesBurnt: Double
    let duration: TimeInterval // New property to store session duration
}

// MARK: - Main Insights View

struct Insights: View {
    // MARK: - State Variables

    @State private var activeCalories: Double = 0
    @State private var totalCalories: Double = 0
    @State private var avgSessionDuration: TimeInterval = 0
    @State private var avgHeartRate: Double = 0
    @State private var workoutData: [WorkoutData] = []

    private let healthStore = HKHealthStore()

    @State private var isTimerRunning = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    @State private var lastScore: TimeInterval = 0
    @State private var personalBest: TimeInterval = 0

    // MARK: - Body

    var body: some View {
        ZStack {
            // MARK: - Sticky Gradient Background
            GeometryReader { geometry in
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#FF5733"), Color(hex: "#f2f1f6")]),
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
                    // MARK: - Summary Section
                    Text("Summary")
                        .padding(.top, 12)
                        .padding(.bottom, 15)
                        .font(.custom("Kurdis-ExtraWideBlack", size: 30))
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.black))
                        .opacity(0.7)

                    // MARK: - Line Chart Rectangle
                    Rectangle()
                        .frame(height: 163)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(Color(.white))
                        .overlay(
                            Chart {
                                ForEach(workoutData) { data in
                                    LineMark(
                                        x: .value("Date", data.date, unit: .day),
                                        y: .value("Calories", data.caloriesBurnt)
                                    )
                                    .foregroundStyle(Color(hex: "#FF5733"))

                                    PointMark(
                                        x: .value("Date", data.date, unit: .day),
                                        y: .value("Calories", data.caloriesBurnt)
                                    )
                                    .symbol(by: .value("Calories", data.caloriesBurnt))
                                    .symbolSize(30)
                                    .foregroundStyle(Color.red)
                                }
                            }
                            .padding()
                        )
                        .onAppear {
                            fetchWorkoutData() // Fetch data when view appears
                        }

                    // MARK: - Metrics Section
                    HStack {
                        // MARK: Avg. Session Duration
                        Rectangle()
                            .frame(height: 163)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(Color(.white))
                            .overlay(
                                VStack(alignment: .leading) {
                                    Text("Avg. Session Duration")
                                        .font(.custom("Kurdis-ExtraWideBold", size: 15))
                                        .foregroundColor(.black)
                                        .padding(.top)
                                    Spacer()
                                    Text(avgSessionDuration.formattedDurationWithMilliseconds())
                                        .font(.custom("Kurdis-ExtraWideBold", size: 22))
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color(hex: "#FF5733"))
                                        .padding(.bottom)
                                }
                                .padding()
                            )
                            .zIndex(1)

                        // MARK: Current Level
                        Rectangle()
                            .frame(height: 163)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(Color(.white))
                            .overlay(
                                VStack(alignment: .center) {
                                    Text("Current Level")
                                        .font(.custom("Kurdis-ExtraWideBold", size: 15))
                                        .foregroundColor(.black)
                                        .padding(.top)
                                    Text("V6")
                                        .font(.custom("Kurdis-ExtraWideBlack", size: 40))
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color(hex: "#FF5733"))
                                        .padding()
                                }
                            )
                            .zIndex(1)
                    }
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.black))
                    .padding(.top, 15)
                    .padding(.bottom)

                    // MARK: - Hang Timer Section
                    Text("Hang Timer")
                        .font(.custom("Kurdis-ExtraWideBold", size: 20))
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: "#3F3F3F"))
                        .padding(.top)

                    Rectangle()
                        .frame(height: 125)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .foregroundStyle(Color(.white))
                        .overlay(
                            VStack {
                                HStack {
                                    ZStack(alignment: .leading) {
                                        // Fixed width background to hold the timer text
                                        Color.clear.frame(width: 150)
                                        Text(elapsedTime.formattedDurationWithMilliseconds())
                                            .font(.custom("Kurdis-ExtraWideBold", size: 22))
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color(hex: "#FF5733"))
                                    }

                                    // Static Play/Pause Button
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
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .foregroundStyle((isTimerRunning ? Color.red : Color(hex: "#FF5733")))
                                            .padding()
                                    }

                                    Spacer() // Spacer to push content to the right

                                    // Last/PB Section
                                    VStack(alignment: .leading) {
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

                    // MARK: - Previous Workouts Section
                    Text("Previous 5 climb workouts")
                        .font(.custom("Kurdis-ExtraWideBold", size: 20))
                        .fontWeight(.bold)
                        .foregroundStyle(Color(hex: "#3F3F3F"))
                        .padding(.top)

                    ZStack {
                        Rectangle()
                            .frame(height: 208)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundStyle(Color(.white))

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
                elapsedTime += 0.01 // Update the time increment to match the timer frequency
            }
        }
    }

    // MARK: - Data Fetching

    private func fetchWorkoutData() {
        // Mock data for demonstration
        workoutData = [
            WorkoutData(date: Date().addingTimeInterval(-86400 * 11), caloriesBurnt: 300, duration: 3600),
            WorkoutData(date: Date().addingTimeInterval(-86400 * 10), caloriesBurnt: 320, duration: 4000),
            WorkoutData(date: Date().addingTimeInterval(-86400 * 9), caloriesBurnt: 310, duration: 3500),
            WorkoutData(date: Date().addingTimeInterval(-86400 * 8), caloriesBurnt: 290, duration: 3700),
            WorkoutData(date: Date().addingTimeInterval(-86400 * 7), caloriesBurnt: 330, duration: 3800),
            WorkoutData(date: Date().addingTimeInterval(-86400 * 6), caloriesBurnt: 340, duration: 3900),
            WorkoutData(date: Date().addingTimeInterval(-86400 * 5), caloriesBurnt: 300, duration: 3600),
            WorkoutData(date: Date().addingTimeInterval(-86400 * 4), caloriesBurnt: 350, duration: 4100),
            WorkoutData(date: Date().addingTimeInterval(-86400 * 3), caloriesBurnt: 360, duration: 4200),
            WorkoutData(date: Date().addingTimeInterval(-86400 * 2), caloriesBurnt: 330, duration: 4300),
            WorkoutData(date: Date().addingTimeInterval(-86400 * 1), caloriesBurnt: 310, duration: 4400),
            WorkoutData(date: Date(), caloriesBurnt: 320, duration: 4500),
        ]

        // Calculate average session duration
        if !workoutData.isEmpty {
            let totalDuration = workoutData.reduce(0) { $0 + $1.duration }
            avgSessionDuration = totalDuration / Double(workoutData.count)
        }
    }
}

// MARK: - Metric View Component

struct MetricView: View {
    var title: String
    var value: Double
    var unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.custom("Kurdis-ExtraWideBold", size: 11))
                .foregroundColor(.black)

            if unit == "" {
                Text(value.formattedDurationWithMilliseconds())
                    .font(.custom("Kurdis-ExtraWideBold", size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "#FF5733"))
            } else {
                Text("\(value, specifier: "%.0f") \(unit)")
                    .font(.custom("Kurdis-ExtraWideBold", size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(Color(hex: "#FF5733"))
            }
        }
        .padding()
        .frame(width: 165, height: 90)
        .background(Color(.white))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - TimeInterval Extension

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

// MARK: - Preview

#Preview {
    Insights()
}


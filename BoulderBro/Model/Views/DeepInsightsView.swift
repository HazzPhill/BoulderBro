import SwiftUI

struct DeepInsightsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var colorThemeManager: ColorThemeManager

    var body: some View {
        ZStack {
            // Background that ignores safe areas
            Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color(hex: "#f1f0f5"))
                .ignoresSafeArea(edges: .all)

            // Content that respects safe areas
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Take a deep look!")
                        .font(.custom("Kurdis-ExtraWideBold", size: 24))
                        .padding(.bottom)

                    Group {
                        Text("Calories Burnt")
                            .font(.custom("Kurdis-ExtraWideBold", size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))

                        Text("Calories Burnt in your last workouts")
                            .font(.custom("Kurdis-Regular", size: 11))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#d4d4d4") : Color(hex: "#6b6b6b")))
                            .padding(.bottom)

                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#333333") : .white))
                                .frame(height: 185)

                            CaloriesChart()
                                .frame(height: 185)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .frame(maxWidth: .infinity) // Constrain chart width
                        }
                    }

                    Group {
                        Text("Avg. Session Duration")
                            .font(.custom("Kurdis-ExtraWideBold", size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))

                        Text("Average session duration of your last workouts")
                            .font(.custom("Kurdis-Regular", size: 11))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#d4d4d4") : Color(hex: "#6b6b6b")))
                            .padding(.bottom)

                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#333333") : .white))
                                .frame(height: 200)

                            DurationChart()
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .frame(maxWidth: .infinity) // Constrain chart width
                        }
                    }

                    Group {
                        Text("Avg. Heart Rate")
                            .font(.custom("Kurdis-ExtraWideBold", size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))

                        Text("Average heart rate of your last workouts")
                            .font(.custom("Kurdis-Regular", size: 11))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#d4d4d4") : Color(hex: "#6b6b6b")))
                            .padding(.bottom)

                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#333333") : .white))
                                .frame(height: 200)

                            HeartRateChart()
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .frame(maxWidth: .infinity) // Constrain chart width
                        }
                    }

                    Group {
                        Text("Overall Avg. Heart Rate")
                            .font(.custom("Kurdis-ExtraWideBold", size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))

                        Text("Average climbing heart rate recently")
                            .font(.custom("Kurdis-Regular", size: 11))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#d4d4d4") : Color(hex: "#6b6b6b")))
                            .padding(.bottom)

                        HStack(spacing: 20) { // Added spacing
                            HeartRateActivityCard()
                            Spacer()
                            HighestHeartRateActivityCard()
                        }
                    }

                    Group {
                        Text("AI Driven Insights")
                            .font(.custom("Kurdis-ExtraWideBold", size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))

                        Text("AI driven insights based off your climbing data")
                            .font(.custom("Kurdis-Regular", size: 11))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#d4d4d4") : Color(hex: "#6b6b6b")))
                            .padding(.bottom)

                        HStack(spacing: 20) { // Added spacing
                            RecoveryTimeActivityCard()
                            Spacer()
                            HRVActivityCard()
                        }

                        HStack {
                            Image(systemName: "bed.double.fill")
                                .foregroundStyle(colorThemeManager.currentThemeColor)
                                .padding(.trailing)
                            VStack(alignment: .leading) {
                                Text("Recovery Time:")
                                    .font(.custom("Kurdis-ExtraWideBold", size: 11))
                                    .fontWeight(.bold)

                                Text("Hydrate, and engage in light activity like stretching or walking to promote muscle recovery.")
                                    .font(.custom("Kurdis-Regular", size: 11))
                            }
                        }
                        .padding(.top)

                        HStack {
                            Image(systemName: "waveform.path.ecg")
                                .foregroundStyle(colorThemeManager.currentThemeColor)
                                .padding(.trailing)
                            VStack(alignment: .leading) {
                                Text("Focus Level:")
                                    .font(.custom("Kurdis-ExtraWideBold", size: 11))
                                    .fontWeight(.bold)

                                Text("Heart Rate Variability (HRV) measures the variation in time between heartbeats, reflecting your body's stress levels and recovery state, with lower HRV indicating higher stress and higher HRV suggesting better relaxation and recovery.")
                                    .font(.custom("Kurdis-Regular", size: 11))
                            }
                        }
                        .padding(.top)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            .padding(.top)
        }
    }
}

#Preview {
    DeepInsightsView()
}

import SwiftUI

struct DeepInsightsView: View {
    @Environment(\.colorScheme) var colorScheme // To detect the current color scheme
    @EnvironmentObject var colorThemeManager: ColorThemeManager // Access the theme color
    var body: some View {
        ZStack {
            // Background that ignores safe areas
            Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color(hex: "#f1f0f5"))
                .ignoresSafeArea(edges: .all) // Extend the background color to the edges
            
            // Content that respects safe areas
            ScrollView {
                VStack (alignment: .leading) {
                    Text("Take a deep look!")
                        .font(.custom("Kurdis-ExtraWideBold", size: 24))
                        .padding(.bottom)
                    
                    
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
                            .frame(height: 185) // Adjust the height based on content
                        
                        CaloriesChart()
                            .frame(height: 185) // Match the frame to the RoundedRectangle
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Text("Avg. Session Duration")
                        .font(.custom("Kurdis-ExtraWideBold", size: 20))
                        .fontWeight(.bold)
                        .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))
                        .padding(.top)
                        .padding(.top)
                    
                    Text("Average session duration of your last workouts")
                        .font(.custom("Kurdis-Regular", size: 11))
                        .fontWeight(.bold)
                        .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#d4d4d4") : Color(hex: "#6b6b6b")))
                        .padding(.bottom)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#333333") : .white))
                            .frame(height: 200) // Adjust the height based on content
                        
                        
                        DurationChart()
                            .frame(height: 200) // Match the frame to the RoundedRectangle
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Text("Avg. Heart Rate")
                        .font(.custom("Kurdis-ExtraWideBold", size: 20))
                        .fontWeight(.bold)
                        .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))
                        .padding(.top)
                        .padding(.top)
                    
                    Text("Average heart rate of your last workouts")
                        .font(.custom("Kurdis-Regular", size: 11))
                        .fontWeight(.bold)
                        .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#d4d4d4") : Color(hex: "#6b6b6b")))
                        .padding(.bottom)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#333333") : .white))
                            .frame(height: 200) // Adjust the height based on content
                        
                        
                        HeartRateChart()
                            .frame(height: 200) // Match the frame to the RoundedRectangle
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Text("Overall Avg. Heart Rate")
                        .font(.custom("Kurdis-ExtraWideBold", size: 20))
                        .fontWeight(.bold)
                        .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))
                        .padding(.top)
                        .padding(.top)
                    
                    Text("Average climbing hear rate recently")
                        .font(.custom("Kurdis-Regular", size: 11))
                        .fontWeight(.bold)
                        .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#d4d4d4") : Color(hex: "#6b6b6b")))
                        .padding(.bottom)
                    HStack{
                        HeartRateActivityCard()
                        Spacer()
                        HighestHeartRateActivityCard()
                    }
                    
                    Text("AI Driven Insights")
                        .font(.custom("Kurdis-ExtraWideBold", size: 20))
                        .fontWeight(.bold)
                        .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))
                        .padding(.top)
                        .padding(.top)
                    
                    Text("AI driven insights based off your climbing datay")
                        .font(.custom("Kurdis-Regular", size: 11))
                        .fontWeight(.bold)
                        .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#d4d4d4") : Color(hex: "#6b6b6b")))
                        .padding(.bottom)
                    HStack{
                        RecoveryTimeActivityCard()
                        Spacer()
                        HRVActivityCard()
                    }
                    HStack{
                        Image(systemName: "bed.double.fill")
                            .foregroundStyle(colorThemeManager.currentThemeColor) // Use theme color
                            .padding(.horizontal)
                        VStack (alignment:.leading){
                            Text ("Recovery Time:")
                                .font(.custom("Kurdis-ExtraWideBold", size: 11))
                                .fontWeight(.bold)
                            
                            Text ("Hydrate, and engage in light activity like stretching or walking to promote muscle recovery.")
                                .font(.custom("Kurdis-Regular", size: 11))
                        }
                    }
                    .padding(.top)
                    
                    HStack{
                        Image(systemName: "waveform.path.ecg")
                            .foregroundStyle(colorThemeManager.currentThemeColor) // Use theme color
                            .padding(.horizontal)
                        VStack (alignment:.leading){
                            Text ("Focus Level:")
                                .font(.custom("Kurdis-ExtraWideBold", size: 11))
                                .fontWeight(.bold)
                            
                            Text ("Heart Rate Variability (HRV) measures the variation in time between heartbeats, reflecting your body's stress levels and recovery state, with lower HRV indicating higher stress and higher HRV suggesting better relaxation and recovery.")
                                .font(.custom("Kurdis-Regular", size: 11))
                        }
                    }
                    .padding(.top)
                    
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            .padding(.top) // Add top padding to ensure content doesn't get too close to the top edge
        }
    }
}

#Preview {
    DeepInsightsView()
}

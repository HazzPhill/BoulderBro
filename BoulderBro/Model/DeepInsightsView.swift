import SwiftUI

struct DeepInsightsView: View {
    @Environment(\.colorScheme) var colorScheme // To detect the current color scheme
    
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
                        .padding(.top)
                        .padding(.top)
                    
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
                    
                }
                .padding(.horizontal)
            }
            .padding(.top) // Add top padding to ensure content doesn't get too close to the top edge
        }
    }
}

#Preview {
    DeepInsightsView()
}

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
                VStack {
                    Text("Take a deep look!")
                        .font(.custom("Kurdis-ExtraWideBold", size: 24))
                        .padding(.bottom)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color(colorScheme == .dark ? .black : .white))
                            .frame(height: 165) // Adjust the height based on content
                        
                        CaloriesChart()
                            .frame(height: 165) // Match the frame to the RoundedRectangle
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color(colorScheme == .dark ? .black : .white))
                            .frame(height: 200) // Adjust the height based on content
                        
                        
                        DurationChart()
                            .frame(height: 200) // Match the frame to the RoundedRectangle
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal)
                    
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

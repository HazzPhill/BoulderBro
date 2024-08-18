//
//  ActivityCard.swift
//  BoulderBro
//
//  Created by Hazz on 17/08/2024.
//

import SwiftUI


struct ActivityCard: View {
    @State var activity: Activity
    
    var body: some View {
        ZStack{
            Color(uiColor: .systemGray6)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            VStack{
                HStack (alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text (activity.title)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        Text (activity.subtitle)
                    }
                    
                    Spacer()
                    
                    Image(systemName: activity.image)
                        .foregroundStyle(Color(hex: "#FF5733"))
                }
                
                Text (activity.amount)
                    .font(.custom("Kurdis-ExtraWideBold", size: 20))
                    .foregroundStyle(Color(hex: "#FF5733"))
                    .padding()
            }
            .padding()
        }
    }
}

#Preview {
    ActivityCard(activity: Activity(title: "Today's Steps", subtitle: "Goal 12,000", image: "figure.walk", tintColor:Color(hex: "#FF5733"), amount: "9,431"))
}

//
//  FitnessHome.swift
//  BoulderBro
//
//  Created by Hazz on 17/08/2024.
//

import SwiftUI

struct FitnessHome: View {
    @State var calories: Int = 123
    @State var active: Int = 52
    @State var stand: Int = 8
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            VStack{
                Text ("Welcome")
                    .font(.custom("Kurdis-ExtraWideBold", size: 24))
                    .padding()
                
                HStack{
                    
                    Spacer()
                    
                    VStack (alignment: .leading,spacing: 8) {
                        VStack(alignment: .leading,spacing: 8) {
                            Text ("Calrories")
                                .font(.custom("Kurdis-ExtraWideBold", size: 15))
                                .foregroundStyle(Color.red)
                            Text ("123 kcal")
                        }
                        .padding(.bottom)
                        
                        VStack(alignment: .leading,spacing: 8) {
                            Text ("Active")
                                .font(.custom("Kurdis-ExtraWideBold", size: 15))
                                .foregroundStyle(Color.green)
                            Text ("52 miniutes")
                        }
                        .padding(.bottom)
                        
                        VStack(alignment: .leading,spacing: 8) {
                            Text ("Stand")
                                .font(.custom("Kurdis-ExtraWideBold", size: 15))
                                .foregroundStyle(Color.blue)
                            Text ("8 hours")
                        }
                        
                    }
                    
                    Spacer()
                    
                    ZStack{
                        ProgressCircleView(progress: $calories, goal: 600, color: .red)
                        
                        ProgressCircleView(progress: $active, goal: 60, color: .green)
                            .padding(.all,20)
                        
                        ProgressCircleView(progress: $stand, goal: 12, color: .blue)
                            .padding(.all,40)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                HStack{
                    Text ("Fitness Activity")
                        .font(.custom("Kurdis-ExtraWideBold", size: 16))
                    Spacer()
                    
                    Button {
                        print("Show More")
                    } label: {
                        Text("Show More")
                            .padding(.all,10)
                            .foregroundStyle(Color.white)
                            .background(Color(hex: "#FF5733"))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal)
            
            }

        }
    }
}

#Preview {
    FitnessHome()
}

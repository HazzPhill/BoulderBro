//
//  CurrentLevel.swift
//  BoulderBro
//
//  Created by Hazz on 20/08/2024.
//

import SwiftUI

struct CurrentLevel: View {
    var body: some View {
        Rectangle()
            .frame(height: 85)
            .clipShape(RoundedRectangle(cornerRadius:15))
            .foregroundStyle(Color(hex: "#FF5733"))
            .overlay(
                HStack (alignment: .center, spacing: 0) {
                    Text("Current Level")
                        .lineLimit(2)
                        .font(.custom("Kurdis-ExtraWideBold", size: 24))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity) // Allow text to expand

                    Spacer() // Pushes elements to the sides
                    ZStack{
                        Rectangle()
                            .frame(width: 155, height: 65)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity) // Allow rectangle to expand
                        
                        Text("V5")
                            .lineLimit(2)
                            .font(.custom("Kurdis-ExtraWideBold", size: 24))
                            .foregroundStyle(Color(hex: "#FF5733"))
                            .frame(maxWidth: .infinity)
                    }
})
            .padding(.top)
            .padding(.bottom)
    }
}

#Preview {
    CurrentLevel()
}

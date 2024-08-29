//
//  TheClimb.swift
//  BoulderBro
//
//  Created by Hazz on 20/08/2024.
//

import SwiftUI
import AVKit

struct TheClimb: View {
    var climb: Climb
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Media section
                if climb.mediaURL.contains(".mp4") {
                    VideoPlayer(player: AVPlayer(url: URL(string: climb.mediaURL)!))
                        .frame(height: 300)
                        .cornerRadius(20)
                        .padding(.horizontal)
                } else {
                    AsyncImage(url: URL(string: climb.mediaURL)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(20)
                            .padding(.horizontal)
                    } placeholder: {
                        ProgressView()
                            .frame(height: 300)
                            .cornerRadius(20)
                            .padding(.horizontal)
                    }
                }
                
                // Climb details section
                Text(climb.name)
                    .font(.custom("Kurdis-ExtraWideBold", size: 30))
                    .padding(.horizontal)
                
                Text("Location: \(climb.climbtype)")
                    .font(.custom("Kurdis-Regular", size: 18))
                    .padding(.horizontal)
                
                Text("Difficulty: \(climb.difficulty)")
                    .font(.custom("Kurdis-Regular", size: 18))
                    .padding(.horizontal)
                
                Text("V Rating: \(climb.vRating)")
                    .font(.custom("Kurdis-Regular", size: 18))
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
        }
        .navigationTitle(climb.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    TheClimb(climb: Climb(id: "1", name: "Sample Climb", climbtype: "Sample Location", difficulty: "Medium", vRating: "V5", mediaURL: "https://example.com/sample.jpg"))
}

import SwiftUI
import _AVKit_SwiftUI
import AVFoundation

struct PersonalClimb: View {
    var climb: Climb

    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: climb.mediaURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.bottom)
            } placeholder: {
                Image("ClimbPlaceholder")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.bottom)
            }

            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text(climb.name)
                        .font(.custom("Kurdis-ExtraWideBold", size: 20))
                        .foregroundColor(.primary) // Set text color
                    Text(climb.location)
                        .font(.custom("Kurdis-Regular", size: 11))
                        .foregroundColor(.primary) // Set text color
                }
                Spacer()
                Text(climb.vRating)
                    .font(.custom("Kurdis-ExtraWideBold", size: 20))
                    .foregroundColor(Color(hex: "#FF5733"))
            }
        }
        .padding(.top)
        .padding(.bottom)
    }
}

#Preview {
    PersonalClimb(climb: Climb(id: "1", name: "Sample Climb", location: "Sample Location", difficulty: "Medium", vRating: "V5", mediaURL: "https://example.com/sample.jpg"))
}

import SwiftUI
import _AVKit_SwiftUI
import AVFoundation

struct PersonalClimb: View {
    @State var climb: Climb
    @Environment(\.colorScheme) var colorScheme // Detect the current color scheme
    @EnvironmentObject var colorThemeManager: ColorThemeManager // Access the theme color
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: climb.mediaURL)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .padding()
                    .background(Color(colorScheme == .dark ? Color(hex: "#212121") : Color(hex: "#ECECEC")))
                    .clipShape(Circle())
                    .padding(.trailing, 8) // Adjust padding to your preference
            } placeholder: {
                Image("ClimbPlaceholder")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .padding()
                    .background(Color(colorScheme == .dark ? Color(hex: "#212121") : Color(hex: "#ECECEC")))
                    .clipShape(Circle())
                    .padding(.trailing, 8) // Adjust padding to your preference
            }
            
            HStack(alignment: .center, spacing: 4) { // Adjust spacing between texts
                
                VStack (alignment: .leading, spacing: 4) {
                    
                        Text(climb.name)
                            .font(.custom("Kurdis-ExtraWideBold", size: 16))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        
                    Text(climb.difficulty)
                        .font(.subheadline)
                    
                    Text(climb.climbtype)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .font(.subheadline)
                        .foregroundColor(.secondary) // Optional: Make the climbtype text less prominent
                }
                    Spacer()
                
                    Text(climb.vRating)
                        .font(.custom("Kurdis-ExtraWideBold", size: 16))
                        .foregroundStyle(colorThemeManager.currentThemeColor) // Use theme color
                }
                
            
            Button(action: {
                climb.isFavorite.toggle()
            }) {
                Image(systemName: climb.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(climb.isFavorite ? .red : .gray)
                    .padding(.leading)
            }
        }
        .padding()
        .background(Color(colorScheme == .dark ? Color(hex: "#333333") : .white))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    let colorThemeManager = ColorThemeManager() // Create an instance of ColorThemeManager
    PersonalClimb(climb: Climb(id: "1", name: "Sample Climb", climbtype: "Sample Location", difficulty: "Medium", vRating: "V5", mediaURL: "https://example.com/sample.jpg", isFavorite: false))
        .environmentObject(colorThemeManager) // Inject the colorThemeManager into the environment
}

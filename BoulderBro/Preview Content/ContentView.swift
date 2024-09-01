import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var selectedTab: Int = 0
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var colorThemeManager: ColorThemeManager
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                ZStack {
                    // Manually switch between views based on selectedTab
                    switch selectedTab {
                    case 0:
                        Home()
                    case 1:
                        FitnessHome()
                    case 2:
                        MyClimbsView()
                    case 3:
                        videosView()
                    case 4:
                        CometChatConversationsWithMessagesView()
                    case 5:
                        ProfileView()
                    default:
                        Home()
                    }
                    
                    // Custom Floating Tab Bar
                    VStack {
                        Spacer()

                        HStack {
                            TabBarButton(icon: "house", isSelected: selectedTab == 0) {
                                selectedTab = 0
                            }
                            CustomSpacer()
                            TabBarButton(icon: "chart.xyaxis.line", isSelected: selectedTab == 1) {
                                selectedTab = 1
                            }
                            CustomSpacer()
                            TabBarButton(icon: "book", isSelected: selectedTab == 2) {
                                selectedTab = 2
                            }
                            CustomSpacer()
                            TabBarButton(icon: "film.stack", isSelected: selectedTab == 3) {
                                selectedTab = 3
                            }
                            CustomSpacer()
                            TabBarButton(icon: "message", isSelected: selectedTab == 4) {
                                selectedTab = 4
                            }
                            CustomSpacer()
                            TabBarButton(icon: "person", isSelected: selectedTab == 5) {
                                selectedTab = 5
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8) // Slightly reduced vertical padding
                        .background(Capsule().fill(Color(colorScheme == .dark ? Color(hex: "#333333") : Color.white)))
                        .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 5)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 15)
                        .padding(.bottom, 40) // Increased bottom padding to move the bar higher up
                    }
                }
                .edgesIgnoringSafeArea(.all)
            } else {
                LogInView()
            }
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var colorThemeManager: ColorThemeManager
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20)) // Reduced icon size
                .foregroundColor(isSelected ? colorThemeManager.currentThemeColor : Color.gray)
                .padding(6) // Reduced padding
        }
    }
}

// Custom spacer to control the spacing between the icons
struct CustomSpacer: View {
    var body: some View {
        Spacer(minLength: 10) // Adjust the minLength to control spacing
    }
}

#Preview {
    ContentView()
}

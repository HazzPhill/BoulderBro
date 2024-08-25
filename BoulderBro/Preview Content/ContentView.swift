import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var selectedTab: Int = 0
    @Environment(\.colorScheme) var colorScheme // To detect the current color
    @EnvironmentObject var colorThemeManager: ColorThemeManager // Access the theme color
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
                            Spacer()
                            TabBarButton(icon: "chart.xyaxis.line", isSelected: selectedTab == 1) {
                                selectedTab = 1
                            }
                            Spacer()
                            TabBarButton(icon: "book", isSelected: selectedTab == 2) {
                                selectedTab = 2
                            }
                            Spacer()
                            TabBarButton(icon: "person", isSelected: selectedTab == 3) {
                                selectedTab = 3
                            }
                        }
                        .padding(.horizontal, 10) // Reduced horizontal padding
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color(colorScheme == .dark ? Color(hex: "#333333") : Color.white)))
                            .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 5)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 20) // Reduced overall padding to push the pill further to the edges
                        .padding(.bottom, 20)
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
    @EnvironmentObject var colorThemeManager: ColorThemeManager // Access the theme color
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? colorThemeManager.currentThemeColor : Color.gray)
                .padding()
        }
    }
}

#Preview {
    ContentView()
}

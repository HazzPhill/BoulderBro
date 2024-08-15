//
//  SignInView.swift
//  BoulderBro
//
//  Created by Hazz on 15/08/2024.
//

import SwiftUI

@MainActor
final class SignInEmailViewModel: ObservableObject {
    
@Published var email = ""
@Published var password = ""

    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            print ("No email or password found")
            return
    }
    
        Task{
            do {
                let returnedUserData = try await AuthenticationManager.shared.createUser(email: email, password: password)
                print ("Success")
                print (returnedUserData)
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
}
struct SignInView: View {
    
    // Circle variables
    @State private var topCircleOffset = CGSize(width: 150, height: -300)
    @State private var bottomCircleOffset = CGSize(width: -150, height: 250)

    // Use a timer for animation
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect() // Adjust the interval as needed

    let easingFactor: CGFloat = 0.5 // Adjust this to control the smoothness
    
    @StateObject private var viewModel = SignInEmailViewModel()
    
    var body: some View {
        NavigationStack{
            ZStack {
                // Background color
                Color.white
                    .ignoresSafeArea()
                    .zIndex(-2) // Ensure it's behind the circles
                
                // Top circle
                Circle()
                    .fill(Color(hex: "#FF5733")).opacity(0.3)
                    .frame(width: 350, height: 350)
                    .blur(radius: 60)
                    .offset(topCircleOffset)
                    .zIndex(-1)
                
                // Bottom circle
                Circle()
                    .fill(Color(hex: "#FF5733")).opacity(0.3)
                    .frame(width: 350, height: 500)
                    .blur(radius: 60)
                    .offset(bottomCircleOffset)
                    .zIndex(-1)
                
                // Animate circle offsets
                    .onReceive(timer) { _ in
                        withAnimation(.linear(duration: 0.9)) {
                            // Calculate new target offsets with slight random variations, but keep them within bounds
                            let newTopOffset = CGSize(
                                width: max(50, min(UIScreen.main.bounds.width - 300, topCircleOffset.width + CGFloat.random(in: -50...50))),
                                height: max(-250, min(-50, topCircleOffset.height + CGFloat.random(in: -25...25)))
                            )
                            let newBottomOffset = CGSize(
                                width: max(-200, min(UIScreen.main.bounds.width - 300, bottomCircleOffset.width + CGFloat.random(in: -50...50))),
                                height: max(50, min(UIScreen.main.bounds.height - 450, bottomCircleOffset.height + CGFloat.random(in: -25...25)))
                            )
                            
                            topCircleOffset = newTopOffset
                            bottomCircleOffset = newBottomOffset
                        }
                    }
                
                VStack() {
                    Spacer()
                    
                    TextField("Email...", text: $viewModel.email)
                        .padding()
                        .background(Color.white)
                        .clipShape(Capsule())
                    
                    SecureField("Password...", text: $viewModel.password)
                        .padding()
                        .background(Color.white)
                        .clipShape(Capsule())
                    
                    Button {
                        viewModel.signIn()
                    } label: {
                        
                        Text ("Sign in with email")
                            .font(.headline)
                            .foregroundStyle(Color.white)
                            .frame(height: 55)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                            .background(Color(hex: "#FF5733"))
                            .clipShape(Capsule())
                    }
                    Spacer()
                }
                .padding()
                .navigationTitle("Sign in with email")
            }
        }
    }
}

#Preview {
    SignInView()
}

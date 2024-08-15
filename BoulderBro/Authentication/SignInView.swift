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
    
    @StateObject private var viewModel = SignInEmailViewModel()
    
    var body: some View {
        NavigationStack{
            Spacer()
            VStack{
                TextField("Email...", text: $viewModel.email)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                
                SecureField("Password...", text: $viewModel.password)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                
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
            
            .navigationTitle("Sign in with email")
        }
    }
}

#Preview {
    SignInView()
}

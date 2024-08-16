//
//  RegisterView.swift
//  BoulderBro
//
//  Created by Hazz on 15/08/2024.
//

import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var fullname = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack{
            NavigationStack{
                VStack{
                    Spacer()
                    VStack(spacing:24){
                        InputView(text: $fullname, title: "Full Name", placehodler: "Harry Phillips")
                            .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                        
                        InputView(text: $email, title: "Email Address", placehodler: "name@example.com")
                            .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                        
                        InputView(text: $password, title: "Password", placehodler: "Enter your password", isSecureField: true)
                        
                        ZStack(alignment:.trailing) {
                            InputView(text: $confirmPassword, title: "Confirm Password", placehodler: "Enter your password again", isSecureField: true)
                            
                            if !password.isEmpty &&  !confirmPassword.isEmpty {
                                
                                if password == confirmPassword {
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color(.systemGreen))
                            } else {
                                Image(systemName: "xmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color(.systemRed))
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Button {
                        Task {
                            try await viewModel.createUser(WithEmail:email,password:password,fullname:fullname)
                        }
                    } label: {
                        HStack{
                            Text ("Sign Up")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundStyle(Color.white)
                        .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                    }
                    .background(Color(hex: "#FF5733"))
                    .clipShape(Capsule())
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1.0 : 0.5)
                    
                    .padding(.top,24)
                    
                    Spacer()
                    
                    Button{
                        dismiss()
                    } label: {
                        HStack(spacing:3){
                            Text("Alreay have an account?")
                            Text("Sign in")
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        }
                        .font(.system(size: 14))
                    }
                    
                }
            }
        }
    }
}

// MARK: - AuthenticationFormProtocol

extension RegisterView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && confirmPassword == password
        && !password.isEmpty
        && !fullname.isEmpty
        && password.count > 9
    }
}

#Preview {
    RegisterView()
}

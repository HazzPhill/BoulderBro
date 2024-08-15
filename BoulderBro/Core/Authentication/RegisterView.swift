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
                        
                        InputView(text: $confirmPassword, title: "Confirm Password", placehodler: "Enter your password again", isSecureField: true)
                    }
                    .padding(.horizontal)
                    
                    Button {
                        print(("Log User In.."))
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

#Preview {
    RegisterView()
}

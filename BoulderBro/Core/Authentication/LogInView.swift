//
//  LogInView.swift
//  BoulderBro
//
//  Created by Hazz on 15/08/2024.
//

import SwiftUI

struct LogInView: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack{
            VStack{
                Spacer()
                VStack(spacing:24){
                    InputView(text: $email, title: "Email Address", placehodler: "name@example.com")
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    
                    InputView(text: $password, title: "Password", placehodler: "Enter your password", isSecureField: true)
                }
                .padding(.horizontal)
                
                Button {
                    print(("Log User In.."))
                } label: {
                    HStack{
                        Text ("Sign in")
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
                
                NavigationLink {
                    RegisterView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing:3){
                        Text("New climber?")
                        Text("Create an account")
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    }
                    .font(.system(size: 14))
                }

            }
        }
    }
}

#Preview {
    LogInView()
}

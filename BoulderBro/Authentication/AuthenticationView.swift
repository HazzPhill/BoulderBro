//
//  AuthenucationView.swift
//  BoulderBro
//
//  Created by Hazz on 15/08/2024.
//

import SwiftUI

struct AuthenticationView: View {
    var body: some View {
        NavigationStack{
            VStack{
                
                NavigationLink{
                    SignInView()
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
            .navigationTitle("Sign In")
        }
    }
}

#Preview {
    AuthenticationView()
}

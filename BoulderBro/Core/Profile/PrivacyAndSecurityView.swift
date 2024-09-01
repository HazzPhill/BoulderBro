//
//  PrivacyAndSecurityView.swift
//  BoulderBro
//
//  Created by Hazz on 01/09/2024.
//

import SwiftUI

struct PrivacyAndSecurityView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var email: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        Form {
            Section(header: Text("Reset Password")) {
                TextField("Enter your email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                Button(action: {
                    Task {
                        await resetPassword()
                    }
                }) {
                    Text("Send Password Reset Email")
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
            
            Section(header: Text("Change Password")) {
                SecureField("Current Password", text: $currentPassword)
                SecureField("New Password", text: $newPassword)
                
                Button(action: {
                    Task {
                        await changePassword()
                    }
                }) {
                    Text("Change Password")
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
        .navigationTitle("Privacy & Security")
    }
    
    private func resetPassword() async {
        if email.isEmpty {
            alertMessage = "Please enter your email."
            showAlert = true
            return
        }
        await viewModel.resetPassword(forEmail: email)
        alertMessage = "Password reset email sent."
        showAlert = true
    }
    
    private func changePassword() async {
        if currentPassword.isEmpty || newPassword.isEmpty {
            alertMessage = "Please fill in all fields."
            showAlert = true
            return
        }
        do {
            try await viewModel.changePassword(currentPassword: currentPassword, newPassword: newPassword)
            alertMessage = "Password changed successfully."
        } catch {
            alertMessage = "Failed to change password: \(error.localizedDescription)"
        }
        showAlert = true
    }
}

#Preview {
    NavigationView {
        PrivacyAndSecurityView()
    }
}

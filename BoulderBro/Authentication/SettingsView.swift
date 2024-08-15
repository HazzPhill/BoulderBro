//
//  SettingsView.swift
//  BoulderBro
//
//  Created by Hazz on 15/08/2024.
//

import SwiftUI

final class SettingsViewModel: ObservableObject {
    
    
    func signOut() throws {
       try AuthenticationManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        
       try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updatePassword() async throws {
        let email = "EMAIL123"
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func updateEmail() async throws{
        let password = "PASSY123"
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    
}

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        NavigationStack{
            List {
                Button ("Log Out"){
                    Task {
                        do {
                            try viewModel.signOut()
                            showSignInView = true
                        } catch {
                            print (error)
                        }
                    }
                }
                
                emailSection
            }
            .navigationTitle("Settings")
        }
        
    }
}
    
    #Preview {
        SettingsView(showSignInView: .constant(false))
    }
    
    extension SettingsView {
        private var emailSection: some View {
            Section {
                
                Button ("Reset Password"){
                    Task {
                        do {
                            try await viewModel.resetPassword()
                            showSignInView = true
                            print("Password has been reset")
                        } catch {
                            print (error)
                        }
                    }
                }
                
                Button ("Update Password"){
                    Task {
                        do {
                            try await viewModel.updatePassword()
                            showSignInView = true
                            print("Update Password")
                        } catch {
                            print (error)
                        }
                    }
                }
                
                Button ("Update Email"){
                    Task {
                        do {
                            try await viewModel.updateEmail()
                            showSignInView = true
                            print("PUpdate Email")
                        } catch {
                            print (error)
                        }
                    }
                }
            } header: {
                Text ("Email")
            }
        }
    }


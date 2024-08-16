//
//  AuthViewModel.swift
//  BoulderBro
//
//  Created by Hazz on 16/08/2024.
//

import Foundation
import Firebase
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init() {
        
    }
    
    func signIn(withEmail email:String, password:String) async throws {
        print ("Sign in..")
    }
    
    func createUser(WithEmail email: String, password: String, fullname: String) async throws {
        do {
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                self.userSession = result.user
                let user = User(id: result.user.uid, fullname: fullname, email: email)
        } catch {
        }
    }
    
    func signOut() {
        
    }
    
    func deleteAccount() {
        
    }
    
    func fetchUser() async {
        
    }
}

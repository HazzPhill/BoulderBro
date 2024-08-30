//
//  AuthViewModel.swift
//  BoulderBro
//
//  Created by Hazz on 16/08/2024.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task{
            await fetchUser()
        }
    }
    
    func signIn(withEmail email:String, password:String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("DBUG failed to sign in user \(error.localizedDescription)")
        }
    }
    
    func createUser(WithEmail email: String, password: String, fullname: String, username: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user

            // Check if the username is already taken
            let usernameQuery = Firestore.firestore().collection("users").whereField("username", isEqualTo: username)
            let usernameSnapshot = try await usernameQuery.getDocuments()
            if !usernameSnapshot.isEmpty {
                throw NSError(domain: "AppErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Username already taken"])
            }

            let user = User(id: result.user.uid, fullname: fullname, email: email, username: username)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
        } catch {
            print("DBUG failed to create user \(error.localizedDescription)")
            // You might want to re-throw the error here or handle it in a more user-friendly way
        }
    }
    
    func signout() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("DEBUG: Failed to sign out with error: \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { return } // Make sure there's a user signed in

        do {
            // 1. Delete user data from Firestore
            try await Firestore.firestore().collection("users").document(user.uid).delete()

            // 2. Delete the user's authentication account
            try await user.delete()

            // 3. Update local state
            self.userSession = nil
            self.currentUser = nil

        } catch {
            print("DEBUG: Failed to delete account with error: \(error.localizedDescription)")
            // Consider re-throwing the error or handling it in a more user-friendly way
        }
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
    }
}

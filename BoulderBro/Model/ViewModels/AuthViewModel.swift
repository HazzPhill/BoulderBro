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
import FirebaseStorage

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var profileImageUrl: URL? // Add this property
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("DEBUG: Failed to sign in user \(error.localizedDescription)")
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
            print("DEBUG: Failed to create user \(error.localizedDescription)")
        }
    }
    
    func updateUser(fullname: String, email: String, username: String) async {
        guard let uid = userSession?.uid else { return }
        
        do {
            // Update user data in Firestore
            let userRef = Firestore.firestore().collection("users").document(uid)
            try await userRef.updateData([
                "fullname": fullname,
                "email": email,
                "username": username
            ])
            
            // Update the authentication email if it's changed
            if email != currentUser?.email {
                try await userSession?.updateEmail(to: email)
            }
            
            // Fetch the updated user data to refresh UI
            await fetchUser()
        } catch {
            print("DEBUG: Failed to update user with error: \(error.localizedDescription)")
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
        guard let user = Auth.auth().currentUser else { return }

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
        }
    }
    
    func uploadProfileImage(_ image: UIImage) async throws {
            guard let uid = userSession?.uid else { return }
            
            let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
            guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            do {
                _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
                let profileImageUrl = try await storageRef.downloadURL()
                
                // Update Firestore with the new profile image URL
                let userRef = Firestore.firestore().collection("users").document(uid)
                try await userRef.updateData(["profileImageUrl": profileImageUrl.absoluteString])
                
                // Update the profileImageUrl property in the view model
                self.profileImageUrl = profileImageUrl
            } catch {
                print("DEBUG: Failed to upload profile image with error: \(error.localizedDescription)")
            }
        }
    
    func resetPassword(forEmail email: String) async {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            print("DEBUG: Password reset email sent successfully")
        } catch {
            print("DEBUG: Failed to send password reset email with error: \(error.localizedDescription)")
        }
    }

    
    func changePassword(currentPassword: String, newPassword: String) async throws {
        guard let user = Auth.auth().currentUser, let email = user.email else { return }

        // Re-authenticate the user to ensure they have the correct credentials
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        do {
            try await user.reauthenticate(with: credential)
            try await user.updatePassword(to: newPassword)
            print("DEBUG: Password updated successfully")
        } catch {
            print("DEBUG: Failed to update password with error: \(error.localizedDescription)")
            throw error
        }
    }

    
    func fetchUser() async {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            do {
                let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
                self.currentUser = try snapshot.data(as: User.self)
                
                // Fetch profile image URL if available
                if let profileImageUrlString = snapshot.data()?["profileImageUrl"] as? String,
                   let url = URL(string: profileImageUrlString) {
                    self.profileImageUrl = url
                }
            } catch {
                print("DEBUG: Failed to fetch user with error: \(error.localizedDescription)")
            }
        }
    }

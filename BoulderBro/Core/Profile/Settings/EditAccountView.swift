//
//  EditAccountView.swift
//  BoulderBro
//
//  Created by Hazz on 30/08/2024.
//

import SwiftUI

struct EditAccountView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var fullname: String
    @State private var email: String
    @State private var username: String
    @State private var selectedImage: UIImage?
    @State private var selectedVideoURL: URL? // Just to satisfy the ImagePicker
    @State private var showImagePicker = false // Add this line

    init(user: User) {
        _fullname = State(initialValue: user.fullname)
        _email = State(initialValue: user.email)
        _username = State(initialValue: user.username)
    }

    var body: some View {
        NavigationView {
            Form {
                // Profile Picture Section
                Section(header: Text("Profile Picture")) {
                    VStack {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else if let profileImageUrl = viewModel.profileImageUrl {
                            AsyncImage(url: profileImageUrl) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }

                        Button(action: {
                            showImagePicker = true // Set showImagePicker to true when the button is tapped
                        }) {
                            Text("Change Picture")
                        }
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker(selectedImage: $selectedImage, selectedVideoURL: $selectedVideoURL)
                        }
                        .onChange(of: selectedImage) { newImage in
                            if let newImage = newImage {
                                Task {
                                    try await viewModel.uploadProfileImage(newImage)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }

                // Name Section
                Section(header: Text("Name")) {
                    TextField("Full Name", text: $fullname)
                }

                // Email Section
                Section(header: Text("Email")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                }

                // Username Section
                Section(header: Text("Username")) {
                    TextField("Username", text: $username)
                }
            }
            .navigationTitle("Edit Account")
            .navigationBarItems(trailing: Button("Save") {
                Task {
                    await viewModel.updateUser(fullname: fullname, email: email, username: username)
                    presentationMode.wrappedValue.dismiss()
                }
            })
        }
    }
}


#Preview {
    let mockUser = User(id: "12345", fullname: "John Doe", email: "johndoe@example.com", username: "johndoe")
    EditAccountView(user: mockUser)
        .environmentObject(AuthViewModel()) // Provide a mock environment object if needed
}

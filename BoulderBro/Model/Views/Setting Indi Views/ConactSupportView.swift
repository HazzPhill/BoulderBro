//
//  ConactSupportView.swift
//  BoulderBro
//
//  Created by Hazz on 30/08/2024.
//

import SwiftUI
import MessageUI

struct ContactSupportView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var message: String = ""
    @State private var showAlert = false
    @State private var showMailView = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil

    var body: some View {
        Form {
            Section(header: Text("Your Details")) {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
            }

            Section(header: Text("Message")) {
                TextEditor(text: $message)
                    .frame(height: 150)
            }

            Button("Submit") {
                // Validate the form
                if validateForm() {
                    showMailView.toggle()
                } else {
                    showAlert = true
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text("Please fill out all fields."), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showMailView) {
                MailView(
                    result: $mailResult,
                    subject: "Support Request from \(name)",
                    recipients: ["hazphillips@outlook.com"], // Your email address
                    messageBody: "Name: \(name)\nEmail: \(email)\n\nMessage:\n\(message)"
                )
            }
        }
        .navigationTitle("Contact Support")
    }

    private func validateForm() -> Bool {
        return !name.isEmpty && !email.isEmpty && !message.isEmpty
    }
}


#Preview {
    ContactSupportView()
}

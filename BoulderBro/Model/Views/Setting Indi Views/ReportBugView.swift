//
//  ReportBugView.swift
//  BoulderBro
//
//  Created by Hazz on 30/08/2024.
//

import SwiftUI
import MessageUI

struct ReportBugView: View {
    @State private var description: String = ""
    @State private var stepsToReproduce: String = ""
    @State private var showAlert = false
    @State private var showMailView = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil

    var body: some View {
        Form {
            Section(header: Text("Bug Description")) {
                TextEditor(text: $description)
                    .frame(height: 150)
            }

            Section(header: Text("Steps to Reproduce")) {
                TextEditor(text: $stepsToReproduce)
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
                    subject: "Bug Report",
                    recipients: ["hazphillips@outlook.com"], // Your email address
                    messageBody: "Bug Description:\n\(description)\n\nSteps to Reproduce:\n\(stepsToReproduce)"
                )
            }
        }
        .navigationTitle("Report Bug")
    }

    private func validateForm() -> Bool {
        return !description.isEmpty && !stepsToReproduce.isEmpty
    }
}


#Preview {
    ReportBugView()
}

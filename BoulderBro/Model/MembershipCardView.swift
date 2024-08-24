import SwiftUI
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins
import Firebase
import FirebaseAuth
import FirebaseStorage

struct MembershipCardView: View {
    @State private var membershipImage: UIImage? = nil
    @State private var croppedImage: UIImage? = nil
    @State private var cardInfo: String = ""
    @State private var showImagePicker = false
    @State private var showRemoveAlert = false
    @State private var showSaveAlert = false // For success/error alerts
    @State private var alertMessage = ""

    // Navigation
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            if let image = croppedImage ?? membershipImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .padding()
            } else {
                Text("No Membership Card Uploaded")
                    .foregroundColor(.gray)
                    .padding()
            }

            Text(cardInfo)
                .padding()

            HStack {
                Button("Update Card") {
                    showImagePicker.toggle()
                }
                .buttonStyle(.borderedProminent)
                .padding()

                if membershipImage != nil || croppedImage != nil {
                    Button("Remove Card") {
                        showRemoveAlert.toggle()
                    }
                    .buttonStyle(.bordered)
                    .padding()
                    .alert(isPresented: $showRemoveAlert) {
                        Alert(
                            title: Text("Remove Membership Card"),
                            message: Text("Are you sure you want to remove your membership card?"),
                            primaryButton: .destructive(Text("Remove")) {
                                membershipImage = nil
                                croppedImage = nil
                                cardInfo = ""
                                removeMembershipCardFromFirestore()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }

                if (membershipImage != nil || croppedImage != nil) && !cardInfo.isEmpty {
                    Button("Save") {
                        saveToFirebase()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    .alert(isPresented: $showSaveAlert) {
                        Alert(title: Text(alertMessage))
                    }
                }
            }
        }
        .sheet(isPresented: $showImagePicker, onDismiss: processImage) {
            ImagePicker(selectedImage: $membershipImage, selectedVideoURL: .constant(nil))
        }
        .navigationTitle("Membership Card")
        .onAppear(perform: loadMembershipCardData)
    }

    func loadMembershipCardData() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Error: User is not logged in")
            return
        }

        let db = Firestore.firestore()
        let docRef = db.collection("users").document(currentUserID)

        docRef.getDocument { document, error in
            if let error = error {
                print("Error fetching membership card data: \(error.localizedDescription)")
                return
            }

            guard let document = document, document.exists, let data = document.data() else {
                print("No membership card data found.")
                return
            }

            if let cardInfo = data["membershipCardInfo"] as? String {
                self.cardInfo = cardInfo
            }

            if let imageUrl = data["membershipCardImageURL"] as? String {
                loadMembershipImage(from: imageUrl)
            }
        }
    }

    func loadMembershipImage(from url: String) {
        guard let imageUrl = URL(string: url) else {
            print("Invalid URL for membership card image.")
            return
        }

        URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            if let error = error {
                print("Error downloading membership card image: \(error.localizedDescription)")
                return
            }

            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.membershipImage = image
                }
            }
        }.resume()
    }

    func processImage() {
        guard let image = membershipImage else {
            print("Error: No membership image available.")
            return
        }
        
        // Attempt to crop the image to the membership card
        croppedImage = cropToMembershipCard(image)
        
        // Fallback: Use the original image if cropping fails
        if croppedImage == nil {
            print("Warning: Cropping failed, using original image.")
            croppedImage = image
        }
        
        extractText(from: croppedImage ?? image)
    }

    func cropToMembershipCard(_ image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else {
            print("Error: Unable to create CIImage from UIImage.")
            return nil
        }

        let request = VNDetectRectanglesRequest { request, error in
            if let error = error {
                print("Error detecting rectangles: \(error.localizedDescription)")
                return
            }

            guard let results = request.results as? [VNRectangleObservation], let rect = results.first else {
                print("Error: No rectangles detected.")
                return
            }

            let imageSize = CGSize(width: ciImage.extent.width, height: ciImage.extent.height)
            let transform = CGAffineTransform(scaleX: imageSize.width, y: imageSize.height)
            let convertedRect = rect.boundingBox.applying(transform)

            let cropped = ciImage.cropped(to: convertedRect)
            let context = CIContext()
            if let cgImage = context.createCGImage(cropped, from: cropped.extent) {
                croppedImage = UIImage(cgImage: cgImage)
            } else {
                print("Error: Unable to create CGImage from cropped CIImage.")
            }
        }

        request.minimumAspectRatio = 0.6
        request.maximumAspectRatio = 1.0

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Error performing rectangle detection: \(error.localizedDescription)")
        }

        return croppedImage
    }

    func extractText(from image: UIImage) {
        guard let cgImage = image.cgImage else {
            print("Error: Unable to create CGImage from UIImage.")
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("Error recognizing text: \(error.localizedDescription)")
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("Error: No text observations found.")
                return
            }

            var recognizedText = ""
            for observation in observations {
                guard let candidate = observation.topCandidates(1).first else { continue }
                recognizedText += "\(candidate.string)\n"
            }

            DispatchQueue.main.async {
                cardInfo = recognizedText.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        request.recognitionLevel = .accurate

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Error performing text recognition: \(error.localizedDescription)")
        }
    }

    func saveToFirebase() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            alertMessage = "Error: User is not logged in"
            showSaveAlert = true
            return
        }

        guard let image = croppedImage else {
            alertMessage = "Error: Cropped image is not available"
            showSaveAlert = true
            return
        }

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            alertMessage = "Error: Could not get image data"
            showSaveAlert = true
            return
        }

        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("membership_cards/\(currentUserID).jpg")

        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                alertMessage = "Error uploading image: \(error.localizedDescription)"
                showSaveAlert = true
                return
            }

            imageRef.downloadURL { url, error in
                if let error = error {
                    alertMessage = "Error getting image URL: \(error.localizedDescription)"
                    showSaveAlert = true
                    return
                }

                guard let downloadURL = url else {
                    alertMessage = "Error: Could not get image URL"
                    showSaveAlert = true
                    return
                }

                // Save the card info and image URL to Firestore under the user's document
                let db = Firestore.firestore()
                db.collection("users").document(currentUserID).setData([
                    "membershipCardInfo": cardInfo,
                    "membershipCardImageURL": downloadURL.absoluteString
                ], merge: true) { error in
                    if let error = error {
                        alertMessage = "Error saving to Firestore: \(error.localizedDescription)"
                    } else {
                        alertMessage = "Membership card saved successfully!"
                        // Navigate back to profile view
                        presentationMode.wrappedValue.dismiss()
                    }
                    showSaveAlert = true
                }
            }
        }
    }

    func removeMembershipCardFromFirestore() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Error: User is not logged in")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(currentUserID).updateData([
            "membershipCardInfo": FieldValue.delete(),
            "membershipCardImageURL": FieldValue.delete()
        ]) { error in
            if let error = error {
                print("Error removing membership card data: \(error.localizedDescription)")
            } else {
                print("Membership card data removed successfully")
            }
        }
    }
}

#Preview {
    MembershipCardView()
}

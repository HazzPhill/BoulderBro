import SwiftUI
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins
import Firebase
import FirebaseAuth
import FirebaseStorage
import Mantis

struct ManualCropView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    var onCropDone: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        var config = Mantis.Config()
        config.cropShapeType = .rect
        let cropViewController = Mantis.cropViewController(image: image!, config: config)
        cropViewController.delegate = context.coordinator
        
        let navigationController = UINavigationController(rootViewController: cropViewController)
        navigationController.modalPresentationStyle = .fullScreen
        
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CropViewControllerDelegate {
        var parent: ManualCropView

        init(_ parent: ManualCropView) {
            self.parent = parent
        }

        func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation, cropInfo: CropInfo) {
            parent.onCropDone(cropped)
            parent.isPresented = false
        }

        func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {
            parent.isPresented = false
        }

        func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
            parent.isPresented = false
        }

        func cropViewControllerDidBeginResize(_ cropViewController: CropViewController) {}

        func cropViewControllerDidEndResize(_ cropViewController: CropViewController, original: UIImage, cropInfo: CropInfo) {}
    }
}

struct MembershipCardView: View {
    @State private var membershipImage: UIImage? = nil
    @State private var croppedImage: UIImage? = nil
    @State private var cardInfo: String = ""
    @State private var showImagePicker = false
    @State private var showRemoveAlert = false
    @State private var showSaveAlert = false
    @State private var alertMessage = ""
    @State private var isManualCropping = false

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            if let image = croppedImage ?? membershipImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .padding()
                    .background(Color("CardBackground"))
                    .cornerRadius(10)
                    .shadow(radius: 5)
            } else {
                Text("No Membership Card Uploaded")
                    .foregroundColor(.gray)
                    .padding()
            }

            Text(cardInfo)
                .font(.custom("YourCustomFont", size: 16))
                .padding()

            HStack {
                Button(action: {
                    showImagePicker.toggle()
                }) {
                    Text("Update Card")
                        .font(.custom("YourCustomFont-Bold", size: 16))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                if membershipImage != nil || croppedImage != nil {
                    Button(action: {
                        showRemoveAlert.toggle()
                    }) {
                        Text("Remove Card")
                            .font(.custom("YourCustomFont-Bold", size: 16))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
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
            }

            if membershipImage != nil || croppedImage != nil {
                Button(action: {
                    isManualCropping = true
                }) {
                    Text("Manual Crop")
                        .font(.custom("YourCustomFont-Bold", size: 16))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }

            if (membershipImage != nil || croppedImage != nil) && !cardInfo.isEmpty {
                Button(action: {
                    saveToFirebase()
                }) {
                    Text("Save")
                        .font(.custom("YourCustomFont-Bold", size: 16))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .alert(isPresented: $showSaveAlert) {
                    Alert(title: Text(alertMessage))
                }
            }
        }
        .padding()
        .background(Color("Background"))
        .cornerRadius(15)
        .shadow(radius: 10)
        .sheet(isPresented: $showImagePicker, onDismiss: processImage) {
            ImagePicker(selectedImage: $membershipImage, selectedVideoURL: .constant(nil))
        }
        .fullScreenCover(isPresented: $isManualCropping) {
            ManualCropView(image: $membershipImage, isPresented: $isManualCropping) { croppedImage in
                self.croppedImage = croppedImage
                extractText(from: croppedImage)
            }
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

        croppedImage = cropToMembershipCard(image)

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

                let db = Firestore.firestore()
                db.collection("users").document(currentUserID).setData([
                    "membershipCardInfo": cardInfo,
                    "membershipCardImageURL": downloadURL.absoluteString
                ], merge: true) { error in
                    if let error = error {
                        alertMessage = "Error saving to Firestore: \(error.localizedDescription)"
                    } else {
                        alertMessage = "Membership card saved successfully!"
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

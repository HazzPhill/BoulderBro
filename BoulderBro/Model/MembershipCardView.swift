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
    @State private var gymName: String = ""
    @State private var showImagePicker = false
    @State private var showRemoveAlert = false
    @State private var showSaveAlert = false
    @State private var alertMessage = ""
    @State private var isManualCropping = false
    @State private var showEditOptions = false
    @State private var isEditingInfo = false
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    // Circle variables for animated background circles
    @State private var topCircleOffset = CGSize(width: 150, height: -300)
    @State private var bottomCircleOffset = CGSize(width: -150, height: 250)
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        if let user = viewModel.currentUser {
            ZStack {
                // Background color
                Color(colorScheme == .dark ? Color(hex: "#1f1f1f") : Color(hex: "#f1f0f5"))
                    .ignoresSafeArea()
                    .zIndex(-2)

                // Top circle
                Circle()
                    .fill(Color(hex: "#FF5733")).opacity(0.3)
                    .frame(width: 350, height: 350)
                    .blur(radius: 60)
                    .offset(topCircleOffset)
                    .opacity(0.5)
                    .zIndex(-1)

                // Bottom circle
                Circle()
                    .fill(Color(hex: "#FF5733")).opacity(0.3)
                    .frame(width: 350, height: 500)
                    .blur(radius: 60)
                    .offset(bottomCircleOffset)
                    .opacity(0.5)
                    .zIndex(-1)

                // Animate circle offsets
                .onReceive(timer) { _ in
                    withAnimation(.linear(duration: 0.9)) {
                        let newTopOffset = CGSize(
                            width: max(50, min(UIScreen.main.bounds.width - 300, topCircleOffset.width + CGFloat.random(in: -50...50))),
                            height: max(-250, min(-50, topCircleOffset.height + CGFloat.random(in: -25...25)))
                        )
                        let newBottomOffset = CGSize(
                            width: max(-200, min(UIScreen.main.bounds.width - 300, bottomCircleOffset.width + CGFloat.random(in: -50...50))),
                            height: max(50, min(UIScreen.main.bounds.height - 450, bottomCircleOffset.height + CGFloat.random(in: -25...25)))
                        )

                        topCircleOffset = newTopOffset
                        bottomCircleOffset = newBottomOffset
                    }
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text ("\(user.firstName)'s Membership Card")
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .font(.custom("Kurdis-ExtraWideBlack", size: 30))
                            .fontWeight(.bold)
                            .foregroundStyle(Color(colorScheme == .dark ? Color(hex: "#ffffff") : Color(hex: "#000000")))
                            .opacity(0.7)
                            .padding(.top)

                        if let image = croppedImage ?? membershipImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .padding()
                                .background(Color(colorScheme == .dark ? Color(hex: "#333333") : .white))
                                .cornerRadius(10)
                                .shadow(radius: 5)
                            
                            VStack(spacing: 16) { // Stack buttons vertically
                                EditButton(showEditOptions: $showEditOptions)
                                    .frame(maxWidth: .infinity) // Ensure buttons are the same width
                                
                                if shouldShowSaveButton {
                                    SaveButton(action: saveToFirebase)
                                        .frame(maxWidth: .infinity)
                                        .alert(isPresented: $showSaveAlert) {
                                            Alert(title: Text(alertMessage))
                                        }
                                }
                            }
                            .padding(.horizontal)
                            .actionSheet(isPresented: $showEditOptions) {
                                ActionSheet(
                                    title: Text("Edit Membership Card"),
                                    buttons: editActionButtons()
                                )
                            }
                            .alert(isPresented: $showRemoveAlert) {
                                removeAlert()
                            }
                        } else {
                            EmptyStateView(showImagePicker: $showImagePicker)
                                .frame(maxWidth: .infinity)
                        }

                        if shouldShowCardInfo {
                            CardInfoView(cardInfo: $cardInfo, gymName: $gymName, isEditingInfo: $isEditingInfo)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $showImagePicker, onDismiss: processImage) {
                ImagePicker(selectedImage: $membershipImage, selectedVideoURL: .constant(nil))
            }
            .fullScreenCover(isPresented: $isManualCropping) {
                ManualCropView(image: $membershipImage, isPresented: $isManualCropping) { croppedImage in
                    self.croppedImage = croppedImage
                    extractText(from: croppedImage)
                }
            }
            .onAppear(perform: loadMembershipCardData)
        }
    }

    private var shouldShowCardInfo: Bool {
        !cardInfo.isEmpty || !gymName.isEmpty || membershipImage != nil || croppedImage != nil
    }

    private var shouldShowSaveButton: Bool {
        (membershipImage != nil || croppedImage != nil) && (!cardInfo.isEmpty || !gymName.isEmpty)
    }

    private func editActionButtons() -> [ActionSheet.Button] {
        [
            .default(Text("Manual Crop")) { isManualCropping = true },
            .default(Text("Update Card")) { showImagePicker = true },
            .destructive(Text("Remove Card")) { showRemoveAlert = true },
            .cancel()
        ]
    }

    private func removeAlert() -> Alert {
        Alert(
            title: Text("Remove Membership Card"),
            message: Text("Are you sure you want to remove your membership card?"),
            primaryButton: .destructive(Text("Remove")) {
                membershipImage = nil
                croppedImage = nil
                cardInfo = ""
                gymName = ""
                removeMembershipCardFromFirestore()
            },
            secondaryButton: .cancel()
        )
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

            if let gymName = data["gymName"] as? String {
                self.gymName = gymName
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

        var croppedImage: UIImage? = nil
        
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
            return nil
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
                    "gymName": gymName,
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
            "gymName": FieldValue.delete(),
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

struct EditButton: View {
    @Binding var showEditOptions: Bool

    var body: some View {
        Button(action: {
            showEditOptions.toggle()
        }) {
            HStack {
                Image(systemName: "pencil.circle")
                Text("Edit Card Info")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity) // Ensure full width
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding(.horizontal) // Padding between buttons
    }
}

struct EmptyStateView: View {
    @Binding var showImagePicker: Bool

    var body: some View {
        VStack(spacing: 16) {
            Text("No Membership Card Uploaded")
                .foregroundColor(.gray)
                .padding()
            
            Button(action: {
                showImagePicker.toggle()
            }) {
                Text("Upload Card")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
}

struct CardInfoView: View {
    @Binding var cardInfo: String
    @Binding var gymName: String
    @Binding var isEditingInfo: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Card Information")
                .font(.headline)
                .padding(.top, 20)
            
            if !gymName.isEmpty {
                Text("Gym Name: \(gymName)")
                    .font(.custom("YourCustomFont", size: 16))
            }

            Text(cardInfo)
                .font(.custom("YourCustomFont", size: 16))
                .padding()

            EditButton(showEditOptions: $isEditingInfo)
                .sheet(isPresented: $isEditingInfo) {
                    EditCardInfoView(cardInfo: $cardInfo, gymName: $gymName)
                }
        }
        .padding(.horizontal)
    }
}

struct SaveButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "tray.and.arrow.down")
                Text("Save")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity) // Ensure full width
            .padding()
            .background(Color(hex: "#FF5733"))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding(.horizontal) // Padding between buttons
    }
}

struct EditCardInfoView: View {
    @Binding var cardInfo: String
    @Binding var gymName: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextField("Enter card information", text: $cardInfo)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .padding()

                TextField("Enter gym name", text: $gymName)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .padding()

                Spacer()
            }
            .navigationBarTitle("Edit Card Info", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    MembershipCardView()
}

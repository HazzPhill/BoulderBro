import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

struct LogClimbView: View {
    @State private var climbName: String = ""
    @State private var selectedVRating: String? = nil
    @State private var selectedDifficulty: String? = nil
    @State private var selectedType: String? = nil
    @State private var climbResult: String? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var selectedVideoURL: URL? = nil
    @State private var selectedImageData: Data? = nil
    @State private var isUploading = false
    @State private var uploadStatusMessage = ""
    @State private var navigateToMyClimbView = false
    @State private var showImagePicker = false
    
    let vRatings = ["V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "V10", "V11", "V12"]
    let difficulties = ["Easy", "Medium", "Hard", "Challenge"]
    let types = ["Overhang", "Normal"]
    let results = ["Completed", "Failed"]
    
    private func resetForm() {
        climbName = ""
        selectedVRating = nil
        selectedDifficulty = nil
        selectedType = nil
        climbResult = nil
        selectedImage = nil
        selectedVideoURL = nil
        selectedImageData = nil
        showImagePicker = false
    }
    
    @EnvironmentObject var colorThemeManager: ColorThemeManager
    @Environment(\.colorScheme) var colorScheme

    var adjustedColor: Color {
        colorScheme == .dark ? Color(hex: "#333333") : .white
    }
    
    var body: some View {
        ZStack {
            colorThemeManager.currentThemeColor // Extend background color to edges
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment:.leading, spacing: 16) {
                    
                    Text("LOG A CLIMB")
                        .font(.custom("Kurdis-ExtraWideBold", size: 30))
                        .foregroundColor(adjustedColor)
                        .padding(.top, 10)
                    
                    Divider() // Divider after the header

                    Text("Name Climb")
                        .font(.custom("Kurdis-ExtraWideBold", size: 16))
                        .foregroundColor(adjustedColor)
                        .padding(.top, 10)
                    
                    TextField("Enter Climb Name", text: $climbName)
                        .font(.custom("Kurdis-Regular", size: 20))
                        .padding()
                        .background(adjustedColor)
                        .cornerRadius(12)
                        .padding(.top, 30)
                    
                    Divider() // Divider after climb name

                    Text("V Rating")
                        .font(.custom("Kurdis-ExtraWideBold", size: 16))
                        .foregroundColor(adjustedColor)
                        .padding(.top, 10)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 4), spacing: 20) {
                        ForEach(vRatings, id: \.self) { rating in
                            Button(action: {
                                selectedVRating = rating
                            }) {
                                Text(rating)
                                    .font(.custom("Kurdis-ExtraWideBold", size: 18))
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(selectedVRating == rating ? colorThemeManager.currentThemeColor : adjustedColor)
                                    .background(selectedVRating == rating ? adjustedColor : colorThemeManager.currentThemeColor)
                                    .cornerRadius(30)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(adjustedColor, lineWidth: 2)
                                    )
                            }
                        }
                    }

                    Divider() // Divider after V rating section

                    Text("Choose Difficulty")
                        .font(.custom("Kurdis-ExtraWideBold", size: 16))
                        .foregroundColor(adjustedColor)
                        .padding(.top, 10)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                        ForEach(difficulties, id: \.self) { difficulty in
                            Button(action: {
                                selectedDifficulty = difficulty
                            }) {
                                Text(difficulty.uppercased())
                                    .font(.custom("Kurdis-ExtraWideBold", size: 15))
                                    .frame(width: 140, height: 50)
                                    .foregroundColor(selectedDifficulty == difficulty ? colorThemeManager.currentThemeColor : adjustedColor)
                                    .background(selectedDifficulty == difficulty ? adjustedColor : colorThemeManager.currentThemeColor)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(adjustedColor, lineWidth: 2)
                                    )
                            }
                        }
                    }

                    Divider() // Divider after difficulty section

                    Text("Climb Type")
                        .font(.custom("Kurdis-ExtraWideBold", size: 16))
                        .foregroundColor(adjustedColor)
                        .padding(.top, 10)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                        ForEach(types, id: \.self) { type in
                            Button(action: {
                                selectedType = type
                            }) {
                                Text(type.uppercased())
                                    .font(.custom("Kurdis-ExtraWideBold", size: 15))
                                    .frame(width: 140, height: 50)
                                    .foregroundColor(selectedType == type ? colorThemeManager.currentThemeColor : adjustedColor)
                                    .background(selectedType == type ? adjustedColor : colorThemeManager.currentThemeColor)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(adjustedColor, lineWidth: 2)
                                    )
                            }
                        }
                    }

                    Divider() // Divider after climb type section

                    Text("Result")
                        .font(.custom("Kurdis-ExtraWideBold", size: 16))
                        .foregroundColor(adjustedColor)
                        .padding(.top, 10)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                        ForEach(results, id: \.self) { result in
                            Button(action: {
                                climbResult = result
                            }) {
                                Text(result.uppercased())
                                    .font(.custom("Kurdis-ExtraWideBold", size: 15))
                                    .frame(width: 140, height: 50)
                                    .foregroundColor(climbResult == result ? colorThemeManager.currentThemeColor : adjustedColor)
                                    .background(climbResult == result ? adjustedColor : colorThemeManager.currentThemeColor)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(adjustedColor, lineWidth: 2)
                                    )
                            }
                        }
                    }

                    Divider() // Divider after result section

                    Text("Upload Image")
                        .font(.custom("Kurdis-ExtraWideBold", size: 16))
                        .foregroundColor(adjustedColor)
                        .padding(.top, 10)
                    
                    Text("(Optional)")
                        .font(.custom("Kurdis-Regular", size: 11))
                        .foregroundColor(adjustedColor)
                    
                    // Image Picker button
                    Button(action: {
                        showImagePicker = true
                    }) {
                        Label("Upload Image", systemImage: "photo.fill.on.rectangle.fill")
                            .font(.custom("Kurdis-ExtraWideBold", size: 18))
                            .frame(width: 300, height: 50)
                            .foregroundColor(colorThemeManager.currentThemeColor)
                            .background(adjustedColor)
                            .cornerRadius(12)
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(selectedImage: $selectedImage, selectedVideoURL: $selectedVideoURL)
                    }
                    .onChange(of: selectedImage) { newImage in
                        if let newImage {
                            selectedImageData = newImage.jpegData(compressionQuality: 0.8)
                        }
                    }

                    Divider() // Divider after image upload section

                    Button(action: {
                        uploadClimb()
                    }) {
                        Text("ADD CLIMB")
                            .font(.custom("Kurdis-ExtraWideBold", size: 20))
                            .frame(width: 300, height: 50)
                            .foregroundColor(colorThemeManager.currentThemeColor)
                            .background(adjustedColor)
                            .cornerRadius(12)
                    }
                    .padding(.top, 30)
                    .disabled(isUploading || climbName.isEmpty || selectedVRating == nil || selectedDifficulty == nil || selectedType == nil || climbResult == nil)
                    
                    Spacer()
                }
                .padding()
                .padding(.bottom,50)
            }
        }
        .alert(isPresented: .constant(!uploadStatusMessage.isEmpty)) {
            Alert(
                title: Text("Upload Status"),
                message: Text(uploadStatusMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationDestination(isPresented: $navigateToMyClimbView) {
            MyClimbsView() // Replace with your actual MyClimbsView implementation
        }
    }
    
    private func uploadClimb() {
        guard let user = Auth.auth().currentUser else {
            uploadStatusMessage = "You must be logged in to upload a climb."
            return
        }

        isUploading = true

        if let imageData = selectedImageData {
            uploadMedia(data: imageData, mediaType: "image/jpeg") { url in
                guard let mediaURL = url else {
                    uploadStatusMessage = "Failed to upload image."
                    isUploading = false
                    return
                }
                saveClimb(mediaURL: mediaURL, userId: user.uid)
            }
        } else {
            saveClimb(mediaURL: nil, userId: user.uid)
        }
    }
    
    private func uploadMedia(data: Data, mediaType: String, completion: @escaping (String?) -> Void) {
        let fileName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("climbs/\(fileName).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = mediaType
        
        storageRef.putData(data, metadata: metadata) { _, error in
            guard error == nil else {
                print("Failed to upload media: \(error!.localizedDescription)")
                completion(nil)
                return
            }
            storageRef.downloadURL { url, error in
                guard let url = url else {
                    print("Failed to get download URL: \(error!.localizedDescription)")
                    completion(nil)
                    return
                }
                completion(url.absoluteString)
            }
        }
    }

    private func saveClimb(mediaURL: String?, userId: String) {
        let db = Firestore.firestore()
        let climbData: [String: Any] = [
            "name": climbName,
            "difficulty": selectedDifficulty ?? "",
            "vRating": selectedVRating ?? "",
            "climbtype": selectedType ?? "",
            "result": climbResult ?? "",
            "mediaURL": mediaURL ?? "",
            "userId": userId,
            "timestamp": Timestamp()
        ]

        db.collection("climbs").addDocument(data: climbData) { error in
            if let error = error {
                uploadStatusMessage = "Error adding document: \(error.localizedDescription)"
            } else {
                uploadStatusMessage = "Climb successfully uploaded!"
                resetForm()
            }
            isUploading = false
        }
    }
}

#Preview {
    LogClimbView()
}

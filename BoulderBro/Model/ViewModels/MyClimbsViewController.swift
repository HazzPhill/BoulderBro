import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import AVKit

struct MyClimbsViewController: View {
    @State private var name: String = ""
    @State private var difficulty: String = "Easy"
    @State private var vRating: String = "V1"
    @State private var location: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var selectedVideoURL: URL? = nil
    @State private var isImagePickerPresented = false
    @State private var isUploading = false
    @State private var uploadStatusMessage = ""
    @State private var navigateToMyClimbView = false

    let difficulties = ["Easy", "Medium", "Challenge", "Hard"]
    let vRatings = (1...12).map { "V\($0)" }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Upload your climb")
                    .font(.custom("Kurdis-ExtraWideBold", size: 16))
                    .foregroundColor(.orange)) {
                    
                    TextField("Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 5)
                        .background(Color.white)
                        .font(.custom("Kurdis-Regular", size: 16))

                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(difficulties, id: \.self) { difficulty in
                            Text(difficulty)
                                .font(.custom("Kurdis-Regular", size: 16))
                                .foregroundColor(.primary)
                                .tag(difficulty)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.vertical, 5)
                    .background(Color.white)

                    Picker("V Rating", selection: $vRating) {
                        ForEach(vRatings, id: \.self) { rating in
                            Text(rating)
                                .font(.custom("Kurdis-ExtraWideBold", size: 16))
                                .foregroundColor(.primary)
                                .tag(rating)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.vertical, 5)
                    .background(Color.white)

                    TextField("Location", text: $location)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 5)
                        .background(Color.white)
                        .font(.custom("Kurdis-Regular", size: 16))
                }

                Section(header: Text("Select Image or Video")
                    .font(.custom("Kurdis-ExtraWideBold", size: 16))
                    .foregroundColor(.orange)) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    } else if let videoURL = selectedVideoURL {
                        VideoPlayer(player: AVPlayer(url: videoURL))
                            .frame(height: 200)
                    } else {
                        Button("Select Image/Video") {
                            isImagePickerPresented.toggle()
                        }
                        .font(.custom("Kurdis-ExtraWideBold", size: 16))
                    }
                }

                Section {
                    if isUploading {
                        ProgressView("Uploading...")
                            .font(.custom("Kurdis-ExtraWideBold", size: 16))
                    } else {
                        Button("Upload Climb") {
                            uploadClimb()
                        }
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .font(.custom("Kurdis-Regular", size: 16))
                    }
                }
            }
            .navigationTitle("My Climbs")
                .font(.custom("Kurdis-Regular", size: 16))
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage, selectedVideoURL: $selectedVideoURL)
            }
            .alert(isPresented: .constant(!uploadStatusMessage.isEmpty)) {
                Alert(
                    title: Text("Upload Status")
                        .font(.custom("Kurdis-Regular", size: 16)),
                    message: Text(uploadStatusMessage)
                        .font(.custom("Kurdis-Regular", size: 16)),
                    dismissButton: .default(Text("OK")
                        .font(.custom("Kurdis-Regular", size: 16)))
                )
            }
            .navigationDestination(isPresented: $navigateToMyClimbView) {
                MyClimbsView()
            }
        }
    }
    
    func uploadClimb() {
        guard let firebaseUser = Auth.auth().currentUser else {
            uploadStatusMessage = "You must be logged in to upload a climb."
            return
        }

        isUploading = true

        if let imageData = selectedImage?.jpegData(compressionQuality: 0.8) {
            uploadMedia(data: imageData, mediaType: "image/jpeg") { url in
                guard let mediaURL = url else {
                    uploadStatusMessage = "Failed to upload image."
                    isUploading = false
                    return
                }
                saveClimb(mediaURL: mediaURL, userId: firebaseUser.uid)
            }
        } else if let videoURL = selectedVideoURL {
            if let videoData = try? Data(contentsOf: videoURL) {
                uploadMedia(data: videoData, mediaType: "video/mp4") { url in
                    guard let mediaURL = url else {
                        uploadStatusMessage = "Failed to upload video."
                        isUploading = false
                        return
                    }
                    saveClimb(mediaURL: mediaURL, userId: firebaseUser.uid)
                }
            }
        } else {
            uploadStatusMessage = "Please select an image or video."
            isUploading = false
        }
    }

    func uploadMedia(data: Data, mediaType: String, completion: @escaping (String?) -> Void) {
        let fileName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("climbs/\(fileName).\(mediaType == "image/jpeg" ? "jpg" : "mp4")")
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

    func saveClimb(mediaURL: String?, userId: String) {
        let db = Firestore.firestore()
        let climbData: [String: Any] = [
            "name": name,
            "difficulty": difficulty,
            "vRating": vRating,
            "location": location,
            "mediaURL": mediaURL ?? "",
            "userId": userId
        ]

        db.collection("climbs").addDocument(data: climbData) { error in
            if let error = error {
                uploadStatusMessage = "Error adding document: \(error.localizedDescription)"
            } else {
                uploadStatusMessage = "Climb successfully uploaded!"
                navigateToMyClimbView = true // Trigger navigation on success
            }
            isUploading = false
        }
    }
}

    
#Preview {
    MyClimbsViewController()
}

//  ImagePicker.swift
//  BoulderBro
//
//  Created by Hazz on 20/08/2024.
//

import SwiftUI
import UIKit
import AVKit

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var selectedVideoURL: URL?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.mediaTypes = ["public.image", "public.movie"] // Allow both images and videos
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.selectedVideoURL = nil
            } else if let videoURL = info[.mediaURL] as? URL {
                parent.selectedVideoURL = videoURL
                parent.selectedImage = nil
            }
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    @Previewable @State var image: UIImage? = nil        // Create a state variable to hold the image
    @Previewable @State var video: URL? = nil            // Create a state variable to hold the video URL
    ImagePicker(selectedImage: $image, selectedVideoURL: $video) // Pass the bindings to the ImagePicker
}

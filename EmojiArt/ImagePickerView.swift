//
//  ImagePickerView.swift
//  EmojiArt
//
//  Created by Entangled Mind on 6/4/2022.
//

import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    var pickSource: PickerSource?
    var imageHandler: (UIImage?) -> Void
    static var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    static var isLibraryAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(imageHandler: imageHandler)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = (pickSource == .camera) ? .camera : .photoLibrary
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Do Nothing
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var imageHandler: (UIImage?) -> Void
        init(imageHandler: @escaping (UIImage?) -> Void) {
            self.imageHandler = imageHandler
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            imageHandler((info[.editedImage] ?? info[.originalImage]) as? UIImage)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            imageHandler(nil)
        }
    }
    
    enum PickerSource {
        case camera
        case library
    }
    
}

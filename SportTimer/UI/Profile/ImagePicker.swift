//
//  ImagePicker.swift
//  SportTimer
//
//  Created by Nikolay Taran on 7/10/25.
//

import SwiftUI
import MobileCoreServices
import Photos

struct ImagePicker: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode) private var presentationMode
    
    let sourceType: UIImagePickerController.SourceType
    let onPhotoPicked: (PHAsset) -> Void
    
    final class Coordinator: NSObject,
                             UINavigationControllerDelegate,
                             UIImagePickerControllerDelegate {
        @Binding
        private var presentationMode: PresentationMode
        private let sourceType: UIImagePickerController.SourceType
        private let onPhotoPicked: (PHAsset) -> Void

        init(presentationMode: Binding<PresentationMode>,
                sourceType: UIImagePickerController.SourceType,
                onPhotoPicked: @escaping (PHAsset) -> Void) {
            _presentationMode = presentationMode
            self.sourceType = sourceType
            self.onPhotoPicked = onPhotoPicked
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
                onPhotoPicked(asset)
            }
            
            presentationMode.dismiss()

        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode,
                            sourceType: sourceType,
                            onPhotoPicked: onPhotoPicked)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.mediaTypes = ["public.image"]
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context:UIViewControllerRepresentableContext<ImagePicker>) {

    }
}

//
//  ProfileObservable.swift
//  SportTimer
//
//  Created by Nikolay Taran on 7/10/25.
//

import SwiftUI
import PhotosUI

class ProfileObservable: TrainingObservable {
    
    @Published var userAvatar: UIImage?
    
    /**
     Navigation Buttons
     */
    @Published var shouldNavigateToSettings = false
    @Published var shouldNavigateToStatistics = false
    
    /**
     Permissions
     */
    @Published var showPicker = false
    @Published var galleryPermissionError = false
    
    func checkPermissionAndUpdateUserAvatar() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async { [weak self] in
                if status == .authorized || status == .limited {
                    self?.showPicker = true
                } else {
                    self?.galleryPermissionError = true
                }
            }
        }
    }
    
    func updateUserAvatar(asset: PHAsset) {
        nowLoading = true
        
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = false
        
        manager.requestImage(for: asset,
                                targetSize: CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width),
                                contentMode: .aspectFit,
                                options: option) { result, info in
            guard let result = result else {
                self.nowLoading = false
                return
            }
            
            self.userAvatar = result
            
            Task {
                await self.saveUserAvatar(image: result)
            }
        }
    }
    
    @MainActor
    private func saveUserAvatar(image: UIImage) async {
        let data = image.jpegData(compressionQuality: 100)
            
        if let data = data, let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Avatar.jpg", isDirectory: false) {
            try? data.write(to: path, options: [.atomic, .completeFileProtection])
        }
        
        nowLoading = false
    }
    
    @MainActor
    private func fetchUserAvatar() async {
        if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Avatar.jpg", isDirectory: false),
            let data = try? Data(contentsOf: path) {
            let image = UIImage(data: data)
            
            userAvatar = image
        }
        
        nowLoading = false
    }
    
    func fetchUserProfile() {
        nowLoading = true
        
        Task {
            await fetchUserAvatar()
        }
    }
}

//
//  PhotoViewModel.swift
//  TestAppForCombine
//
//  Created by Hyun A Song on 5/17/24.
//

import SwiftUI
import Combine

class PhotoViewModel: ObservableObject {
    @Published var photos: [Photo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let photoService = PhotoService()
    
    func loadPhotos() {
        isLoading = true
        errorMessage = nil
        
        photoService.fetchPhotos()
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { photos in
                self.photos = photos
            })
            .store(in: &cancellables)
    }
}

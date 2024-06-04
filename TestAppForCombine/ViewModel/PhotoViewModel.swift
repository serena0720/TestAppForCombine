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

// MARK: - Observation
/*
 @Observable
 https://green1229.tistory.com/373
 https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app
 https://developer.apple.com/documentation/Observation
 https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro
 https://forums.swift.org/t/lifecycle-of-swiftui-view-observable-vs-observableobject/69842
 */
@Observable class ObservablePhotoViewModel: Identifiable {
  var photos: [Photo] = []
  var isLoading = false
  var errorMessage: String?
  
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

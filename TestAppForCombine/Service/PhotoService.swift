//
//  PhotoService.swift
//  TestAppForCombine
//
//  Created by Hyun A Song on 5/17/24.
//

import Foundation
import Combine

final class PhotoService {
  private let baseURL = "https://api.unsplash.com/photos"
  private var apiKey = Bundle.main.apiKey
  
  func fetchPhotos() -> AnyPublisher<[Photo], Error> {
    var components = URLComponents(string: baseURL)!
    components.queryItems = [
      URLQueryItem(name: "client_id", value: apiKey)
    ]
    
    let request = URLRequest(url: components.url!)
    
    return URLSession.shared.getPhoto(for: request)
  }
}

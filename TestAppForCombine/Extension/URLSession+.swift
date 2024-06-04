//
//  URLSession+.swift
//  TestAppForCombine
//
//  Created by Hyun A Song on 5/26/24.
//

import Foundation
import Combine

extension URLSession {
  func getPhoto<T>(for request: URLRequest) -> AnyPublisher<[T], Error> where T: Decodable {
    self
      .dataTaskPublisher(for: request)
      .map(\.data)
      .decode(as: [T].self)
      .validate { reponse in
        guard !reponse.isEmpty else {
          throw APIError.unValidated
        }
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
  
  func getFirstPhoto<T>(for request: URLRequest) -> AnyPublisher<T, Error> where T: Decodable {
    self
      .dataTaskPublisher(for: request)
      .map(\.data)
      .decode(as: [T].self)
      .map(\[T].first)
      .unwrap(orThrow: APIError.unValidated)
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
}

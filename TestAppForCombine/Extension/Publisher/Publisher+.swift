//
//  Publisher+.swift
//  TestAppForCombine
//
//  Created by Hyun A Song on 5/26/24.
//

import Foundation
import Combine

// MARK: - Custom Function
extension Publisher {
  func unwrap<T>() -> Publishers.CompactMap<Self, T> where Output == Optional<T> {
    compactMap { $0 }
  }
  
  func decode<T: Decodable>(as type: T.Type = T.self,
                            using decoder: JSONDecoder = .init()) -> Publishers.Decode<Self, T, JSONDecoder> where Output == Data {
    decode(type: type, decoder: decoder)
  }
  
  func validate(using validator: @escaping (Output) throws -> Void) -> Publishers.TryMap<Self, Output> {
    tryMap { output in
      try validator(output)
      return output
    }
  }
  
  func unwrap<T>(orThrow error: @escaping @autoclosure () -> Failure) -> Publishers.TryMap<Self, T> where Output == Optional<T> {
    tryMap { output in
      switch output {
      case .some(let value):
        return value
      case nil:
        throw APIError.unValidated
      }
    }
  }
  
  func convertToResult() -> AnyPublisher<Result<Output, Failure>, Never> {
    self.map(Result.success)
      .catch { Just(.failure($0)) }
      .eraseToAnyPublisher()
  }
}

// MARK: - Replay
extension Publisher {
  
}

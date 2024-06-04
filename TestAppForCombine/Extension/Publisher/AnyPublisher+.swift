//
//  AnyPublisher+.swift
//  TestAppForCombine
//
//  Created by Hyun A Song on 5/26/24.
//

import Combine

extension AnyPublisher {
  static func just(_ output: Output) -> Self {
    Just(output)
      .setFailureType(to: Failure.self)
      .eraseToAnyPublisher()
  }
  
  static func fail(with error: Failure) -> Self {
    Fail(error: error).eraseToAnyPublisher()
  }
}

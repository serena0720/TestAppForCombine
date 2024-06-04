//
//  APIError.swift
//  TestAppForCombine
//
//  Created by Hyun A Song on 5/26/24.
//

enum APIError: Error {
  case unValidated
  case failToUnwrap
  
  var discription: String {
    switch self {
    case .unValidated:
      "유효하지 않은 값입니다."
    case .failToUnwrap:
      "Unwrap 실패했대."
    }
  }
}

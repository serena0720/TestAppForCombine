//
//  Bundle+.swift
//  TestAppForCombine
//
//  Created by Hyun A Song on 5/17/24.
//

import Foundation

extension Bundle {
  var apiKey: String {
    guard let file = self.path(forResource: "APIKey", ofType: "plist") else { return "" }
    guard let resource = NSDictionary (contentsOfFile: file) else { return "" }
    guard let key = resource["Authorization"] as? String else {
      fatalError("APIKey.plist에 Authorization를 설정해주세요.")
    }
    
    return key
  }
}

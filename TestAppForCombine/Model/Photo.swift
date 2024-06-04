//
//  Photo.swift
//  TestAppForCombine
//
//  Created by Hyun A Song on 5/17/24.
//

struct Photo: Identifiable, Decodable {
  var id: String
  var description: String?
  var urls: Urls
}

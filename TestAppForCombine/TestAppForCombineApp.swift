//
//  TestAppForCombineApp.swift
//  TestAppForCombine
//
//  Created by Hyun A Song on 5/17/24.
//

import SwiftUI

@main
struct TestAppForCombineApp: App {
//  @StateObject private var viewModel = PhotoViewModel()
  private var viewModel = ObservablePhotoViewModel()
  
  var body: some Scene {
    WindowGroup {
      ContentView(viewModel: viewModel)
    }
  }
}

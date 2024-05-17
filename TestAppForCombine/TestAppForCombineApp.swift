//
//  TestAppForCombineApp.swift
//  TestAppForCombine
//
//  Created by Hyun A Song on 5/17/24.
//

import SwiftUI

@main
struct TestAppForCombineApp: App {
    @StateObject private var viewModel = PhotoViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}

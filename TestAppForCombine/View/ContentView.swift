//
//  ContentView.swift
//  TestAppForCombine
//
//  Created by Hyun A Song on 5/17/24.
//

import SwiftUI

struct ContentView: View {
//  @ObservedObject var viewModel: PhotoViewModel
  @State var viewModel: ObservablePhotoViewModel
  
  var body: some View {
    NavigationView {
      Group {
        if viewModel.isLoading {
          ProgressView("Loading...")
        } else if let errorMessage = viewModel.errorMessage {
          Text("Error: \(errorMessage)")
        } else {
          PhotoScrollView(viewModel: viewModel)
        }
      }
      .navigationBarTitle("Photo Album")
      .onAppear {
        viewModel.loadPhotos()
      }
    }
  }
}

// MARK: - Custom View
struct PhotoScrollView: View {
  private let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible())
  ]
//  var viewModel: PhotoViewModel
  var viewModel: ObservablePhotoViewModel
  
  var body: some View {
    ScrollView {
      LazyVGrid(columns: columns, spacing: 5) {
        ForEach(viewModel.photos) { photo in
          NavigationLink(destination: PhotoDetailView(photo: photo)) {
            AsyncImage(url: URL(string: photo.urls.small)) { image in
              image
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipped()
            } placeholder: {
              ProgressView()
            }
          }
        }
      }
      .padding()
    }
  }
}

struct PhotoDetailView: View {
  var photo: Photo
  
  var body: some View {
    let url = URL(string: photo.urls.full)
    let description = photo.description ?? "No description"
    
    VStack {
      AsyncImage(url: url) { image in
        image
          .resizable()
          .aspectRatio(contentMode: .fit)
      } placeholder: {
        ProgressView()
      }
      Text(description)
        .font(.largeTitle)
        .padding()
      Spacer()
    }
    .navigationBarTitle("Photo Detail",
                        displayMode: .inline)
  }
}

// MARK: - Preview
#Preview {
//  ContentView(viewModel: PhotoViewModel())
  ContentView(viewModel: ObservablePhotoViewModel())
}

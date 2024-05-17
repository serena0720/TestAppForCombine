//
//  ContentView.swift
//  TestAppForCombine
//
//  Created by Hyun A Song on 5/17/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: PhotoViewModel
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(viewModel.photos) { photo in
                                NavigationLink(destination: PhotoDetailView(photo: photo)) {
                                    AsyncImage(url: URL(string: photo.urls.small)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 150, height: 150)
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
            .navigationBarTitle("Photo Album")
            .onAppear {
                viewModel.loadPhotos()
            }
        }
    }
}

struct PhotoDetailView: View {
    var photo: Photo
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: photo.urls.full)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            Text(photo.description ?? "No description")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
        .navigationBarTitle("Photo Detail", displayMode: .inline)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: PhotoViewModel())
    }
}

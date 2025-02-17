//
//  ImageDetailView.swift
//  receipt-scanner
//
//  Created by Jason Tan on 2025-01-19.
//
import SwiftUI

struct ImageDetailView: View {
    let image: UIImage
    
    var body: some View {
        // You can customize the layout as you like.
        // Here we fill the screen with black behind, and center the image.
        ZStack {
            Color.black.ignoresSafeArea()
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding()
        }
        // Give the screen a title in a NavigationView context
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
    }
}


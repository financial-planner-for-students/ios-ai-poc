//
//  HomeView.swift
//  fips
//
//  Created by Jason Tan on 2025-02-06.
//
import SwiftUI

struct HomeView: View {
    // Setting up Global Router (NavigationService)
    @Environment(\.navigation) private var navigation: Navigation
    
    var body: some View {
        VStack (alignment: .center) {
            Button("Talk to a Bot") {
                navigation.path.append(Screen.chat)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .tint(.mint.opacity(0.8))
            .shadow(color: .blue, radius: 10)
            
            Button("Capture Receipts") {
                navigation.path.append(Screen.receipt)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .tint(.mint.opacity(0.8))
            .shadow(color: .blue, radius: 10)
        }
        .navigationTitle("Home")
    }
}


#Preview {
    RootView {
        HomeView()
    }
}

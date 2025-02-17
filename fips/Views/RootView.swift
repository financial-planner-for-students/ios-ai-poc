//
//  RootView.swift
//  fips
//
//  Created by Jason Tan on 2025-02-07.
//
import SwiftUI

struct RootView<Content: View>: View {
    let content: Content
    @StateObject private var navigation = Navigation()

    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        NavigationStack(path: $navigation.path){
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationDestination(for: Screen.self) { screen in
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea() // gym close @ 9
                    screen.destination
                }
            }
            .environment(\.navigation, navigation)
        }
    }
}

struct BackButton: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
            Text("Back")
        }
        .buttonStyle(.borderedProminent)
        .tint(Color.green.opacity(0.5))
    }
}

#Preview {
    RootView {
        HomeView()
    }
}

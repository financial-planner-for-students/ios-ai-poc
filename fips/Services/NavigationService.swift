//
//  NavigationService.swift
//  fips
//
//  Created by Jason Tan on 2025-02-06.
//

import SwiftUI

enum Screen: Hashable {
    case chat
    case receipt
    
    init?(url: URL) {
        switch url.absoluteString {
        case "fips://chat":
            self = .chat
        case "fips://receipt":
            self = .receipt
        default:
            return nil
        }
    }
    
    @ViewBuilder // Macro to construct views from closures
    var destination: some View { // closure in question
        switch self {
        case .chat:
            LoadBotView()
        case .receipt:
            ReceiptCaptureView()
        }
    }
}


final class Navigation: ObservableObject {
    @Published var path = NavigationPath()
    
    func handleDeepLink(url: URL) {
        guard let screen = Screen(url: url) else { return }
        path.append(screen)
    }
}

extension EnvironmentValues {
    private struct NavigationKey: EnvironmentKey {
        static let defaultValue = Navigation()
    }
    
    var navigation: Navigation {
        get { self[NavigationKey.self] }
        set { self[NavigationKey.self] = newValue }
    }
}

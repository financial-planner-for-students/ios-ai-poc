//
//  BotService.swift
//  fips
//
//  Created by Jason Tan on 2025-02-07.
//

import SwiftUI

class BotService: ObservableObject {
    @Published private(set) var bot: Bot?
    @Published var loadingProgress: CGFloat = 0
    
    func initializeBot() async {
        await MainActor.run { loadingProgress = 0 }
        let newBot = await Bot { [weak self] progress in
            await MainActor.run {
                self?.loadingProgress = CGFloat(progress)
            }
        }
        await MainActor.run { self.bot = newBot }
    }
}

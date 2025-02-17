//
//  LoadBotView.swift
//  fips
//
//  Created by Jason Tan on 2025-02-06.
//

import SwiftUI

// Modified LoadBotView
struct LoadBotView: View {
    @StateObject private var botService = BotService()
    
    var body: some View {
        if let bot = botService.bot {
            BotView(bot)
        } else {
            ProgressView(value: botService.loadingProgress) {
                Text("loading huggingface model...")
            } currentValueLabel: {
                Text(String(format: "%.2f%%", botService.loadingProgress * 100))
            }
            .padding()
            .onAppear {
                Task {
                    await botService.initializeBot()
                }
            }
        }
    }
}

#Preview {
    LoadBotView()
}

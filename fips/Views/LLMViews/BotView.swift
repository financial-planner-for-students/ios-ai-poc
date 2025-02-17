//
//  BotView.swift
//  fips
//
//  Created by Jason Tan on 2025-02-06.
//

import SwiftUI

struct BotView: View {
    @ObservedObject var bot: Bot
    @State var input = ""
    @State private var isLoading = false
    @State private var isBotSpeaking = false
    
    init(_ bot: Bot) { self.bot = bot }
    func respond() {
        let response = input
        Task {
            input = ""
            isLoading = true
            isBotSpeaking = true
            await bot.respond(to: response)
            isLoading = false
            isBotSpeaking = false
        }
    }
    func stop() {
        bot.stop()
        isBotSpeaking = false
        isLoading = false
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if isLoading {
                ProgressView()
            }
            ScrollView { Text(bot.output).monospaced() }
            Spacer()
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8).foregroundStyle(.thinMaterial).frame(height: 40)
                    TextField("Message", text: $input)
                    .padding(8)
                }
                if !isBotSpeaking {
                    Button(action: respond) { Image(systemName: "paperplane.fill") }
                } else {
                    Button(action: stop) { Image(systemName: "xmark") }
                }
            }
        }
        .frame(maxWidth: .infinity).padding()
    }
}

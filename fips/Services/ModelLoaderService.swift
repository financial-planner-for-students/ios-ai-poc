import SwiftUI
import LLM
//
//class Bot: LLM {
//    convenience init() async {
//        let systemPrompt = "You are a sentient AI with emotions."
//        await self.init(from: HuggingFaceModel("TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF", .Q2_K, template: .chatML(systemPrompt)))
//    }
//}
//

extension String: Error {}

class Bot: LLM {
    static var availableModels: [URL] {
        // Check if the user has a model installed on their system and grab that
        do {
            let modelURL = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            print("Model URL = ", modelURL.absoluteString)
            
            let directoryContents = try FileManager.default.contentsOfDirectory(
                at: modelURL,
                includingPropertiesForKeys: nil
            )
            print("directoryContents:", directoryContents.map { $0.absoluteString })
            
            for url in directoryContents {
                print(url.absoluteString)
            }
            
            // get all the models they have downloaded
            let models = directoryContents.filter{ $0.pathExtension == "gguf" }
            if models.count == 0 {
                throw "Empty directory"
            }
            print("Found \(models.count) .gguf files:")
            for file in models {
                print("•", file.lastPathComponent, file.absoluteString)
            }
            return models
        } catch {
            print("Error: ", error)
            return []
        }
    }
    
    static func deleteAllModels() {
        do {
            let modelURL = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            let directoryContents = try FileManager.default.contentsOfDirectory(
                at: modelURL,
                includingPropertiesForKeys: nil
            )
            
            // Delete the models all found within that directory
            directoryContents.filter({ $0.pathExtension == "gguf" }).forEach{ try? FileManager.default.removeItem(at: $0)}
            
        } catch {
            print("Error deleting:", error)
        }
    }
    
    public static func llama(_ systemPrompt: String? = nil) -> Template {
        return Template(
            system: ("<|system|>\n", "{system_message}</s>\n"),
            user: ("<|user|>\n", "{prompt}</s>\n"),
            bot: ("<|assistant|>\n", ""),
            stopSequence: "",
            systemPrompt: systemPrompt
        )
    }
    
    convenience init?(_ update: @escaping @MainActor (Double) async -> Void) async {
        
        // TODO: Bundle app with a small model that way we never need to make this assumption
        // Check if the user has a model installed on their system and grab that
//        Bot.deleteAllModels() // uncomment this line to reset the models on your system
        let llama = Template(
            prefix: "<|begin_of_text|>",
            system: ("<|start_header_id|>system", "<|end_header_id|>"),
            user: ("<|eot_id|><|start_header_id|>user", "<|end_header_id|>"),
            bot: ("<|eot_id|><|start_header_id|>assistant", "<|end_header_id|>"),
            stopSequence: "<|end_of_text|>",
            systemPrompt: "You are a knowledgeable, efficient, and direct AI assistant. Provide concise answers, focusing on the key information needed. Offer suggestions tactfully when appropriate to improve outcomes. Engage in productive collaboration with the user."
        )
        
//        Bot.deleteAllModels()
        if Bot.availableModels.isEmpty {
            // Otherwise, download one from the internet assuming we're on internet
            print("Downloading the default set Model...")
            let model = HuggingFaceModel("bartowski/Llama-3.2-3B-Instruct-GGUF", .Q5_K_M, template: llama) // ONLY GGUF tagged models work
            try? await self.init(from: model, maxTokenCount: 512) { progress in
                Task { @MainActor in
                    await update(progress)
                }
            }

        } else {
            print("Loading the first model found on the system...")
            self.init(from: Bot.availableModels[0], template: llama, maxTokenCount: 512)
        }
    }
}

/**
 Sample usage on how to use the whole Bot above
 */
#if DEBUG
struct ModelLoaderView: View {
    @State private var bot: Bot? = nil
    @State private var progress: CGFloat = 0
    func updateProgress(_ progress: Double) {
        self.progress = CGFloat(progress)
    }
    var body: some View {
        if let bot {
            NavigationStack {
                BotView(bot)
            }
        } else {
            ProgressView(value: progress) {
                Text("loading huggingface model...")
            } currentValueLabel: {
                Text(String(format: "%.2f%%", progress * 100))
            }
            .padding()
            .onAppear() { Task {
                let bot = await Bot(updateProgress) // suppose we're initializing through grabbing model from web, then it'll call the update function here
                await MainActor.run { self.bot = bot } // run on the main thread
            } }
        }
    }
}

#Preview {
//    BotView()
}
#endif

import SwiftUI
import PhotosUI
import VisionKit
import Vision

struct ReceiptCaptureView: View {
    // Services
//    private let textProcessor = TextProcessingService()
    
    // States
    @State private var isScannerPresented = false
    @State private var processedText: String = ""
    
    // 2) Photo picker (iOS 16+ approach)
    @State private var selectedLibraryItems: [PhotosPickerItem] = []
    
    // Storage for scanned images
    @State private var scannedImages: [UIImage] = []
    
    // Storage for library-chosen images
    @State private var libraryImages: [UIImage] = []
    
    @State private var isImageViewerPresented: Bool = false
    @State private var chosenImage: UIImage? = nil
    
    func recognizeText(in image: UIImage, completion: @escaping (String?) -> Void) {
        // Convert UIImage to CGImage (required by Vision).
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        // Create a request handler for the CGImage.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Create the text-recognition request.
        let request = VNRecognizeTextRequest { (request, error) in
            guard error == nil else {
                print("Error during text recognition: \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            // The results will be an array of VNRecognizedTextObservation.
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            
            // Extract the top-candidate string from each observation.
            let recognizedStrings: [String] = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            // Combine all recognized text into a single string
            let fullText = recognizedStrings.joined(separator: "\n")
            print("String got = ", fullText)
            
//            // Process through LLM
//            Task {
//                let processed = await self.textProcessor.processText(fullText)
//                DispatchQueue.main.async {
//                    self.processedText = processed
//                }
//                completion(fullText)
//            }
        }
        
        // Configure the request for speed/accuracy, language, etc. (optional)
//        request.recognitionLevel = .accurate  // or .fast
        // request.usesCPUOnly = false  // set to true if you must avoid GPU processing
        // request.recognitionLanguages = ["en-US"]  // optionally specify languages
        
        do {
            // Perform the text-recognition request.
            try requestHandler.perform([request])
        } catch {
            print("Failed to perform text-recognition request: \(error.localizedDescription)")
            completion(nil)
        }
    }

    
    var body: some View {
            VStack(spacing: 20) {
                
                // SCAN BUTTON
                Button("Scan a Receipt") {
                    isScannerPresented = true
                }
                .buttonStyle(.borderedProminent)
                .sheet(isPresented: $isScannerPresented) {
                    DocumentScannerView(isPresented: $isScannerPresented) { newImages in
                        scannedImages.append(contentsOf: newImages)
                        
                        // Immediately OCR each new image
                        for image in newImages {
                            recognizeText(in: image) { recognizedString in
                                guard let text = recognizedString else { return }
                                // For example, store it, or parse it further:
                                print("Recognized text for a scanned page: \(text)")
                            }
                        }
                    }

                }
                
//                 PHOTO PICKER BUTTON (iOS 16+)
                PhotosPicker(selection: $selectedLibraryItems,
                             maxSelectionCount: nil,
                             matching: .images) {
                    Text("Choose from Library")
                }
                    .buttonStyle(.borderedProminent)
                    .onChange(of: selectedLibraryItems) { newItems in
                        Task {
                            for item in newItems {
                                // Attempt to load a UIImage
                                if let data = try? await item.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    libraryImages.append(uiImage)
                                    recognizeText(in: uiImage) { recognizedString in
                                        guard let text = recognizedString else { return }
                                        // For example, store it, or parse it further:
                                        print("Recognized text for a scanned page: \(text)")
                                    }
                                }
                            }
                        }
                    }
                
                // SCANNED IMAGES THUMBNAILS
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(scannedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: .infinity, height: .infinity)
                                .onTapGesture {
                                    print("Before setting chosenImage - Main thread:", Thread.isMainThread)
                                    DispatchQueue.main.async {
                                        print("Setting chosenImage on main thread")
                                        chosenImage = image
                                        print("chosenImage set to:", chosenImage?.description ?? "nil")
                                        isImageViewerPresented = true
                                        print("isImageViewerPresented set to true")
                                    }
                                }
                                .onChange(of: chosenImage) { newImage in
                                    print("chosenImage changed to:", newImage?.description ?? "nil")
                                }
                                .onChange(of: isImageViewerPresented) { newValue in
                                    print("isImageViewerPresented changed to:", newValue)
                                }
                        }
                    }
                }
                .padding(.horizontal)
                
                // LIBRARY IMAGES THUMBNAILS
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(libraryImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .onTapGesture {
                                        chosenImage = image
                                        isImageViewerPresented = true
                                }
                        }
                    }
                    .fullScreenCover(isPresented: $isImageViewerPresented) {
                        ImageViewer(isPresented: $isImageViewerPresented, image: chosenImage)
                            .id(chosenImage)
                    }
                }
                .padding(.horizontal)
                
                // Loading and error states
//                if isLoading {
//                    ProgressView("Processing receipt...")
//                        .padding()
//                }
//                
//                if let error = errorMessage {
//                    Text(error)
//                        .foregroundColor(.red)
//                        .padding()
//                }
                
                // Display processed text
                if !processedText.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Processed Receipt")
                            .font(.headline)
                        
                        ScrollView {
                            Text(processedText)
                                .font(.system(.body, design: .monospaced))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxHeight: 200)
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Receipt Capture")
    }
}

#Preview {
    RootView {
        ReceiptCaptureView()
    }
}

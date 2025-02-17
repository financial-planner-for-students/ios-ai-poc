import SwiftUI
import VisionKit

/// A SwiftUI wrapper around VNDocumentCameraViewController for scanning documents (e.g. receipts).
struct DocumentScannerView: UIViewControllerRepresentable {
    // We’ll use a binding to control presentation from the outside
    @Binding var isPresented: Bool
    
    /// Called when scanning is complete, passing back the scanned images (pages).
    let onScanComplete: ([UIImage]) -> Void
    
    // MARK: - UIViewControllerRepresentable
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        // No need to update in this scenario.
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: DocumentScannerView
        
        init(parent: DocumentScannerView) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFinishWith scan: VNDocumentCameraScan) {
            var images: [UIImage] = []
            for pageIndex in 0..<scan.pageCount {
                let img = scan.imageOfPage(at: pageIndex)
                images.append(img)
            }
            
            // Call the callback with all scanned images
            parent.onScanComplete(images)
            
            // Dismiss the scanner
            parent.isPresented = false
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.isPresented = false
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFailWithError error: Error) {
            // Handle error if needed
            parent.isPresented = false
        }
    }
}

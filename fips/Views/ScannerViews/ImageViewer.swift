import SwiftUI

struct ImageViewer: View {
    @Binding var isPresented: Bool
    let image: UIImage?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Text("Close")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(10)
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isPresented)
    }
}

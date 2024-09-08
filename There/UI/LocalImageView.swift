import SwiftUI

struct LocalImageView: View {
    let imageURL: URL

    @State private var image: NSImage?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if isLoading {
                ProgressView()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .onAppear(perform: loadImage)
    }

    private func loadImage() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            if let imageData = try? Data(contentsOf: imageURL),
               let loadedImage = NSImage(data: imageData) {
                DispatchQueue.main.async {
                    self.image = loadedImage
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load image"
                    self.isLoading = false
                }
            }
        }
    }
}

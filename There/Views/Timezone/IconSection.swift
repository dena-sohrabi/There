import SwiftUI

struct IconSection: View {
    @Binding var image: NSImage?
    @Binding var countryEmoji: String
    @Binding var showingXAccountInput: Bool
    @Binding var showingTGAccountInput: Bool

    @State private var xHovered = false
    @State private var tgHovered = false

    var body: some View {
        VStack {
            IconView(
                image: $image,
                countryEmoji: $countryEmoji
            )
            .padding(.bottom, 6)
        }
    }
}

struct SocialMediaButton: View {
    let imageName: String
    @Binding var isHovered: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(imageName)
                .resizable()
                .frame(width: 18, height: 18)
                .clipShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isHovered ? 1.1 : 1)
        .shadow(color: isHovered ? .black.opacity(0.2) : .clear, radius: 4, x: 0, y: 4)
        .onHover { hovering in
            withAnimation {
                isHovered = hovering
            }
        }
    }
}

struct SocialMediaInput: View {
    let platform: String
    @Binding var username: String
    @Binding var image: NSImage?
    @Binding var debounceTask: Task<Void, Never>?

    var body: some View {
        VStack(alignment: .leading) {
            StyledLabel(title: "Enter a \(platform) username")
                .padding(.top, 8)
            Input(text: $username, placeholder: "eg. dena_sohrabi")
                .onChange(of: username) { value in
                    debounceTask?.cancel()

                    if !value.isEmpty {
                        debounceTask = Task {
                            try? await Task.sleep(for: .milliseconds(800))

                            if !Task.isCancelled {
                                do {
                                    let imageUrl = "https://unavatar.io/\(platform.lowercased())/\(value.lowercased())"
                                    let fetchedImage = try await simpleImageFetch(from: imageUrl)
                                    await MainActor.run {
                                        self.image = NSImage(data: fetchedImage)
                                    }
                                } catch {
                                    print("Got error \(error)")
                                }
                            }
                        }
                    } else {
                        image = nil
                    }
                }
        }
    }

    func simpleImageFetch(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        image = NSImage(data: data)
        return data
    }
}

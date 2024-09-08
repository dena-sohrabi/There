import SwiftUI

struct IconSection: View {
    @Binding var selectedType: EntryType
    @Binding var image: NSImage?
    @Binding var countryEmoji: String

    @State private var showingXAccountInput = false
    @State private var showingTGAccountInput = false
    @State private var xHovered = false
    @State private var tgHovered = false
    @State private var username = ""
    @State private var debounceTask: Task<Void, Never>?

    var body: some View {
        VStack {
            IconView(
                selectedType: selectedType,
                image: $image,
                countryEmoji: $countryEmoji
            )
            .padding(.top, 6)

            if selectedType == .person {
                HStack {
                    SocialMediaButton(
                        imageName: "twitter",
                        isHovered: $xHovered,
                        action: {
                            withAnimation(.bouncy(duration: 0.1)) {
                                showingTGAccountInput = false
                                showingXAccountInput.toggle()
                            }
                        }
                    )

                    SocialMediaButton(
                        imageName: "telegram-logo",
                        isHovered: $tgHovered,
                        action: {
                            withAnimation(.bouncy(duration: 0.1)) {
                                showingXAccountInput = false
                                showingTGAccountInput.toggle()
                            }
                        }
                    )
                }
            }

            if showingXAccountInput {
                SocialMediaInput(
                    platform: "X",
                    username: $username,
                    image: $image,
                    debounceTask: $debounceTask
                )
            } else if showingTGAccountInput {
                SocialMediaInput(
                    platform: "Telegram",
                    username: $username,
                    image: $image,
                    debounceTask: $debounceTask
                )
            }
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
        VStack {
            StyledLabel(title: "Enter a \(platform) username")
                .padding(.top, 8)
            Input(text: $username, placeholder: "eg. dena_sohrabi")
                .onChange(of: username) { value in
                    debounceTask?.cancel()

                    if !value.isEmpty {
                        debounceTask = Task {
                            try? await Task.sleep(for: .milliseconds(300))

                            if !Task.isCancelled {
                                do {
                                    let imageUrl = "https://unavatar.io/\(platform.lowercased())/\(value)"
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

        print("HTTP Status Code: \(httpResponse.statusCode)")
        print("Received data size: \(data.count) bytes")
        image = NSImage(data: data)
        return data
    }
}

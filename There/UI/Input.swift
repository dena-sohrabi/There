import SwiftUI

struct AdaptiveColors {
    static let textFieldBackground = Color(.textBackgroundColor)
    static let textFieldBorder = Color.secondary
    static let textColor = Color.primary
}

struct Input: View {
    @Binding var text: String
    var placeholder: String
    @FocusState private var isFocused: Bool

    var body: some View {
        CustomTextInput(text: $text, placeholder: placeholder, isFocused: _isFocused)
            .frame(width: 200, height: 32)
    }
}

struct CompactInput: View {
    @Binding var text: String
    var placeholder: String
    @FocusState private var isFocused: Bool

    var body: some View {
        CustomTextInput(text: $text, placeholder: placeholder, isFocused: _isFocused)
            .frame(height: 32)
            .padding(.bottom)
            .scaledToFill()
    }
}

struct AutocompleteInput: View {
    @Binding var text: String
    let placeholder: String
    let suggestions: [String]
    let onCommit: () -> Void

    @State private var isEditing = false
    @State private var showSuggestions = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading) {
            CustomTextInput(text: $text, placeholder: placeholder, isFocused: _isFocused)
                .frame(height: 32)
                .onChange(of: isFocused) { focused in
                    isEditing = focused
                    showSuggestions = focused && !suggestions.isEmpty
                }
                .onChange(of: text) { _ in
                    showSuggestions = isEditing && !suggestions.isEmpty
                }

            if showSuggestions {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(suggestions.prefix(5), id: \.self) { suggestion in
                            Text(suggestion)
                                .padding(.vertical, 2)
                                .onTapGesture {
                                    text = suggestion
                                    showSuggestions = false
                                    onCommit()
                                }
                        }
                    }
                }
                .frame(maxHeight: 150)
                .background(AdaptiveColors.textFieldBackground)
                .cornerRadius(5)
                .shadow(color: Color.primary.opacity(0.2), radius: 5)
            }
        }
    }
}

struct CustomTextInput: View {
    @Binding var text: String
    var placeholder: String
    @FocusState var isFocused: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(AdaptiveColors.textFieldBackground)

            RoundedRectangle(cornerRadius: 8)
                .stroke(isFocused ? .blue : AdaptiveColors.textFieldBorder.opacity(0.5), lineWidth: 1)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .padding(.horizontal, 6)
                .foregroundColor(AdaptiveColors.textColor)
                .focused($isFocused)
        }
        .onTapGesture {
            isFocused = true
        }
    }
}

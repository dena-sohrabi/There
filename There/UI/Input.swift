// EmailInput.swift

import SwiftUI

struct Input: View {
    @Binding var text: String
    var placeholder: String
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.plain)
            .padding(.horizontal, 6)
            .frame(width: 200, height: 32)
            .background(.white)
            .cornerRadius(8)
            .background(
                RoundedRectangle(
                    cornerRadius: 8,
                    style: .continuous
                )
                .stroke(isFocused ? Color.secondary.opacity(0.4) : Color.secondary.opacity(0.2), style: StrokeStyle(lineWidth: 3))
            )
            .padding(.bottom)
            .focused($isFocused)
    }
}

struct CompactInput: View {
    @Binding var text: String
    var placeholder: String
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.plain)
            .padding(.horizontal, 6)
            .frame(height: 32)
            .background(.white)
            .cornerRadius(8)
            .background(
                RoundedRectangle(
                    cornerRadius: 8,
                    style: .continuous
                )
                .stroke(isFocused ? Color.secondary.opacity(0.4) : Color.secondary.opacity(0.2), style: StrokeStyle(lineWidth: 3))
            )
            .padding(.bottom)
            .focused($isFocused)
            .scaledToFill()
    }
}

import Combine
import SwiftUI

struct AutocompleteInput: View {
    @Binding var text: String
    let placeholder: String
    let suggestions: [String]
    let onCommit: () -> Void

    @State private var isEditing = false
    @State private var showSuggestions = false

    var body: some View {
        VStack(alignment: .leading) {
            TextField(placeholder, text: $text, onEditingChanged: { editing in
                isEditing = editing
                showSuggestions = editing && !suggestions.isEmpty
            }, onCommit: {
                showSuggestions = false
                onCommit()
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
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
                .background(Color(.textBackgroundColor))
                .cornerRadius(5)
                .shadow(radius: 5)
            }
        }
    }
}

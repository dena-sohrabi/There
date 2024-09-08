// InitialView.swift

import SwiftUI

struct InitialView: View {
    @Environment(\.database) var database
    @Environment(\.dismissWindow) var dismissWindow
    @State private var email: String = ""
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 80) {
            LeftPanel()
            RightPanel(email: $email, saveEmail: saveEmail)
        }
        .padding()
    }

    func saveEmail() {
        do {
            try SecureKeychainService.shared.saveEncrypted(email, forKey: "userEmail")
            UserDefaults.standard.setValue(true, forKey: "hasCompletedInitialSetup")
        } catch {
            print("Error saving email: \(error)")
        }
    }
}

#Preview {
    InitialView()
        .frame(width: 600, height: 400)
}

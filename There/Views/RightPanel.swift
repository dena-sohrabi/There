// RightPanel.swift

import SwiftUI

struct RightPanel: View {
    @Binding var email: String
    let saveEmail: () -> Void
    @Environment(\.dismissWindow) var dismissWindow
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Please enter your email")
                .font(.callout)
                .fontWeight(.medium)
                .padding(.bottom, 2)

            Input(text: $email, placeholder: "dena@example.com")

            PrimaryButton(title: "Continue", action: {
                saveEmail()
                appState.presentMenu()
                dismissWindow(id: "init")
            })

            SecondaryButton(title: "Skip", action: {
                UserDefaults.standard.setValue(true, forKey: "hasCompletedInitialSetup")
                appState.presentMenu()
                dismissWindow(id: "init")
            })
        }
    }
}

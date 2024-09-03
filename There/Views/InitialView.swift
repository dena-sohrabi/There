//
//  InitialView.swift
//  There
//
//  Created by Dena Sohrabi on 9/3/24.
//

import CryptoSwift
import Foundation
import KeychainSwift
import SwiftUI

struct InitialView: View {
    @Environment(\.database) var database
    @Environment(\.dismissWindow) var dismissWindow
    @State private var email: String = ""
    @FocusState private var isFocused: Bool
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 80) {
            VStack(alignment: .leading, spacing: 8) {
                Image("Logo")
                Text("Hey There!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                HStack {
                    Text(Date.now, format: .dateTime.timeZone())
                        .padding(4)
                        .background(.green.opacity(0.2))
                        .cornerRadius(8)
                    Text(Date.now, format: .dateTime.hour().minute())
                        .monospaced()
                        .padding(4)
                        .background(.cyan.opacity(0.2))
                        .cornerRadius(8)
                }
                HStack {
                    Text(TimeZone.current.identifier)
                        .monospaced()
                        .padding(4)
                        .background(.yellow.opacity(0.2))
                        .cornerRadius(8)
                    Text(Date.now, format: .dateTime.weekday())
                        .monospaced()
                        .padding(4)
                        .background(.pink.opacity(0.2))
                        .cornerRadius(8)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Please enter your email")
                    .font(.callout)
                    .fontWeight(.medium)
                    .padding(.bottom, 2)

                TextField("dena@example.com", text: $email)
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

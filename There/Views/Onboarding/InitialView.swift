// InitialView.swift

import SwiftUI

struct InitialView: View {
    @Environment(\.database) var database
    @State private var email: String = ""
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 80) {
            LeftPanel()
            RightPanel(email: $email, saveEmail: saveEmail)
        }
        .padding()
    }

    func signupForThere(email: String, completion: @escaping (Bool) -> Void) {
        var hostname: String {
            #if DEBUG
                return "http://localhost:8000"
            #else
                return "https://inline.chat"
            #endif
        }
        let url = URL(string: "\(hostname)/api/there/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let timeZone = TimeZone.current.identifier
        let body: [String: Any] = ["email": email, "timeZone": timeZone]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async {
                completion(success)
            }
        }.resume()
    }

    func saveEmail() {
        signupForThere(email: email) { success in
            if success {
                print("Signup successful")
                UserDefaults.standard.set(email, forKey: "userEmail")
                UserDefaults.standard.set(true, forKey: "hasCompletedInitialSetup")
            } else {
                print("Signup failed")
            }
        }
    }
}

#Preview {
    InitialView()
        .frame(width: 600, height: 400)
}

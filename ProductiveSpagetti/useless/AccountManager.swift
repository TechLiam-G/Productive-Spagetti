//
//  AccountManager.swift
//  ProductiveSpagetti
//
//  Created by Liam Gao on 8/16/26.
//

import Foundation
import AuthenticationServices
import Combine

@MainActor
final class AccountManager: ObservableObject {

    static let shared = AccountManager()

    @Published var isSignedIn = false
    @Published var userID = ""

    private let userIDKey = "appleUserID"

    private init() {
        userID = UserDefaults.standard.string(forKey: userIDKey) ?? ""
        isSignedIn = !userID.isEmpty
    }

    // Call after a successful Sign in with Apple
    func signIn(with credential: ASAuthorizationAppleIDCredential) {
        let id = credential.user

        UserDefaults.standard.set(id, forKey: userIDKey)

        userID = id
        isSignedIn = true

        print("Signed in")
    }

    // Check whether the saved Apple credential is still valid
    func checkCredential() async {

        guard !userID.isEmpty else {
            isSignedIn = false
            return
        }

        let provider = ASAuthorizationAppleIDProvider()

        do {
            let state = try await provider.credentialState(
                forUserID: userID
            )

            switch state {
            case .authorized:
                isSignedIn = true
                print("✅ Apple account still authorized")

            case .revoked, .notFound:
                signOut()
                print("❌ Apple account is no longer authorized")

            case .transferred:
                print("⚠️ App was transferred to another Apple developer team")

            @unknown default:
                signOut()
            }

        } catch {
            print("❌ Could not check Apple credential:", error)
        }
    }

    func signOut() {
        UserDefaults.standard.removeObject(forKey: userIDKey)

        userID = ""
        isSignedIn = false

        print("👋 Signed out")
    }
}

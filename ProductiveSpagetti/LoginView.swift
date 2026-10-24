//
//  LoginView.swift
//  ProductiveSpagetti
//
//  Created by Liam Gao on 8/16/26.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {

    @StateObject private var account = AccountManager.shared

    var body: some View {

        VStack(spacing: 20) {

            if account.isSignedIn {

                Text("Welcome!")
                    .font(.largeTitle.bold())

                Text("You're signed in to Productive Spagetti.")
                    .foregroundStyle(.secondary)

                Text("Apple User ID:")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(account.userID)
                    .font(.caption)
                    .textSelection(.enabled)

                Button("Sign Out") {
                    account.signOut()
                }
                .buttonStyle(.bordered)

            } else {

                Text("Welcome to Productive Spagetti")
                    .font(.largeTitle.bold())

                Text("Sign in to save your progress.")
                    .foregroundStyle(.secondary)

                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in

                        request.requestedScopes = [
                            .fullName,
                            .email
                        ]

                    },
                    onCompletion: { result in

                        switch result {

                        case .success(let authorization):

                            guard let credential =
                                authorization.credential
                                as? ASAuthorizationAppleIDCredential
                            else {
                                return
                            }

                            AccountManager.shared.signIn(
                                with: credential
                            )

                            print("✅ Signed in")
                            print(
                                "Apple user ID:",
                                credential.user
                            )

                        case .failure(let error):

                            print(
                                "❌ Sign in failed:",
                                error
                            )
                        }
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(
                    width: 300,
                    height: 50
                )
            }
        }
        .padding()
        .task {
            await account.checkCredential()
        }
    }
}

#Preview {
    LoginView()
}

//
//  AIProductiveRunManager.swift
//  ProductiveSpagetti
//
//  Created by Liam Gao on 8/18/26.
//

import Foundation
import Combine

struct AIProductiveRunResponse: Codable {
    let blockedApps: [String]
}

@MainActor
final class AIProductiveRunManager: ObservableObject {

    static let shared = AIProductiveRunManager()

    private init() {}

    private let serverURL =
        "https://apispagetti.sytes.net/ai-productive-run"

    func askAI(
        task: String,
        apps: [String]
    ) async throws -> [String] {

        guard let url = URL(string: serverURL) else {
            throw URLError(.badURL)
        }

        let body: [String: Any] = [
            "task": task,
            "apps": apps
        ]

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.httpBody = try JSONSerialization.data(
            withJSONObject: body
        )

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {

            if let serverError = String(
                data: data,
                encoding: .utf8
            ) {
                print("❌ Server error:", serverError)
            }

            throw URLError(.badServerResponse)
        }

        let result = try JSONDecoder().decode(
            AIProductiveRunResponse.self,
            from: data
        )

        return result.blockedApps
    }
}

//
//  NetworkManager.swift
//  ProductiveSpagetti
//
//  Created by Liam Gao on 9/27/26.
//

import Foundation
import Combine

@MainActor
final class NetworkManager: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading = false

    func fetchItems() async {
        guard let url = URL(string: "https://apispagetti.sytes.net/psshop") else {
            return
        }

        isLoading = true

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            items = try JSONDecoder().decode([Item].self, from: data)

            isLoading = false
        } catch {
            print("❌ Error fetching online shop: \(error)")
            isLoading = false
        }
    }
}

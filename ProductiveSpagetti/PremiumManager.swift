import Foundation
import SwiftUI
import Combine
import StoreKit

@MainActor
final class PremiumManager: ObservableObject {

    static let shared = PremiumManager()

    @Published private(set) var isPremium = false
    @Published private(set) var product: Product?

    // This MUST exactly match App Store Connect.
    private let productID = "com.productivespagetti.gold"

    private var updatesTask: Task<Void, Never>?

    private init() {
        // Start listening for transaction updates in the background
        updatesTask = Task {
            for await result in Transaction.updates {
                if case .verified = result {
                    await refreshEntitlements()
                }
            }
        }
    }

    deinit {
        // Because updatesTask is captured on MainActor, we can cancel it safely
        updatesTask?.cancel()
    }
    
    // MARK: - Load Product
    
    func loadProduct() async {
        do {
            if let storefront = await Storefront.current {
                print("🟢 STOREFRONT:", storefront.countryCode)
                print("🟢 STOREFRONT ID:", storefront.id)
            } else {
                print("🔴 NO STOREFRONT")
            }

            let products = try await Product.products(for: [productID])

            print("🟢 Products returned: \(products.count)")

            for product in products {
                print("🟢 ID: \(product.id)")
                print("🟢 Name: \(product.displayName)")
                print("🟢 Price: \(product.displayPrice)")
            }

            product = products.first

            if products.isEmpty {
                print("🔴 NO PRODUCT FOUND")
            }
        } catch {
            print("🔴 STOREKIT ERROR: \(error)")
        }
    }

    // MARK: - Purchase

    func purchasePremium() async {
        guard let product else {
            print("❌ Premium product hasn't loaded")
            return
        }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    isPremium = true
                    await transaction.finish()
                    print("⭐ Premium purchased!")

                case .unverified(_, let error):
                    print("❌ Purchase could not be verified: \(error)")
                }

            case .userCancelled:
                print("Purchase cancelled")

            case .pending:
                print("Purchase is pending")

            @unknown default:
                print("❌ Unknown purchase result")
            }

        } catch {
            print("❌ Purchase failed: \(error)")
        }
    }

    // MARK: - Restore Purchases

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            print("🔄 Purchases restored")
        } catch {
            print("❌ Could not restore purchases: \(error)")
        }
    }

    // MARK: - Check Entitlements

    func refreshEntitlements() async {
        var foundPremium = false

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }

            if transaction.productID == productID {
                foundPremium = true
            }
        }

        isPremium = foundPremium

        print(
            foundPremium
                ? "✅ Premium is unlocked"
                : "ℹ️ Premium is not unlocked"
        )
    }
}

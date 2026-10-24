import SwiftUI
import StoreKit


import Foundation

struct Item: Codable, Identifiable {
    var id: String { name }
    let name: String
    let type: String
    let price: String
    let image: String
}




struct ShopView: View {
    @AppStorage("score") private var score = 0
    @AppStorage("coins") private var coins = 0
    @AppStorage("backgrounds") private var backgrounds = ""
    @AppStorage("pets") private var pets = ""
    @AppStorage("equippedPet") private var equippedPet = ""
    
    @StateObject private var premium = PremiumManager.shared
    @State private var isBuyingPremium = false
    @StateObject private var network = NetworkManager()
    
    private let items = [
        ShopItem(id: "outerspace", name: "Outer Space", subtitle: "A quiet nebula for deep work", icon: "sparkles", price: 10, colors: [.indigo, .purple], typ:"bg"),
        ShopItem(id: "sunset", name: "Golden Hour", subtitle: "A warm sunset focus theme", icon: "sun.max.fill", price: 25, colors: [.orange, .pink], typ:"bg"),
        ShopItem(id: "aurora", name: "Aurora", subtitle: "A cool northern-lights gradient", icon: "wave.3.right", price: 40, colors: [.mint, .indigo], typ:"bg"),
        ShopItem(id: "mini_spag",name: "Mini Spagetti", subtitle: "Let mini spagetti the dog help!", icon: "dog.fill",price:100,colors:[.orange,.red],typ:"pet"),
        ShopItem(id:"rain_code",name:"Rain Code", subtitle: "Feel like a hacker!",icon:"lessthan",price:220,colors:[.white,.white],typ:"bg")
    ]
    private func purchaseOnlineItem(_ item: Item) {
        guard let price = Int(item.price) else {
            return
        }

        if item.type == "bg" {
            guard coins >= price,
                  !ownedBackgrounds.contains(item.name) else {
                return
            }

            coins -= price

            backgrounds += backgrounds.isEmpty
                ? item.name
                : "|\(item.name)"

        } else if item.type == "pet" {
            guard coins >= price,
                  !ownedPets.contains(item.name) else {
                return
            }

            coins -= price

            pets += pets.isEmpty
                ? item.name
                : "|\(item.name)"
        }
    }

    var body: some View {
        NavigationStack{
            ZStack {
                AppBackdrop()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Reward shop").font(.largeTitle.bold())
                            Text("Spend coins on focus-space upgrades.").foregroundStyle(.secondary)
                        }
                        HStack(spacing: 12) {
                            Label("\(coins) coins", systemImage: "circle.hexagongrid.fill").font(.headline).foregroundStyle(.purple)
                            Spacer()
                            Text("Score \(score)").foregroundStyle(.secondary)
                        }
                        .appCard()
                        HStack(spacing: 12) {
                            NavigationLink(destination: CratesShop()) {
                                Label("Open crates", systemImage: "shippingbox.fill").frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            NavigationLink(destination: BackgroundsView()) {
                                Label("My themes", systemImage: "paintpalette.fill").frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            NavigationLink(destination: PetsView()) {
                                Label("My pets", systemImage: "pawprint.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                        HStack{
                            VStack{
                                Text("Online Shop")
                                    .font(.title2.bold())
                                
                                if network.isLoading {
                                    ProgressView("Loading online items...")
                                } else if network.items.isEmpty {
                                    Text("No online items available.")
                                        .foregroundStyle(.secondary)
                                } else {
                                    ForEach(network.items) { item in
                                        HStack(spacing: 16) {
                                            AsyncImage(url: URL(string: item.image)) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            .frame(width: 52, height: 52)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(item.name)
                                                    .font(.headline)
                                                
                                                Text(item.type)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                
                                                Text("\(item.price) coins")
                                                    .font(.caption.weight(.semibold))
                                                    .foregroundStyle(.purple)
                                            }
                                            
                                            Spacer()
                                            Button("Buy") {
                                                purchaseOnlineItem(item)
                                            }
                                            .buttonStyle(.borderedProminent)
                                            .tint(.purple)
                                            .disabled(coins < (Int(item.price) ?? 0))
                                        }
                                        .appCard(cornerRadius: 20)
                                    }
                                }
                            }.padding(10)
                            // end
                            Divider()
                            VStack{
                                Text("Shop Items").font(.title2.bold())
                                ForEach(items) { item in shopItemCard(item) }
                            }
                        }
                        
                        
                        
                        // Premium
                        VStack(alignment: .leading, spacing: 15) {

                            HStack {

                                Image(systemName: "star.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.yellow)

                                VStack(alignment: .leading) {

                                    Text("Spagetti Premium")
                                        .font(.title3.bold())
                                        .foregroundStyle(.primary)

                                    Text("Unlock exclusive cosmetics.")
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()
                            }

                            VStack(alignment: .leading, spacing: 8) {

                                Label(
                                    "LOCK MODE (block the stop and pause buttons)",
                                    systemImage: "lock.fill"
                                )
                                .foregroundStyle(.orange)

                                Label(
                                    "BLOCKER MODE (close blocked apps every 30 seconds)",
                                    systemImage: "nosign"
                                )
                                .foregroundStyle(.red)
                                
                                Label(
                                    "Automatic focus mode",
                                    systemImage: "nosign"
                                )
                                .foregroundStyle(.primary)
                                
                                Label(
                                    "More focus settings",
                                    systemImage: "gear"
                                )
                                .foregroundStyle(.primary)
                                
                            }
                            .font(.subheadline)

                            if premium.isPremium {

                                Label(
                                    "Premium Unlocked",
                                    systemImage: "checkmark.seal.fill"
                                )
                                .foregroundStyle(.green)
                                .font(.headline)

                            } else {

                                Button {

                                    Task {
                                        await premium.purchasePremium()
                                    }

                                } label: {

                                    HStack {

                                        Image(systemName: "cart.fill")

                                        Text(
                                            premium.product?.displayPrice ?? "$0.99"
                                        )

                                        Spacer()

                                        Text("Buy Premium")
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.purple)
                            }

                            // Always show Restore Purchases.
                            Button {

                                Task {
                                    await premium.restorePurchases()
                                }

                            } label: {

                                HStack {
                                    Spacer()

                                    Text("Restore Purchases")
                                        .font(.system(size: 14, weight: .medium))

                                    Spacer()
                                }
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.secondary)
                        }
                        .appCard(cornerRadius: 22)
                    }
                    .padding(28).foregroundStyle(.cyan)
                }
            }
        }
        .task {
            await premium.loadProduct()
            await premium.refreshEntitlements()
            await network.fetchItems()
        }
    }

    private func shopItemCard(_ item: ShopItem) -> some View {
        let isOwned = item.typ == "bg"
            ? ownedBackgrounds.contains(item.id)
            : pets.contains(item.id)
        return HStack(spacing: 16) {
            VStack(spacing: 5) {
                Image(systemName: item.icon)
                    .font(.title2).foregroundStyle(.white).frame(width: 52, height: 52)
                    .background(LinearGradient(colors: item.colors, startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                Text(item.name)
                    .font(.caption2.weight(.bold))
                    .lineLimit(1)
                    .frame(width: 74)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name).font(.headline)
                Text(item.subtitle).font(.caption).foregroundStyle(.secondary)
                Text("\(item.typ == "bg" ? "Focus theme" : "Pet") • \(item.price) coins")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.purple)
            }
            Spacer()
            Button(isOwned ? "Owned" : "\(item.price) coins") { purchase(item) }
                .buttonStyle(.borderedProminent).tint(isOwned ? .secondary : .purple)
                .disabled(isOwned || coins < item.price)
        }
        .appCard(cornerRadius: 20)
    }

    private var ownedBackgrounds: [String] { backgrounds.split(separator: "|").map(String.init) }
    private var ownedPets: [String] {
        pets.split(separator: "|").map(String.init)
    }
    private func purchase(_ item: ShopItem) {

        if item.typ == "bg" {

            guard coins >= item.price,
                  !ownedBackgrounds.contains(item.id) else {
                return
            }

            coins -= item.price

            backgrounds += backgrounds.isEmpty
                ? item.id
                : "|\(item.id)"

        } else if item.typ == "pet" {

            guard coins >= item.price,
                  !ownedPets.contains(item.id) else {
                return
            }

            coins -= item.price

            pets += pets.isEmpty
                ? item.id
                : "|\(item.id)"
        }
    }
}

private struct ShopItem: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let icon: String
    let price: Int
    let colors: [Color]
    let typ: String
}

struct CratesShop: View {
    @AppStorage("score") private var score = 0
    @AppStorage("coins") private var coins = 0
    @AppStorage("nextcratescore") private var nextCrateScore = 100
    @State private var latestReward: Int?

    private var progress: Double {
        let previousMilestone = max(0, nextCrateScore - 100)
        return min(1, max(0, Double(score - previousMilestone) / 100))
    }

    var body: some View {
        ZStack {
            AppBackdrop()
            VStack(spacing: 22) {
                Image(systemName: "shippingbox.fill").font(.system(size: 52)).foregroundStyle(.purple)
                Text("Focus crates").font(.largeTitle.bold())
                Text("Every 100 productivity score unlocks a crate with 10–20 coins.").multilineTextAlignment(.center).foregroundStyle(.secondary)
                VStack(spacing: 10) {
                    HStack { Text("Next crate"); Spacer(); Text("\(score) / \(nextCrateScore)").monospacedDigit().foregroundStyle(.secondary) }
                    ProgressView(value: progress).tint(.purple)
                }
                .appCard()
                if let latestReward { Label("You found \(latestReward) coins!", systemImage: "sparkles").font(.headline).foregroundStyle(.purple) }
                Button {
                    let reward = Int.random(in: 10...20)
                    coins += reward
                    latestReward = reward
                    nextCrateScore += 100
                } label: {
                    Label(score >= nextCrateScore ? "Open crate" : "Keep focusing", systemImage: "gift.fill").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent).tint(.purple).disabled(score < nextCrateScore)
            }
            .frame(maxWidth: 460).padding(30)
        }
    }
}

#Preview { ShopView() }

import SwiftUI

struct PetsView: View {

    @AppStorage("pets") private var pets = ""
    @AppStorage("equippedPet") private var equippedPet = ""

    private let petList = [
        Pet(
            id: "mini_spag",
            name: "Mini Spagetti",
            description: "Your loyal robo dog that cheers you on during focus sessions.",
            icon: "dog.fill",
            colors: [.orange, .red]
        )
    ]

    var body: some View {

        ZStack {

            AppBackdrop()

            ScrollView {

                VStack(alignment: .leading, spacing: 24) {

                    VStack(alignment: .leading, spacing: 4) {

                        Text("My Pets")
                            .font(.largeTitle.bold())

                        Text("Collect adorable companions to join your focus journey.")
                            .foregroundStyle(.secondary)

                    }

                    ForEach(petList) { pet in

                        if ownedPets.contains(pet.id) {

                            petCard(pet)

                        }

                    }

                    if ownedPets.isEmpty {

                        VStack(spacing: 15) {

                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 55))
                                .foregroundStyle(.orange)

                            Text("No Pets Yet")
                                .font(.title2.bold())

                            Text("Visit the shop to adopt your first companion!")
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)

                        }
                        .frame(maxWidth: .infinity)
                        .padding(40)
                        .appCard()

                    }

                }
                .padding(28)

            }

        }

    }

    @ViewBuilder
    private func petCard(_ pet: Pet) -> some View {

        HStack(spacing: 18) {

            ZStack {

                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: pet.colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 85, height: 85)

                Image(systemName: pet.icon)
                    .font(.system(size: 40))
                    .foregroundStyle(.white)

            }

            VStack(alignment: .leading, spacing: 6) {

                Text(pet.name)
                    .font(.title3.bold())

                Text(pet.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if equippedPet == pet.id {

                    Label("Equipped", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption.bold())

                }

            }

            Spacer()

            Button {

                equippedPet = pet.id

            } label: {

                Text(equippedPet == pet.id ? "Equipped" : "Equip")
                    .frame(width: 90)

            }
            .buttonStyle(.borderedProminent)
            .disabled(equippedPet == pet.id)

        }
        .appCard(cornerRadius: 24)

    }

    private var ownedPets: [String] {

        pets
            .split(separator: "|")
            .map(String.init)

    }

}

struct Pet: Identifiable {

    let id: String
    let name: String
    let description: String
    let icon: String
    let colors: [Color]

}

#Preview {
    PetsView()
}

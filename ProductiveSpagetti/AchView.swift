//
//  AchView.swift
//  ProductiveSpagetti
//
//  Created by Liam Gao on 8/6/26.
//

import SwiftUI

struct AchView: View {

    @AppStorage("achievements") private var achievements = ""

    private var unlockedAchievements: [String] {
        achievements
            .split(separator: "|")
            .map(String.init)
    }

    var body: some View {

        ZStack {

            AppBackdrop()

            VStack(spacing: 15) {

                HStack {

                    Text("Achievements")

                    Spacer()

                    Image(systemName: "medal.fill")
                        .foregroundStyle(.yellow)

                }
                .font(.largeTitle.bold())


                if unlockedAchievements.isEmpty {

                    VStack(spacing: 10) {

                        Image(systemName: "medal")
                            .font(.system(size: 50))
                            .foregroundStyle(.gray)

                        Text("No Achievements Yet")
                            .font(.title2.bold())

                        Text("Complete focus runs to unlock achievements!")
                            .foregroundStyle(.secondary)

                    }
                    .appCard()

                } else {

                    ForEach(unlockedAchievements, id: \.self) { item in

                        HStack {

                            Image(systemName: "medal.fill")
                                .foregroundStyle(.yellow)

                            Text(item)
                                .font(.headline)

                            Spacer()

                        }
                        .appCard()

                    }

                }

                Spacer()

            }
            .padding(28)

        }
    }
}

#Preview {
    AchView()
}

//
//  ParentalControls.swift
//  ProductiveSpagetti
//
//  Created by Liam Gao on 8/8/26.
//

import Foundation
import SwiftUI

struct ParentalControls: View {

    @Environment(\.dismiss) private var dismiss

    @AppStorage("score") private var score = 0
    @AppStorage("coins") private var coins = 0
    @AppStorage("rbapasscodereq") private var rbapasscodereq = false

    @State private var addCoinsAmount = ""
    @State private var removeCoinsAmount = ""

    @State private var addScoreAmount = ""
    @State private var removeScoreAmount = ""

    var body: some View {

        ZStack {

            AppBackdrop()

            ScrollView {

                VStack(spacing: 22) {

                    // MARK: - Header

                    HStack {

                        VStack(alignment: .leading, spacing: 4) {

                            Text("Parent Dashboard")
                                .font(.largeTitle.bold())

                            Text("Manage your child's productivity settings.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                        }

                        Spacer()

                        Button {
                            dismiss()
                        } label: {

                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundStyle(.secondary)

                        }
                        .buttonStyle(.plain)
                    }

                    // MARK: - Current Stats

                    HStack(spacing: 14) {

                        VStack(spacing: 8) {

                            Image(systemName: "circle.hexagongrid.fill")
                                .font(.title)
                                .foregroundStyle(.purple)

                            Text("\(coins)")
                                .font(.title.bold())

                            Text("Coins")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white.opacity(0.8))
                        .clipShape(
                            RoundedRectangle(cornerRadius: 18)
                        )

                        VStack(spacing: 8) {

                            Image(systemName: "bolt.circle.fill")
                                .font(.title)
                                .foregroundStyle(.blue)

                            Text("\(score)")
                                .font(.title.bold())

                            Text("Score")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white.opacity(0.8))
                        .clipShape(
                            RoundedRectangle(cornerRadius: 18)
                        )
                    }

                    // MARK: - Coins

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Remove Coins")
                            .font(.headline)

                        HStack {

                            TextField(
                                "Amount",
                                text: $removeCoinsAmount
                            )
                            .textFieldStyle(.roundedBorder)

                            Button {

                                if let amount = Int(removeCoinsAmount),
                                   amount > 0 {

                                    coins = max(0, coins - amount)
                                    removeCoinsAmount = ""
                                }

                            } label: {

                                Image(systemName: "minus.circle.fill")

                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                            .disabled(
                                Int(removeCoinsAmount) == nil ||
                                Int(removeCoinsAmount)! <= 0
                            )
                        }

                    Divider()
                    // MARK: - Score


                        Text("Remove Score")
                            .font(.headline)

                        HStack {

                            TextField(
                                "Amount",
                                text: $removeScoreAmount
                            )
                            .textFieldStyle(.roundedBorder)

                            Button {

                                if let amount = Int(removeScoreAmount),
                                   amount > 0 {

                                    score = max(0, score - amount)
                                    removeScoreAmount = ""
                                }

                            } label: {

                                Image(systemName: "minus.circle.fill")

                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                            .disabled(
                                Int(removeScoreAmount) == nil ||
                                Int(removeScoreAmount)! <= 0
                            )
                        }
                    }
                    .padding(22)
                    .appCard(cornerRadius: 22)
                    /*
                    // MARK: - App Restrictions

                    VStack(alignment: .leading, spacing: 14) {

                        Label(
                            "App Restrictions",
                            systemImage: "lock.app.dashed"
                        )
                        .font(.title2.bold())

                        Divider()

                    }
                    .padding(22)
                    .appCard(cornerRadius: 22)
                     */
                    
                    // MARK: - Parent Info

                    HStack(spacing: 12) {

                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.blue)

                        Text(
                            "These controls change your child's productivity data directly."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)

                        Spacer()
                    }
                    .padding(18)
                    .background(.blue.opacity(0.10))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 18)
                    )
                }
                .padding(24)
            }
        }
    }
}

#Preview {
    ParentalControls()
}


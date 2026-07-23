import SwiftUI

struct AtlasView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.palette) private var p

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Kicker("SINCE 2019 · IST BASE")
                .padding(.top, 10)
                .padding(.bottom, 3)
            ScreenTitle("Atlas")
                .padding(.bottom, 16)
            MapCard()
                .padding(.bottom, 8)
            SectionHeader("The log")
            LogCard()
                .padding(.bottom, 8)
            SectionHeader("Stamps")
            StampsCard()
                .padding(.bottom, 8)
            SectionHeader("Crew — \(model.allFriends.count) friends")
            CrewCard()
        }
    }
}

// MARK: - Map

private struct MapCard: View {
    @Environment(\.palette) private var p

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            WorldMapView()
            Text("Teal — flown · filled square — home · ringed — this week: LHR")
                .font(.hanken(11.5))
                .foregroundStyle(p.secondary)
        }
        .padding(16)
        .card()
    }
}

// MARK: - The log

private struct LogCard: View {
    @Environment(\.palette) private var p

    var body: some View {
        Grid(alignment: .topLeading, horizontalSpacing: 14, verticalSpacing: 16) {
            GridRow {
                stat("20", "countries")
                stat("6", "continents")
            }
            GridRow {
                stat("4,180", "block hours")
                stat("3", "new this year")
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }

    private func stat(_ value: String, _ caption: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.hanken(21, .heavy))
                .monospacedDigit()
            Text(caption)
                .font(.hanken(12))
                .foregroundStyle(p.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Stamps

private struct StampsCard: View {
    @Environment(\.palette) private var p

    var body: some View {
        VStack(spacing: 0) {
            let stamps = AppModel.stamps
            ForEach(stamps.indices, id: \.self) { index in
                let stamp = stamps[index]
                VStack(spacing: 0) {
                    if index > 0 { Hairline() }
                    HStack(spacing: 10) {
                        Text(stamp.title)
                            .font(.hanken(14, .heavy))
                        if stamp.isThisWeek {
                            TagPill(text: "THIS WEEK", foreground: p.accentText, background: p.accentSoft)
                        }
                        Spacer()
                        Text(stamp.detail)
                            .font(.hanken(12))
                            .foregroundStyle(p.secondary)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 6)
                    .frame(minHeight: 46)
                }
            }
        }
        .padding(.vertical, 4)
        .card()
    }
}

// MARK: - Crew network

private struct CrewCard: View {
    @Environment(AppModel.self) private var model
    @Environment(\.palette) private var p

    var body: some View {
        @Bindable var model = model
        VStack(spacing: 0) {
            let friends = model.allFriends
            ForEach(friends.indices, id: \.self) { index in
                VStack(spacing: 0) {
                    if index > 0 { Hairline() }
                    FriendRow(friend: friends[index])
                }
            }

            Hairline()
            HStack(spacing: 8) {
                TextField("Crew ID or name", text: $model.newFriendName)
                    .font(.hanken(13))
                    .submitLabel(.done)
                    .onSubmit { model.addFriend() }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(p.fill, in: Capsule())
                    .overlay(Capsule().strokeBorder(p.hairline, lineWidth: 1))
                    .accessibilityLabel("Add friend")
                Button {
                    model.addFriend()
                } label: {
                    Text("Add")
                        .font(.hanken(13, .heavy))
                        .foregroundStyle(p.onAccent)
                        .padding(.horizontal, 18)
                        .frame(minHeight: 44)
                        .background(p.accent, in: Capsule())
                }
                .buttonStyle(PressScale(0.96))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
        }
        .padding(.vertical, 4)
        .card()
    }
}

private struct FriendRow: View {
    @Environment(AppModel.self) private var model
    @Environment(\.palette) private var p
    let friend: Friend

    var body: some View {
        let expanded = model.expandedFriends.contains(friend.id)
        VStack(spacing: 0) {
            Button {
                model.toggleExpanded(friend.id)
            } label: {
                HStack(spacing: 10) {
                    Text(friend.initials)
                        .font(.hanken(12, .heavy))
                        .foregroundStyle(p.accentText)
                        .frame(width: 36, height: 36)
                        .background(p.fill, in: Circle())
                    VStack(alignment: .leading, spacing: 0) {
                        Text(friend.name)
                            .font(.hanken(14, .bold))
                        Text(friend.role)
                            .font(.hanken(11.5))
                            .foregroundStyle(p.secondary)
                    }
                    Spacer(minLength: 8)
                    Text(friend.citiesLabel)
                        .font(.hanken(12, .bold))
                        .foregroundStyle(p.secondary)
                    Text(expanded ? "▴" : "▾")
                        .font(.hanken(11))
                        .foregroundStyle(p.tertiary)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 6)
                .frame(minHeight: 56)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if expanded {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 6) {
                        ForEach(friend.chips, id: \.self) { chip in
                            Text(chip)
                                .font(.hanken(10.5, .heavy))
                                .tracking(0.42)
                                .foregroundStyle(p.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(p.fill, in: Capsule())
                        }
                    }
                    Text("Mutual with you: \(friend.mutual) cities")
                        .font(.hanken(12))
                        .foregroundStyle(p.secondary)
                        .padding(.vertical, 10)
                    AskTipsButton(friendID: friend.id)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 0, leading: 18, bottom: 14, trailing: 18))
            }
        }
    }
}

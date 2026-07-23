import SwiftUI

struct CityView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.palette) private var p

    var body: some View {
        @Bindable var model = model
        VStack(alignment: .leading, spacing: 0) {
            Kicker("NEW YORK · LOCAL \(model.nycClock) · 27°")
                .padding(.top, 10)
                .padding(.bottom, 3)
            ScreenTitle("City")
                .padding(.bottom, 16)
            CrewIntelCard()
                .padding(.bottom, 14)
            SegmentedPill(options: CityFilter.allCases.map { ($0, $0.rawValue) },
                          selection: $model.cityFilter)
                .padding(.bottom, 14)
            if model.cityFilter == .shop {
                QuickConvertCard()
                    .padding(.bottom, 14)
            }
            VenueListCard()
        }
    }
}

// MARK: - Crew intel

private struct CrewIntelCard: View {
    @Environment(AppModel.self) private var model
    @Environment(\.palette) private var p

    var body: some View {
        VStack(spacing: 0) {
            (Text("\(model.nycFriends.count) friends")
                .foregroundStyle(p.accentText)
            + Text(" know New York — ask before you go"))
                .font(.hanken(13, .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 12, leading: 18, bottom: 4, trailing: 18))

            let friends = model.nycFriends
            ForEach(friends.indices, id: \.self) { index in
                let friend = friends[index]
                VStack(spacing: 0) {
                    if index > 0 { Hairline() }
                    HStack(spacing: 10) {
                        Text(friend.initials)
                            .font(.hanken(12, .heavy))
                            .foregroundStyle(p.accentText)
                            .frame(width: 36, height: 36)
                            .background(p.fill, in: Circle())
                        VStack(alignment: .leading, spacing: 0) {
                            Text(friend.name)
                                .font(.hanken(14, .bold))
                            Text("JFK ×\(friend.nycCount) · \(friend.role)")
                                .font(.hanken(11.5))
                                .foregroundStyle(p.secondary)
                        }
                        Spacer(minLength: 8)
                        AskTipsButton(friendID: friend.id)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 6)
                    .frame(minHeight: 54)
                }
            }
        }
        .padding(.vertical, 4)
        .card()
    }
}

// MARK: - Quick convert (Shop filter only)

private struct QuickConvertCard: View {
    @Environment(AppModel.self) private var model
    @Environment(\.palette) private var p

    var body: some View {
        @Bindable var model = model
        VStack(alignment: .leading, spacing: 0) {
            (Text("Quick convert ")
                .font(.hanken(13, .bold))
            + Text("· mid-market, $1 = ₺43.62")
                .font(.hanken(13, .semibold))
                .foregroundStyle(p.secondary))
                .padding(.bottom, 10)

            HStack(spacing: 10) {
                TextField("Amount", text: $model.fxAmount)
                    .keyboardType(.decimalPad)
                    .font(.hanken(16, .bold))
                    .monospacedDigit()
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(p.fill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(p.hairline, lineWidth: 1))
                    .accessibilityLabel("Amount")
                SegmentedPill(options: [(Currency.USD, "USD"), (Currency.EUR, "EUR"), (Currency.TRY, "TRY")],
                              selection: $model.fxFrom)
                    .frame(width: 180)
            }
            .padding(.bottom, 8)

            let rows = model.fxRows
            ForEach(rows.indices, id: \.self) { index in
                let row = rows[index]
                VStack(spacing: 0) {
                    if index > 0 { Hairline() }
                    HStack {
                        Text(row.currency.rawValue)
                            .font(.hanken(11.5, .heavy))
                            .tracking(0.46)
                            .foregroundStyle(p.secondary)
                            .frame(width: 52, alignment: .leading)
                        Spacer()
                        Text(row.value)
                            .font(.hanken(19, .heavy))
                            .monospacedDigit()
                    }
                    .padding(.vertical, 4)
                    .frame(minHeight: 44)
                }
            }
        }
        .padding(EdgeInsets(top: 16, leading: 18, bottom: 6, trailing: 18))
        .card()
    }
}

// MARK: - Venue list

private struct VenueListCard: View {
    @Environment(AppModel.self) private var model
    @Environment(\.palette) private var p

    var body: some View {
        let venues = model.filteredVenues
        VStack(spacing: 0) {
            ForEach(venues.indices, id: \.self) { index in
                let venue = venues[index]
                VStack(spacing: 0) {
                    if index > 0 { Hairline() }
                    VenueRow(venue: venue)
                }
                .fadeInRise(delay: Double(index) * 0.018)
                // Fresh identity per filter so rows re-run their staggered entrance.
                .id("\(model.cityFilter.rawValue)-\(venue.id)")
            }
        }
        .padding(.vertical, 4)
        .card()
    }
}

private struct VenueRow: View {
    @Environment(\.palette) private var p
    let venue: Venue

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(venue.name)
                    .font(.hanken(15, .heavy))
                    .tracking(-0.15)
                    .layoutPriority(1)
                if venue.isCrewFav {
                    TagPill(text: "CREW FAV", foreground: p.accentText, background: p.accentSoft)
                }
                if let tag = venue.tag {
                    TagPill(text: tag.uppercased(), foreground: p.secondary, background: p.fill)
                }
                Spacer(minLength: 8)
                Text(venue.price)
                    .font(.hanken(12.5, .bold))
                    .foregroundStyle(p.secondary)
            }
            Text(venue.blurb)
                .font(.hanken(13))
                .foregroundStyle(p.secondary)
                .lineSpacing(2)
            Text(venue.distance)
                .font(.hanken(11.5))
                .foregroundStyle(p.tertiary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

import SwiftUI
import UniformTypeIdentifiers

struct RosterView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Kicker("PERIOD 01 AUG – 01 SEP · 115011")
                .padding(.top, 10)
                .padding(.bottom, 3)
            ScreenTitle("Roster")
                .padding(.bottom, 16)
            RosterHeaderCard()
                .padding(.bottom, 14)
            CalendarCard()
                .padding(.bottom, 14)
            DayDetailCard()
        }
    }
}

// MARK: - Header

private struct RosterHeaderCard: View {
    @Environment(AppModel.self) private var model
    @Environment(\.palette) private var p
    @State private var showingImporter = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("August 2026")
                        .font(.hanken(19, .heavy))
                    Text("D. Silanoglu · Cabin / Y")
                        .font(.hanken(12))
                        .foregroundStyle(p.secondary)
                }
                Spacer(minLength: 8)
                TagPill(text: "LANDING CARD → 26 SEP", foreground: p.amber, background: p.amberSoft)
            }

            Text("\(model.rosterStatsString) · block 81:50")
                .font(.hanken(12.5, .semibold))
                .foregroundStyle(p.secondary)
                .monospacedDigit()
                .padding(.top, 4)

            HStack {
                Text("Block hours, rolling year")
                Spacer()
                Text("494:00 / 900:00")
                    .monospacedDigit()
            }
            .font(.hanken(11))
            .foregroundStyle(p.secondary)
            .padding(.top, 12)
            .padding(.bottom, 4)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(p.fill)
                    Capsule()
                        .fill(p.accent)
                        .frame(width: geo.size.width * 0.55)
                }
            }
            .frame(height: 6)

            // The handoff notes production behavior parses the airline's roster PDF;
            // this prototype only loads the bundled sample data, so the picker here is decorative.
            Button {
                showingImporter = true
            } label: {
                Text("Update roster PDF →")
                    .font(.hanken(12, .heavy))
                    .foregroundStyle(p.accentText)
            }
            .buttonStyle(.plain)
            .frame(minHeight: 44, alignment: .leading)
            .padding(.top, 10)
            .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.pdf]) { _ in }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .card()
    }
}

// MARK: - Calendar

private struct CalendarCard: View {
    @Environment(AppModel.self) private var model
    @Environment(\.palette) private var p

    private static let weekdayLabels = ["MO", "TU", "WE", "TH", "FR", "SA", "SU"]
    private static let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    var body: some View {
        VStack(spacing: 0) {
            LazyVGrid(columns: Self.columns, spacing: 2) {
                ForEach(Self.weekdayLabels, id: \.self) { label in
                    Text(label)
                        .font(.hanken(10, .heavy))
                        .tracking(0.5)
                        .foregroundStyle(p.tertiary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 6)

            LazyVGrid(columns: Self.columns, spacing: 2) {
                ForEach(Array(model.rosterCalendarCells.enumerated()), id: \.offset) { _, cell in
                    switch cell {
                    case .blank:
                        Color.clear.frame(minHeight: 52)
                    case .day(let day):
                        DayCell(day: day)
                    }
                }
            }

            HStack(spacing: 14) {
                legend(color: p.accent, filled: true, label: "Duty")
                legend(color: p.accent, filled: false, label: "Standby")
                legend(color: p.amber, filled: true, label: "Leave")
                legend(color: p.fill, filled: true, label: "Off", bordered: true)
            }
            .padding(.top, 12)
            .padding(.horizontal, 6)
        }
        .padding(EdgeInsets(top: 14, leading: 12, bottom: 14, trailing: 12))
        .card()
    }

    private func legend(color: Color, filled: Bool, label: String, bordered: Bool = false) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(filled ? color : Color.clear)
                .overlay(Circle().strokeBorder(bordered ? p.hairline : color, lineWidth: filled ? 0 : 1.5))
                .frame(width: 6, height: 6)
            Text(label)
                .font(.hanken(10.5))
                .foregroundStyle(p.secondary)
        }
    }
}

private struct DayCell: View {
    @Environment(AppModel.self) private var model
    @Environment(\.palette) private var p
    let day: Int

    private var info: RosterDay { AppModel.rosterDays[day] ?? RosterDay(type: .off) }
    private var selected: Bool { model.selectedRosterDay == day }

    var body: some View {
        Button {
            model.selectedRosterDay = day
        } label: {
            VStack(spacing: 2) {
                Text("\(day)")
                    .font(.hanken(13, .bold))
                    .monospacedDigit()
                dot
                Text(info.code ?? "")
                    .font(.hanken(8.5, .heavy))
                    .tracking(0.34)
                    .frame(height: 11)
            }
            .frame(maxWidth: .infinity, minHeight: 52)
            .foregroundStyle(info.type == .off && !selected ? p.secondary : p.ink)
            .background(selected ? p.accentSoft : .clear, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(selected ? p.accent : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var dot: some View {
        switch info.type {
        case .duty:
            Circle().fill(p.accent).frame(width: 6, height: 6)
        case .standby:
            Circle().strokeBorder(p.accent, lineWidth: 1.5).frame(width: 6, height: 6)
        case .leave:
            Circle().fill(p.amber).frame(width: 6, height: 6)
        case .off:
            Circle().fill(.clear).frame(width: 6, height: 6)
        }
    }
}

// MARK: - Day detail

private struct DayDetailCard: View {
    @Environment(AppModel.self) private var model
    @Environment(\.palette) private var p

    var body: some View {
        let day = model.rosterSelectedDay
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Text("\(model.selectedRosterDay) August")
                    .font(.hanken(15, .heavy))
                typeChip(day.type)
                Spacer()
            }
            Text(day.label ?? day.type.name)
                .font(.hanken(12.5))
                .foregroundStyle(p.secondary)
                .padding(.top, 2)

            if !day.flights.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(day.flights.enumerated()), id: \.offset) { index, flight in
                        VStack(spacing: 0) {
                            if index > 0 { Hairline() }
                            HStack {
                                Text(flight.number)
                                    .font(.hanken(13.5, .heavy))
                                    .monospacedDigit()
                                Spacer()
                                Text(flight.route)
                                    .font(.hanken(13.5))
                                    .foregroundStyle(p.secondary)
                                    .monospacedDigit()
                            }
                            .frame(minHeight: 42)
                        }
                    }
                }
                .padding(.top, 8)
            }

            if let station = day.layoverStation, let hotel = day.layoverHotel {
                HStack(spacing: 8) {
                    Text("Layover \(station) · \(hotel)")
                        .font(.hanken(12.5, .bold))
                }
                .foregroundStyle(p.accentText)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(p.accentSoft, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(.top, 10)
            }

            if day.hasMalariaWarning {
                Text("Malaria advisory at EBB — see the health unit before you fly.")
                    .font(.hanken(12.5, .bold))
                    .foregroundStyle(p.amber)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(p.amberSoft, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .card()
    }

    private func typeChip(_ type: RosterDayType) -> some View {
        let colors: (fg: Color, bg: Color) = switch type {
        case .duty: (p.accentText, p.accentSoft)
        case .off: (p.secondary, p.fill)
        case .leave: (p.amber, p.amberSoft)
        case .standby: (p.accentText, p.accentSoft)
        }
        return TagPill(text: type.name.uppercased(), foreground: colors.fg, background: colors.bg)
    }
}

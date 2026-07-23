import SwiftUI

struct TodayView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Kicker("WEDNESDAY 23 JULY · DUTY DAY")
                .padding(.top, 10)
                .padding(.bottom, 3)
            ScreenTitle("Good morning.")
                .padding(.bottom, 16)
            ProfileCard()
                .padding(.bottom, 14)
            FlightCard()
                .padding(.bottom, 14)
            DayRibbonCard()
                .padding(.bottom, 14)
            SectionHeader("The layover")
            LayoverGridCard()
                .padding(.bottom, 14)
            AtlasTeaser()
        }
    }
}

// MARK: - Profile + return card

private struct ProfileCard: View {
    @Environment(AppModel.self) private var model
    @Environment(\.palette) private var p

    var body: some View {
        @Bindable var model = model
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text(model.userInitials)
                    .font(.hanken(13, .heavy))
                    .foregroundStyle(p.accentText)
                    .frame(width: 40, height: 40)
                    .background(p.accentSoft, in: Circle())
                VStack(alignment: .leading, spacing: 0) {
                    Text(model.userName)
                        .font(.hanken(15, .bold))
                    Text(model.roleLine)
                        .font(.hanken(12))
                        .foregroundStyle(p.secondary)
                }
                Spacer(minLength: 8)
                SegmentedPill(options: [(CrewRole.cabin, "Crew"), (CrewRole.pilot, "Pilot")],
                              selection: $model.role)
                    .frame(width: 150)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .frame(minHeight: 52)

            infoRow(label: "Return · AV 205, Thu", value: "LHR 14:15 → IST 20:05")
            infoRow(label: "Return report", value: "12:15 BST")
        }
        .padding(.vertical, 4)
        .card()
    }

    private func infoRow(label: String, value: String) -> some View {
        VStack(spacing: 0) {
            Hairline()
            HStack {
                Text(label)
                    .foregroundStyle(p.secondary)
                Spacer()
                Text(value)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }
            .font(.hanken(13.5))
            .padding(.horizontal, 18)
            .padding(.vertical, 4)
            .frame(minHeight: 46)
        }
    }
}

// MARK: - Flight card

private struct FlightCard: View {
    @Environment(AppModel.self) private var model
    @Environment(\.palette) private var p

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Text("AV 204 · A321neo · Gate B2")
                    .font(.hanken(12.5, .semibold))
                    .foregroundStyle(p.secondary)
                Spacer()
                if model.flightStatus == .onTime {
                    StatusPill(text: "ON TIME", foreground: p.accentText, background: p.accentSoft)
                } else {
                    StatusPill(text: "DELAYED 45 M", foreground: p.amber, background: p.amberSoft)
                }
            }
            .padding(.bottom, 14)

            HStack(spacing: 14) {
                Text("IST")
                    .font(.hanken(30, .heavy))
                    .tracking(-0.6)
                RouteLine()
                Text("LHR")
                    .font(.hanken(30, .heavy))
                    .tracking(-0.6)
            }

            HStack {
                Text("Istanbul")
                Spacer()
                Text("4 h 05 · 2 zones west")
                Spacer()
                Text("London")
            }
            .font(.hanken(12))
            .foregroundStyle(p.secondary)
            .padding(.top, 4)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(model.stdString)
                        .font(.hanken(23, .heavy))
                        .monospacedDigit()
                    Text("departs · GMT+3")
                        .font(.hanken(12))
                        .foregroundStyle(p.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text(model.staString)
                        .font(.hanken(23, .heavy))
                        .monospacedDigit()
                    Text("arrives · BST")
                        .font(.hanken(12))
                        .foregroundStyle(p.secondary)
                }
            }
            .padding(.top, 12)

            if model.flightStatus == .delayed {
                Text("New STD 09:20 — report unchanged.")
                    .font(.hanken(12.5, .semibold))
                    .foregroundStyle(p.amber)
                    .padding(.top, 8)
            }

            Hairline()
                .padding(.horizontal, -18)
                .padding(.vertical, 14)

            HStack(spacing: 10) {
                Text("Report 06:50 · briefing C4")
                    .font(.hanken(12.5, .bold))
                Spacer()
                Text("T–\(model.countdownString)")
                    .font(.hanken(17, .heavy))
                    .monospacedDigit()
            }
            .foregroundStyle(p.accentText)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(p.accentSoft, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .card()
    }
}

private struct RouteLine: View {
    @Environment(\.palette) private var p

    var body: some View {
        ZStack {
            Rectangle()
                .fill(p.hairline)
                .frame(height: 1.5)
            HStack {
                Circle()
                    .fill(p.accent)
                    .frame(width: 8, height: 8)
                Spacer()
                ZStack {
                    Circle().fill(p.card)
                    Circle().strokeBorder(p.accent, lineWidth: 1.5)
                }
                .frame(width: 8, height: 8)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 12)
    }
}

// MARK: - "Your day" ribbon (signature)

private struct DayRibbonCard: View {
    @Environment(AppModel.self) private var model
    @Environment(\.palette) private var p

    private static let labels: [(time: String, label: String)] = [
        ("06:50", "Report"), ("08:35", "Wheels up"), ("12:40", "On blocks"), ("14:40", "Hotel"),
    ]

    var body: some View {
        let progress = CGFloat(model.ribbonProgress)
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Kicker("YOUR DAY")
                Spacer()
                Text("times IST")
                    .font(.hanken(11))
                    .foregroundStyle(p.tertiary)
            }
            .padding(.bottom, 18)

            GeometryReader { geo in
                let width = geo.size.width
                ZStack(alignment: .topLeading) {
                    Capsule()
                        .fill(p.fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 4)
                    Capsule()
                        .fill(p.accent)
                        .frame(width: max(0, width * progress), height: 4)
                        .animation(.linear(duration: 1), value: progress)
                    ForEach(0..<4) { index in
                        let reached = model.ribbonNowMinutes >= AppModel.ribbonNodes[index]
                        ZStack {
                            Circle().fill(reached ? p.accent : p.card)
                            Circle().strokeBorder(reached ? p.accent : p.tertiary, lineWidth: 2)
                        }
                        .frame(width: 11, height: 11)
                        .position(x: width * CGFloat(index) / 3, y: 2)
                        .animation(.easeInOut(duration: 0.3), value: reached)
                    }
                    NowDot()
                        .position(x: width * progress, y: 2)
                        .animation(.linear(duration: 1), value: progress)
                }
            }
            .frame(height: 11)
            .padding(.horizontal, 6)

            GeometryReader { geo in
                let width = geo.size.width
                ZStack(alignment: .topLeading) {
                    nodeLabel(0, alignment: .leading)
                    nodeLabel(1, alignment: .center)
                        .frame(height: 34, alignment: .top)
                        .position(x: width / 3, y: 17)
                    nodeLabel(2, alignment: .center)
                        .frame(height: 34, alignment: .top)
                        .position(x: width * 2 / 3, y: 17)
                    nodeLabel(3, alignment: .trailing)
                        .frame(maxWidth: .infinity, alignment: .topTrailing)
                }
            }
            .frame(height: 34)
            .padding(.top, 10)
            .padding(.horizontal, 6)
        }
        .padding(EdgeInsets(top: 16, leading: 18, bottom: 14, trailing: 18))
        .card()
    }

    private func nodeLabel(_ index: Int, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 0) {
            Text(Self.labels[index].time)
                .font(.hanken(11.5, .heavy))
                .monospacedDigit()
            Text(Self.labels[index].label)
                .font(.hanken(10.5))
                .foregroundStyle(p.secondary)
        }
        .fixedSize()
    }
}

private struct NowDot: View {
    @Environment(\.palette) private var p
    @State private var pulsing = false

    var body: some View {
        ZStack {
            Circle().fill(p.accent)
            Circle().strokeBorder(p.card, lineWidth: 3)
        }
        .frame(width: 14, height: 14)
        .background(
            Circle()
                .fill(p.accent.opacity(0.35))
                .scaleEffect(pulsing ? 2.3 : 1)
                .opacity(pulsing ? 0 : 1)
                .animation(.easeOut(duration: 2.2).repeatForever(autoreverses: false), value: pulsing)
        )
        .onAppear { pulsing = true }
    }
}

// MARK: - Layover stats grid

private struct LayoverGridCard: View {
    @Environment(\.palette) private var p

    var body: some View {
        Grid(alignment: .topLeading, horizontalSpacing: 14, verticalSpacing: 16) {
            GridRow {
                stat("24 h 35 m", "in London")
                stat("Hoxton, Holborn", "shuttle +60 min")
            }
            GridRow {
                stat("≈ $76", "per diem · $74/24 h")
                stat("22° showers", "on arrival")
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
                .font(.hanken(19, .heavy))
                .monospacedDigit()
            Text(caption)
                .font(.hanken(12))
                .foregroundStyle(p.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Atlas teaser

private struct AtlasTeaser: View {
    @Environment(AppModel.self) private var model
    @Environment(\.palette) private var p

    var body: some View {
        Button {
            model.tab = .atlas
        } label: {
            HStack(spacing: 12) {
                Text("Atlas")
                    .font(.hanken(15, .heavy))
                Spacer()
                Text("21 cities · 6 continents")
                    .font(.hanken(12.5))
                    .foregroundStyle(p.secondary)
                Text("→")
                    .font(.hanken(16, .heavy))
                    .foregroundStyle(p.accentText)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(minHeight: 54)
            .card()
            .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(PressScale(0.99))
    }
}

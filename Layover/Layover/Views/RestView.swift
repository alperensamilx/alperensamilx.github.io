import SwiftUI

struct RestView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.palette) private var p

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Kicker("EASA ORO.FTL.235 · SIMPLIFIED")
                .padding(.top, 10)
                .padding(.bottom, 3)
            ScreenTitle("Rest")
                .padding(.bottom, 16)
            FormCard()
            Text("Times in departure-base local · floors 12 h home, 10 h away.")
                .font(.hanken(12))
                .foregroundStyle(p.secondary)
                .padding(.horizontal, 4)
                .padding(.top, 8)
                .padding(.bottom, 20)
            ResultCard()
            fdpFootnote
                .padding(.horizontal, 4)
                .padding(.top, 10)
            SectionHeader("Shift plan — 7 zones west")
            ShiftPlanCard()
                .padding(.bottom, 8)
            Text("Anchor: the New York evening · times EDT.")
                .font(.hanken(12))
                .foregroundStyle(p.secondary)
                .padding(.horizontal, 4)
        }
    }

    private var fdpFootnote: some View {
        (Text("FDP guide — \(model.roleWord). ")
            .font(.hanken(12.5, .heavy))
            .foregroundStyle(p.ink)
        + Text(model.fdpNote)
            .font(.hanken(12.5))
            .foregroundStyle(p.secondary))
            .lineSpacing(3)
    }
}

// MARK: - Duty form

private struct FormCard: View {
    @Environment(AppModel.self) private var model
    @Environment(\.palette) private var p

    var body: some View {
        @Bindable var model = model
        VStack(spacing: 0) {
            timeRow(label: "Duty start", selection: $model.restStart, first: true)
            timeRow(label: "Duty end", selection: $model.restEnd, first: false)
            VStack(spacing: 0) {
                Hairline()
                HStack(spacing: 10) {
                    Text("Rest taken")
                        .font(.hanken(14.5, .semibold))
                    Spacer()
                    SegmentedPill(options: [(RestLocation.home, "Home"), (RestLocation.away, "Away")],
                                  selection: $model.restLocation)
                        .frame(width: 176)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 6)
                .frame(minHeight: 54)
            }
        }
        .padding(.vertical, 4)
        .card()
    }

    private func timeRow(label: String, selection: Binding<Date>, first: Bool) -> some View {
        VStack(spacing: 0) {
            if !first { Hairline() }
            HStack {
                Text(label)
                    .font(.hanken(14.5, .semibold))
                Spacer()
                DatePicker("", selection: selection, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .font(.hanken(15, .semibold))
                    .monospacedDigit()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 6)
            .frame(minHeight: 54)
        }
    }
}

// MARK: - Result

private struct ResultCard: View {
    @Environment(AppModel.self) private var model
    @Environment(\.palette) private var p

    var body: some View {
        VStack(spacing: 0) {
            Kicker("MINIMUM REST")
            Text(model.minRestString)
                .font(.hanken(46, .heavy))
                .tracking(-0.92)
                .monospacedDigit()
                .foregroundStyle(p.accentText)
                .padding(.top, 2)
                .padding(.bottom, 10)
            resultRow(label: "Duty length") {
                Text(model.dutyLengthString)
                    .font(.hanken(13.5, .heavy))
                    .monospacedDigit()
            }
            resultRow(label: "Rest closes") {
                Text(model.restClosesString)
                    .font(.hanken(13.5, .heavy))
                    .monospacedDigit()
                    .foregroundStyle(p.accentText)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .card()
    }

    private func resultRow(label: String, @ViewBuilder value: () -> some View) -> some View {
        VStack(spacing: 0) {
            Hairline()
            HStack {
                Text(label)
                    .font(.hanken(13.5))
                    .foregroundStyle(p.secondary)
                Spacer()
                value()
            }
            .frame(minHeight: 42)
        }
    }
}

// MARK: - Shift plan

private struct ShiftPlanCard: View {
    @Environment(\.palette) private var p

    var body: some View {
        VStack(spacing: 0) {
            let rows = AppModel.shiftRows
            ForEach(rows.indices, id: \.self) { index in
                let row = rows[index]
                VStack(spacing: 0) {
                    if index > 0 { Hairline() }
                    HStack(spacing: 10) {
                        Text(row.time)
                            .font(.hanken(12, .bold))
                            .monospacedDigit()
                            .foregroundStyle(p.secondary)
                            .frame(width: 80, alignment: .leading)
                        Text(row.label)
                            .font(.hanken(13.5))
                        Spacer(minLength: 0)
                        switch row.pill {
                        case .light:
                            StatusPill(text: "LIGHT", foreground: p.amber, background: p.amberSoft)
                        case .dark:
                            StatusPill(text: "DARK", foreground: p.secondary, background: p.fill)
                        case nil:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 2)
                    .frame(minHeight: 46)
                }
            }
        }
        .padding(.vertical, 4)
        .card()
    }
}

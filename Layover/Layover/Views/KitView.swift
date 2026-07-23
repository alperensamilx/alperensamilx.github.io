import SwiftUI

struct KitView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Kicker("26 H AWAY · NYC 26–29°")
                .padding(.top, 10)
                .padding(.bottom, 3)
            ScreenTitle("Kit")
                .padding(.bottom, 16)
            ProgressCard()
                .padding(.bottom, 8)
            ForEach(model.kitGroups) { group in
                SectionHeader(group.name)
                KitGroupCard(group: group)
            }
        }
    }
}

// MARK: - Progress

private struct ProgressCard: View {
    @Environment(AppModel.self) private var model
    @Environment(\.palette) private var p

    var body: some View {
        let fraction = model.kitTotal > 0 ? CGFloat(model.kitDoneCount) / CGFloat(model.kitTotal) : 0
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                (Text("\(model.kitDoneCount)")
                    .font(.hanken(27, .heavy))
                + Text("/\(model.kitTotal)")
                    .font(.hanken(16, .bold))
                    .foregroundStyle(p.secondary))
                    .monospacedDigit()
                Text(model.kitHint)
                    .font(.hanken(12.5, .semibold))
                    .foregroundStyle(p.secondary)
                Spacer()
                Button("Reset") {
                    model.kitDone.removeAll()
                }
                .font(.hanken(13, .heavy))
                .foregroundStyle(p.accentText)
                .buttonStyle(PressScale(0.96))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(p.fill)
                    Capsule()
                        .fill(p.accent)
                        .frame(width: geo.size.width * fraction)
                        .animation(.easeOut(duration: 0.3), value: fraction)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .card()
    }
}

// MARK: - Checklist groups

private struct KitGroupCard: View {
    let group: KitGroup

    var body: some View {
        VStack(spacing: 0) {
            ForEach(group.items.indices, id: \.self) { index in
                VStack(spacing: 0) {
                    if index > 0 { Hairline() }
                    KitRow(item: group.items[index])
                }
            }
        }
        .padding(.vertical, 4)
        .card()
    }
}

private struct KitRow: View {
    @Environment(AppModel.self) private var model
    @Environment(\.palette) private var p
    let item: KitItem

    var body: some View {
        let done = model.kitDone.contains(item.id)
        Button {
            withAnimation(.spring(response: 0.22, dampingFraction: 0.55)) {
                model.toggleKitItem(item.id)
            }
        } label: {
            HStack(spacing: 6) {
                ZStack {
                    if done {
                        Circle()
                            .fill(p.accent)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .heavy))
                                    .foregroundStyle(p.onAccent)
                            )
                            .frame(width: 23, height: 23)
                            .transition(.scale(scale: 0.6).combined(with: .opacity))
                    } else {
                        Circle()
                            .strokeBorder(p.tertiary, lineWidth: 1.5)
                            .frame(width: 23, height: 23)
                    }
                }
                .frame(width: 44, height: 44)
                Text(item.label)
                    .font(.hanken(14, .semibold))
                    .strikethrough(done)
                    .foregroundStyle(done ? p.secondary : p.ink)
                Spacer(minLength: 0)
            }
            .padding(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 16))
            .frame(minHeight: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.label)
        .accessibilityAddTraits(done ? [.isSelected] : [])
    }
}

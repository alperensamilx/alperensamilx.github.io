import SwiftUI

// MARK: - Button press feedback

struct PressScale: ButtonStyle {
    var scale: CGFloat

    init(_ scale: CGFloat = 0.96) {
        self.scale = scale
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Text styles

struct Kicker: View {
    @Environment(\.palette) private var p
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.hanken(11, .bold))
            .tracking(0.88)
            .monospacedDigit()
            .foregroundStyle(p.secondary)
    }
}

struct ScreenTitle: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.hanken(26, .heavy))
            .tracking(-0.52)
    }
}

struct SectionHeader: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.hanken(16.5, .heavy))
            .tracking(-0.165)
            .padding(.top, 24)
            .padding(.bottom, 10)
            .padding(.horizontal, 2)
    }
}

struct Hairline: View {
    @Environment(\.palette) private var p

    var body: some View {
        Rectangle()
            .fill(p.hairline)
            .frame(height: 1)
    }
}

// MARK: - Pills

struct SegmentedPill<T: Hashable>: View {
    @Environment(\.palette) private var p
    let options: [(T, String)]
    @Binding var selection: T

    var body: some View {
        HStack(spacing: 2) {
            ForEach(options.indices, id: \.self) { index in
                let option = options[index]
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selection = option.0
                    }
                } label: {
                    Text(option.1)
                        .font(.hanken(12.5, .bold))
                        .foregroundStyle(selection == option.0 ? p.onAccent : p.secondary)
                        .frame(maxWidth: .infinity, minHeight: 38)
                        .background(selection == option.0 ? p.accent : .clear, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(p.fill, in: Capsule())
    }
}

struct StatusPill: View {
    let text: String
    let foreground: Color
    let background: Color

    var body: some View {
        Text(text)
            .font(.hanken(10.5, .heavy))
            .tracking(0.63)
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(background, in: Capsule())
    }
}

struct TagPill: View {
    let text: String
    let foreground: Color
    let background: Color

    var body: some View {
        Text(text)
            .font(.hanken(10, .heavy))
            .tracking(0.4)
            .foregroundStyle(foreground)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(background, in: Capsule())
    }
}

// MARK: - Ask tips (state shared between City and Atlas)

struct AskTipsButton: View {
    @Environment(AppModel.self) private var model
    @Environment(\.palette) private var p
    let friendID: String

    var body: some View {
        let sent = model.tipsSent.contains(friendID)
        Button {
            model.sendTips(to: friendID)
        } label: {
            Text(sent ? "Sent ✓" : "Ask tips")
                .font(.hanken(12.5, .heavy))
                .foregroundStyle(sent ? p.accentText : p.onAccent)
                .padding(.horizontal, 14)
                .frame(minHeight: 40)
                .background(sent ? p.accentSoft : p.accent, in: Capsule())
        }
        .buttonStyle(PressScale(0.96))
        .disabled(sent)
    }
}

// MARK: - Entrance animation (mirrors the prototype's tabIn keyframes)

struct FadeInRise: ViewModifier {
    var delay: Double = 0
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : 5)
            .onAppear {
                withAnimation(.easeOut(duration: 0.25).delay(delay)) {
                    shown = true
                }
            }
    }
}

extension View {
    func fadeInRise(delay: Double = 0) -> some View {
        modifier(FadeInRise(delay: delay))
    }
}

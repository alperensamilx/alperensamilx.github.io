import SwiftUI
import Combine

struct RootView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.colorScheme) private var systemScheme

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var effectiveTheme: AppTheme {
        model.themeOverride ?? (systemScheme == .dark ? .dark : .light)
    }

    var body: some View {
        let palette = Palette.of(effectiveTheme)
        ZStack {
            palette.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                TopBar(theme: effectiveTheme)
                ZStack(alignment: .bottom) {
                    ScrollView(showsIndicators: false) {
                        tabContent
                            .padding(.horizontal, 20)
                            .padding(.bottom, 120)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fadeInRise()
                            .id(model.tab)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    Dock()
                }
            }
        }
        .foregroundStyle(palette.ink)
        .tint(palette.accent)
        .environment(\.palette, palette)
        .animation(.easeInOut(duration: 0.25), value: effectiveTheme)
        .preferredColorScheme(model.themeOverride.map { $0 == .dark ? ColorScheme.dark : ColorScheme.light })
        .onReceive(timer) { _ in
            model.tick()
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch model.tab {
        case .today: TodayView()
        case .roster: RosterView()
        case .rest: RestView()
        case .city: CityView()
        case .kit: KitView()
        case .atlas: AtlasView()
        }
    }
}

// MARK: - Top bar

private struct TopBar: View {
    @Environment(AppModel.self) private var model
    @Environment(\.palette) private var p
    let theme: AppTheme

    var body: some View {
        HStack(spacing: 10) {
            (Text("Layover") + Text(".").foregroundStyle(p.accent))
                .font(.hanken(17, .heavy))
                .tracking(-0.17)
            Spacer()
            Text("\(model.istClock) IST")
                .font(.hanken(12, .semibold))
                .monospacedDigit()
                .foregroundStyle(p.secondary)
            Button {
                model.themeOverride = theme == .dark ? .light : .dark
            } label: {
                Image(systemName: theme == .light ? "moon" : "sun.max")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(p.ink)
                    .frame(width: 36, height: 36)
                    .background(p.card, in: Circle())
                    .overlay(Circle().strokeBorder(p.hairline, lineWidth: 1))
                    .shadow(color: p.shadow1, radius: 1, y: 1)
                    .shadow(color: p.shadow2, radius: 12, y: 8)
            }
            .buttonStyle(PressScale(0.93))
            .accessibilityLabel("Toggle appearance")
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 8)
    }
}

// MARK: - Dock

private struct Dock: View {
    @Environment(AppModel.self) private var model
    @Environment(\.palette) private var p

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    model.tab = tab
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 17, weight: .medium))
                        Text(tab.rawValue)
                            .font(.hanken(10.5, .bold))
                            .tracking(0.21)
                    }
                    .padding(EdgeInsets(top: 8, leading: 13, bottom: 7, trailing: 13))
                    .foregroundStyle(model.tab == tab ? p.accentText : p.secondary)
                    .background(model.tab == tab ? p.accentSoft : .clear,
                                in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(PressScale(0.94))
                .frame(maxWidth: .infinity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: model.tab)
        .padding(.top, 6)
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
        .background {
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                Rectangle().fill(p.dock)
            }
            .overlay(alignment: .top) { Hairline() }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

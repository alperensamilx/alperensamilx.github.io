import SwiftUI
import Observation

// MARK: - Domain types

enum AppTab: String, CaseIterable {
    case today = "Today"
    case rest = "Rest"
    case city = "City"
    case kit = "Kit"
    case atlas = "Atlas"

    var icon: String {
        switch self {
        case .today: "sun.max"
        case .rest: "moon"
        case .city: "mappin.and.ellipse"
        case .kit: "briefcase"
        case .atlas: "globe"
        }
    }
}

enum CrewRole: String {
    case cabin, pilot
}

enum FlightStatus {
    case onTime, delayed
}

enum RestLocation: String {
    case home, away
}

enum CityFilter: String, CaseIterable {
    case all = "All"
    case eat = "Eat"
    case coffee = "Coffee"
    case see = "See"
    case shop = "Shop"
}

enum Currency: String, CaseIterable {
    case TRY, USD, EUR, GBP

    var symbol: String {
        switch self {
        case .TRY: "₺"
        case .USD: "$"
        case .EUR: "€"
        case .GBP: "£"
        }
    }
}

struct Friend: Identifiable {
    let id: String
    let name: String
    let role: String
    let cities: Int?          // nil for freshly added friends -> "new"
    let nycCount: Int
    let topAirports: [String]
    let mutual: Int

    var initials: String {
        String(name.split(separator: " ").compactMap { $0.first }.prefix(2)).uppercased()
    }
    var citiesLabel: String {
        cities.map { "\($0) cities" } ?? "new"
    }
    var chips: [String] {
        topAirports.isEmpty ? ["no log yet"] : topAirports
    }
}

struct Venue: Identifiable {
    let category: CityFilter
    let name: String
    let isCrewFav: Bool
    let tag: String?
    let price: String
    let distance: String
    let blurb: String

    var id: String { name }
}

struct KitItem: Identifiable {
    let id: String
    let label: String
}

struct KitGroup: Identifiable {
    let id: String
    let name: String
    let items: [KitItem]
}

struct ShiftRow: Identifiable {
    enum Pill { case light, dark }
    let time: String
    let label: String
    let pill: Pill?

    var id: String { time }
}

struct Stamp: Identifiable {
    let title: String
    let isThisWeek: Bool
    let detail: String

    var id: String { title }
}

// MARK: - App model

@Observable
final class AppModel {
    // Navigation & appearance
    var tab: AppTab = .today
    var themeOverride: AppTheme?

    // Scenario
    var role: CrewRole = .cabin
    // Config flag from the handoff: switch to .delayed to preview the amber state.
    var flightStatus: FlightStatus = .onTime

    // Ticker
    var now = Date()
    var countdownSeconds = 5882   // ~T-01:38:02, floors at 0

    // Rest calculator
    var restStart = AppModel.time(hour: 6, minute: 50)
    var restEnd = AppModel.time(hour: 20, minute: 50)
    var restLocation: RestLocation = .away

    // City
    var cityFilter: CityFilter = .all
    var fxAmount = "74"
    var fxFrom: Currency = .USD

    // Kit
    var kitDone: Set<String> = []

    // Crew network
    var addedFriends: [Friend] = []
    var tipsSent: Set<String> = []
    var expandedFriends: Set<String> = []
    var newFriendName = ""

    // MARK: Ticker

    func tick() {
        now = Date()
        if countdownSeconds > 0 {
            countdownSeconds -= 1
        }
    }

    var countdownString: String {
        let t = countdownSeconds
        return String(format: "%02d:%02d:%02d", t / 3600, (t / 60) % 60, t % 60)
    }

    private static func clockFormatter(_ identifier: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: identifier)
        return formatter
    }
    private static let istFormatter = clockFormatter("Europe/Istanbul")
    private static let nycFormatter = clockFormatter("America/New_York")

    var istClock: String { Self.istFormatter.string(from: now) }
    var nycClock: String { Self.nycFormatter.string(from: now) }

    // MARK: Persona

    var userName: String { role == .cabin ? "Berkay Can" : "Ahmet Enes" }
    var userInitials: String { role == .cabin ? "BC" : "AE" }
    var roleLine: String { role == .cabin ? "Cabin crew · Purser" : "Flight crew · First Officer" }
    var roleWord: String { role == .cabin ? "cabin crew" : "flight crew" }

    // MARK: Flight

    var stdString: String { flightStatus == .delayed ? "09:20" : "08:35" }
    var staString: String { flightStatus == .delayed ? "13:05" : "12:20" }

    // MARK: Day ribbon

    // Node minutes IST: 06:50 report, 08:35 wheels up, 19:20 on blocks, 20:50 hotel.
    static let ribbonNodes: [Double] = [410, 515, 1160, 1250]

    var ribbonNowMinutes: Double {
        410 - Double(countdownSeconds) / 60
    }

    // Nodes are evenly spaced on the track; interpolate within the active segment.
    var ribbonProgress: Double {
        let nodes = Self.ribbonNodes
        let nowMin = ribbonNowMinutes
        if nowMin >= nodes[nodes.count - 1] { return 1 }
        guard nowMin > nodes[0] else { return 0 }
        for i in 0..<(nodes.count - 1) where nowMin >= nodes[i] && nowMin < nodes[i + 1] {
            let frac = (nowMin - nodes[i]) / (nodes[i + 1] - nodes[i])
            return (Double(i) + frac) / Double(nodes.count - 1)
        }
        return 0
    }

    // MARK: Rest calculator

    static func time(hour: Int, minute: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }

    static func minutesOfDay(_ date: Date) -> Int {
        let c = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (c.hour ?? 0) * 60 + (c.minute ?? 0)
    }

    static func hhmm(_ minutes: Int) -> String {
        String(format: "%02d:%02d", minutes / 60, minutes % 60)
    }

    var dutyMinutes: Int {
        let start = Self.minutesOfDay(restStart)
        let end = Self.minutesOfDay(restEnd)
        return ((end - start) % 1440 + 1440) % 1440
    }

    var minRestMinutes: Int {
        max(restLocation == .home ? 720 : 600, dutyMinutes)
    }

    var dutyLengthString: String { Self.hhmm(dutyMinutes) }
    var minRestString: String { Self.hhmm(minRestMinutes) }

    var restClosesString: String {
        let absolute = Self.minutesOfDay(restEnd) + minRestMinutes
        return Self.hhmm(absolute % 1440) + (absolute >= 1440 ? " +1d" : "")
    }

    var fdpNote: String {
        role == .cabin
            ? "For cabin crew at a 06:50 report: 14:00 basic, up to 16:00 with in-flight rest. Today’s FDP is 13:30 — inside limits."
            : "For flight crew at a 06:50 report: 13:00 acclimatised, 16:00 augmented with class-2 rest. Today’s FDP is 13:30 — legal augmented only."
    }

    static let shiftRows: [ShiftRow] = [
        ShiftRow(time: "to 10:00", label: "Sunglasses on — hold Istanbul a while", pill: .dark),
        ShiftRow(time: "14:00", label: "Last caffeine of the day", pill: nil),
        ShiftRow(time: "15–19:00", label: "Seek daylight — the bridge walk", pill: .light),
        ShiftRow(time: "20:00", label: "Dinner light; skip the nightcap", pill: nil),
        ShiftRow(time: "21:30", label: "Screens dim, curtains half", pill: nil),
        ShiftRow(time: "22:30", label: "Lights out — 06:30 alarm, 8 h", pill: .dark),
    ]

    // MARK: Currency

    private static let fxRatesToTRY: [Currency: Double] = [.USD: 43.62, .EUR: 47.51, .GBP: 55.30, .TRY: 1]

    private static let fxFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."
        return formatter
    }()

    var fxRows: [(currency: Currency, value: String)] {
        let amount = Double(fxAmount.replacingOccurrences(of: ",", with: ".")) ?? 0
        let fromRate = Self.fxRatesToTRY[fxFrom] ?? 1
        return Currency.allCases.filter { $0 != fxFrom }.map { currency in
            let toRate = Self.fxRatesToTRY[currency] ?? 1
            let converted = amount * fromRate / toRate
            let formatted = Self.fxFormatter.string(from: NSNumber(value: converted)) ?? "0.00"
            return (currency, currency.symbol + formatted)
        }
    }

    // MARK: City guide

    static let venues: [Venue] = [
        Venue(category: .eat, name: "Los Tacos No.1", isCrewFav: true, tag: nil, price: "$",
              distance: "15 min · A/C to 14 St",
              blurb: "Stand-up tacos; the queue is brutal but moves. Adobada, always."),
        Venue(category: .eat, name: "Joe’s Pizza", isCrewFav: false, tag: "late-safe", price: "$",
              distance: "20 min · subway to W 4 St",
              blurb: "The classic slice, bright and fast — open until 4 a.m."),
        Venue(category: .eat, name: "Xi’an Famous Foods", isCrewFav: false, tag: "solo-friendly", price: "$",
              distance: "8 min walk · FiDi",
              blurb: "Hand-pulled noodles in minutes; counter seating, no ceremony."),
        Venue(category: .eat, name: "The Odeon", isCrewFav: false, tag: nil, price: "$$$",
              distance: "12 min walk · Tribeca",
              blurb: "The proper end-of-trip brasserie dinner. Book for 19:00."),
        Venue(category: .coffee, name: "Black Fox Coffee", isCrewFav: true, tag: nil, price: "$$",
              distance: "6 min walk · FiDi",
              blurb: "Serious flat white; quiet corners before 11."),
        Venue(category: .coffee, name: "La Cabra", isCrewFav: false, tag: nil, price: "$$",
              distance: "18 min · 6 to Astor Pl",
              blurb: "Danish roaster; the cardamom bun beats the jet lag."),
        Venue(category: .coffee, name: "Devoción", isCrewFav: false, tag: "worth the trip", price: "$$",
              distance: "30 min · Williamsburg",
              blurb: "Bogotá beans under a greenhouse roof — daylight therapy."),
        Venue(category: .see, name: "Brooklyn Bridge at sunrise", isCrewFav: true, tag: "beats jet lag", price: "Free",
              distance: "10 min walk",
              blurb: "Morning light is the reset. Walk out, coffee after."),
        Venue(category: .see, name: "Staten Island Ferry", isCrewFav: false, tag: nil, price: "Free",
              distance: "12 min walk · Whitehall",
              blurb: "The skyline for nothing — 55 minutes round trip."),
        Venue(category: .see, name: "The High Line", isCrewFav: false, tag: nil, price: "Free",
              distance: "25 min · A/C to 14 St",
              blurb: "Gansevoort to 34th on the old rail bed; go late afternoon."),
        Venue(category: .see, name: "The Met", isCrewFav: false, tag: "needs 4 h", price: "$$",
              distance: "35 min · 4/5 to 86 St",
              blurb: "Only with a clear half-day. One wing, not five."),
        Venue(category: .shop, name: "Century 21", isCrewFav: true, tag: "outlet", price: "$$",
              distance: "5 min walk · Cortlandt St",
              blurb: "Designer outlet steps from the hotel — crew ritual since forever."),
        Venue(category: .shop, name: "Trader Joe’s", isCrewFav: false, tag: "snack haul", price: "$",
              distance: "14 min · Broadway",
              blurb: "The fly-home snack haul: peanut butter cups, everything seasoning."),
        Venue(category: .shop, name: "B&H Photo", isCrewFav: false, tag: "electronics", price: "$$",
              distance: "25 min · 34 St",
              blurb: "Cameras and headphones at prices that beat home. Closed Saturdays."),
        Venue(category: .shop, name: "CVS — 24 h", isCrewFav: false, tag: "late-safe", price: "$",
              distance: "4 min walk",
              blurb: "Midnight pharmacy run: melatonin, plasters, SPF."),
    ]

    var filteredVenues: [Venue] {
        cityFilter == .all ? Self.venues : Self.venues.filter { $0.category == cityFilter }
    }

    // MARK: Kit

    var kitGroups: [KitGroup] {
        [
            KitGroup(id: "documents", name: "Documents", items: [
                KitItem(id: "pass", label: "Passport — check the six months"),
                KitItem(id: "lic", label: role == .cabin ? "Crew ID + attestation" : "Licence + medical"),
                KitItem(id: "esta", label: "KCM / ESTA printout, just in case"),
            ]),
            KitGroup(id: "uniform", name: "Uniform", items: [
                KitItem(id: "press", label: "Shirt pressed, wings on"),
                KitItem(id: "spare", label: role == .cabin ? "Scarf + spare tights" : "Epaulettes + spare shirt"),
            ]),
            KitGroup(id: "layover", name: "Layover — New York, July", items: [
                KitItem(id: "jacket", label: "Light jacket — the AC is serious"),
                KitItem(id: "gym", label: "Gym kit + trainers"),
                KitItem(id: "socks", label: "Compression socks"),
                KitItem(id: "power", label: "Power bank + Type-A adapter"),
                KitItem(id: "sleep", label: "Melatonin + eye mask"),
            ]),
        ]
    }

    var kitTotal: Int {
        kitGroups.reduce(0) { $0 + $1.items.count }
    }

    var kitDoneCount: Int {
        kitGroups.reduce(0) { total, group in
            total + group.items.filter { kitDone.contains($0.id) }.count
        }
    }

    var kitAllDone: Bool {
        kitTotal > 0 && kitDoneCount == kitTotal
    }

    var kitHint: String {
        kitAllDone ? "ready to roll" : "for 26 h away"
    }

    func toggleKitItem(_ id: String) {
        if kitDone.contains(id) {
            kitDone.remove(id)
        } else {
            kitDone.insert(id)
        }
    }

    // MARK: Crew network

    static let baseFriends: [Friend] = [
        Friend(id: "dilara", name: "Dilara S.", role: "Cabin · IST", cities: 44, nycCount: 12,
               topAirports: ["JFK", "NRT", "CPT", "LHR"], mutual: 11),
        Friend(id: "hatice", name: "Hatice D.", role: "FO · IST", cities: 61, nycCount: 23,
               topAirports: ["JFK", "SIN", "GRU", "SYD"], mutual: 14),
        Friend(id: "berkayu", name: "Berkay Can U.", role: "Purser · FRA", cities: 38, nycCount: 0,
               topAirports: ["BKK", "JNB", "ICN"], mutual: 9),
        Friend(id: "ahmetk", name: "Ahmet Enes K.", role: "Cabin · AMS", cities: 27, nycCount: 3,
               topAirports: ["JFK", "YYZ", "MAD"], mutual: 7),
    ]

    var allFriends: [Friend] {
        Self.baseFriends + addedFriends
    }

    var nycFriends: [Friend] {
        allFriends.filter { $0.nycCount > 0 }
    }

    func sendTips(to friendID: String) {
        tipsSent.insert(friendID)
    }

    func toggleExpanded(_ friendID: String) {
        if expandedFriends.contains(friendID) {
            expandedFriends.remove(friendID)
        } else {
            expandedFriends.insert(friendID)
        }
    }

    func addFriend() {
        let name = newFriendName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        addedFriends.append(Friend(id: "friend-\(Date().timeIntervalSince1970)", name: name,
                                   role: "Crew · new", cities: nil, nycCount: 0,
                                   topAirports: [], mutual: 0))
        newFriendName = ""
    }

    // MARK: Atlas stamps

    static let stamps: [Stamp] = [
        Stamp(title: "JFK · New York", isThisWeek: true, detail: "14th"),
        Stamp(title: "NRT · Tokyo", isThisWeek: false, detail: "3rd · May"),
        Stamp(title: "GRU · São Paulo", isThisWeek: false, detail: "1st · April"),
        Stamp(title: "LHR · London", isThisWeek: false, detail: "22nd · March"),
        Stamp(title: "SIN · Singapore", isThisWeek: false, detail: "5th · February"),
    ]
}

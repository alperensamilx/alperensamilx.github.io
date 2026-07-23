import SwiftUI
import Observation

// MARK: - Domain types

enum AppTab: String, CaseIterable {
    case today = "Today"
    case roster = "Roster"
    case rest = "Rest"
    case city = "City"
    case kit = "Kit"
    case atlas = "Atlas"

    var icon: String {
        switch self {
        case .today: "sun.max"
        case .roster: "calendar"
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
    let lhrCount: Int         // times flown to the current layover city (LHR)
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

// MARK: - Roster types

enum RosterDayType {
    case duty, off, leave, standby

    var name: String {
        switch self {
        case .duty: "Duty"
        case .off: "Day off"
        case .leave: "Leave"
        case .standby: "Standby"
        }
    }
}

struct RosterFlight {
    let number: String
    let route: String
}

struct RosterDay {
    let type: RosterDayType
    var code: String?
    var label: String?
    var flights: [RosterFlight] = []
    var layoverStation: String?
    var layoverHotel: String?
    var hasMalariaWarning = false

    init(type: RosterDayType, code: String? = nil, label: String? = nil,
         flights: [RosterFlight] = [], layoverStation: String? = nil,
         layoverHotel: String? = nil, hasMalariaWarning: Bool = false) {
        self.type = type
        self.code = code
        self.label = label
        self.flights = flights
        self.layoverStation = layoverStation
        self.layoverHotel = layoverHotel
        self.hasMalariaWarning = hasMalariaWarning
    }
}

enum CalendarCell {
    case blank
    case day(Int)
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
    var restEnd = AppModel.time(hour: 13, minute: 10)
    var restLocation: RestLocation = .away

    // City
    var cityFilter: CityFilter = .all
    var fxAmount = "60"
    var fxFrom: Currency = .GBP

    // Kit
    var kitDone: Set<String> = []

    // Crew network
    var addedFriends: [Friend] = []
    var tipsSent: Set<String> = []
    var expandedFriends: Set<String> = []
    var newFriendName = ""

    // Roster
    var selectedRosterDay = 8

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
    private static let cityFormatter = clockFormatter("Europe/London")

    var istClock: String { Self.istFormatter.string(from: now) }
    var cityClock: String { Self.cityFormatter.string(from: now) }

    // MARK: Persona

    var userName: String { role == .cabin ? "Berkay Can" : "Ahmet Enes" }
    var userInitials: String { role == .cabin ? "BC" : "AE" }
    var roleLine: String { role == .cabin ? "Cabin crew · Purser" : "Flight crew · First Officer" }
    var roleWord: String { role == .cabin ? "cabin crew" : "flight crew" }

    // MARK: Flight

    var stdString: String { flightStatus == .delayed ? "09:20" : "08:35" }
    var staString: String { flightStatus == .delayed ? "11:25" : "10:40" }

    // MARK: Day ribbon

    // Node minutes IST: 06:50 report, 08:35 wheels up, 12:40 on blocks, 14:40 hotel.
    static let ribbonNodes: [Double] = [410, 515, 760, 880]

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
            ? "For cabin crew at a 06:50 report: 14:00 basic. Today’s FDP is 5:50 — well inside limits."
            : "For flight crew at a 06:50 report: 13:00 acclimatised. Today’s FDP is 5:50 — well inside limits."
    }

    static let shiftRows: [ShiftRow] = [
        ShiftRow(time: "14:30", label: "Last caffeine of the day", pill: nil),
        ShiftRow(time: "17–19:00", label: "Daylight walk — the parks do it", pill: .light),
        ShiftRow(time: "20:30", label: "Dinner light; skip the nightcap", pill: nil),
        ShiftRow(time: "23:00", label: "Lights out — 07:00 alarm, 8 h", pill: .dark),
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
        Venue(category: .eat, name: "Padella", isCrewFav: true, tag: nil, price: "$",
              distance: "14 min · Borough Market",
              blurb: "Fresh pasta, tiny prices; the queue moves. Pici cacio e pepe."),
        Venue(category: .eat, name: "Dishoom", isCrewFav: false, tag: "crew breakfast", price: "$$",
              distance: "9 min walk · Covent Garden",
              blurb: "Bacon naan and house chai — the morning fix."),
        Venue(category: .eat, name: "Flat Iron", isCrewFav: false, tag: "solo-friendly", price: "$$",
              distance: "10 min walk · Covent Garden",
              blurb: "One great steak, no ceremony; free ice cream on the way out."),
        Venue(category: .eat, name: "The Wolseley", isCrewFav: false, tag: nil, price: "$$$",
              distance: "18 min · Piccadilly",
              blurb: "The proper end-of-trip dinner. Book for 19:00."),
        Venue(category: .coffee, name: "Prufrock Coffee", isCrewFav: true, tag: nil, price: "$$",
              distance: "6 min walk · Leather Lane",
              blurb: "Serious flat white; quiet tables before 11."),
        Venue(category: .coffee, name: "Monmouth Coffee", isCrewFav: false, tag: nil, price: "$$",
              distance: "13 min · Covent Garden",
              blurb: "The classic — and beans to fly home with."),
        Venue(category: .coffee, name: "Kaffeine", isCrewFav: false, tag: "worth the trip", price: "$$",
              distance: "22 min · Fitzrovia",
              blurb: "Antipodean precision; the banana bread earns the walk."),
        Venue(category: .see, name: "St James’s Park, golden hour", isCrewFav: true, tag: "beats jet lag", price: "Free",
              distance: "20 min · Westminster",
              blurb: "Evening light over the lake, pelicans included. Walk on to the river."),
        Venue(category: .see, name: "Tate Modern", isCrewFav: false, tag: nil, price: "Free",
              distance: "15 min walk · Bankside",
              blurb: "Vast and free, late on Fri–Sat. The Turbine Hall alone."),
        Venue(category: .see, name: "Borough Market", isCrewFav: false, tag: nil, price: "Free",
              distance: "14 min · London Bridge",
              blurb: "Graze lunch among the stalls; closed Sundays."),
        Venue(category: .see, name: "Sky Garden", isCrewFav: false, tag: "book ahead", price: "Free",
              distance: "18 min · Fenchurch St",
              blurb: "The skyline from level 35 — free, but book the slot online."),
        Venue(category: .shop, name: "Liberty", isCrewFav: true, tag: "icon", price: "$$$",
              distance: "15 min · Soho",
              blurb: "Tudor timbers and print scarves — the souvenir that lasts."),
        Venue(category: .shop, name: "M&S Food Hall", isCrewFav: false, tag: "snack haul", price: "$",
              distance: "4 min walk",
              blurb: "Percy Pigs and shortbread — the fly-home haul."),
        Venue(category: .shop, name: "Daunt Books", isCrewFav: false, tag: "worth the trip", price: "$$",
              distance: "24 min · Marylebone",
              blurb: "Edwardian oak galleries; travel books shelved by country."),
        Venue(category: .shop, name: "Boots — late", isCrewFav: false, tag: "late-safe", price: "$",
              distance: "9 min walk",
              blurb: "Pharmacy run: melatonin, plasters, SPF."),
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
            KitGroup(id: "layover", name: "Layover — London, July", items: [
                KitItem(id: "jacket", label: "Rain shell — it’s London"),
                KitItem(id: "gym", label: "Gym kit + trainers"),
                KitItem(id: "socks", label: "Compression socks"),
                KitItem(id: "power", label: "Power bank + Type-G adapter"),
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
        kitAllDone ? "ready to roll" : "for 24 h away"
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
        Friend(id: "dilara", name: "Dilara S.", role: "Cabin · IST", cities: 44, lhrCount: 22,
               topAirports: ["LHR", "NRT", "CPT", "JFK"], mutual: 11),
        Friend(id: "hatice", name: "Hatice D.", role: "FO · IST", cities: 61, lhrCount: 9,
               topAirports: ["LHR", "SIN", "GRU", "SYD"], mutual: 14),
        Friend(id: "berkayu", name: "Berkay Can U.", role: "Purser · FRA", cities: 38, lhrCount: 5,
               topAirports: ["LHR", "BKK", "JNB"], mutual: 9),
        Friend(id: "ahmetk", name: "Ahmet Enes K.", role: "Cabin · AMS", cities: 27, lhrCount: 0,
               topAirports: ["JFK", "YYZ", "MAD"], mutual: 7),
    ]

    var allFriends: [Friend] {
        Self.baseFriends + addedFriends
    }

    var lhrFriends: [Friend] {
        allFriends.filter { $0.lhrCount > 0 }
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
                                   role: "Crew · new", cities: nil, lhrCount: 0,
                                   topAirports: [], mutual: 0))
        newFriendName = ""
    }

    // MARK: Atlas stamps

    static let stamps: [Stamp] = [
        Stamp(title: "LHR · London", isThisWeek: true, detail: "23rd"),
        Stamp(title: "NRT · Tokyo", isThisWeek: false, detail: "3rd · May"),
        Stamp(title: "GRU · São Paulo", isThisWeek: false, detail: "1st · April"),
        Stamp(title: "JFK · New York", isThisWeek: false, detail: "14th · June"),
        Stamp(title: "SIN · Singapore", isThisWeek: false, detail: "5th · February"),
    ]

    // MARK: Roster

    // Monthly schedule, period 01 Aug – 01 Sep 2026. Keys are day-of-month.
    static let rosterDays: [Int: RosterDay] = [
        1: RosterDay(type: .leave, label: "Annual leave"),
        2: RosterDay(type: .off),
        3: RosterDay(type: .off),
        4: RosterDay(type: .leave, label: "Excuse leave (IMP)"),
        5: RosterDay(type: .standby, label: "Call for roster"),
        6: RosterDay(type: .standby, label: "Call for roster"),
        7: RosterDay(type: .off, label: "Requested day off"),
        8: RosterDay(type: .duty, code: "GOT", label: "Gothenburg turn · duty 9:35", flights: [
            RosterFlight(number: "TK1799", route: "IST 12:25 → GOT 15:50"),
            RosterFlight(number: "TK1800", route: "GOT 16:45 → IST 20:15"),
        ]),
        9: RosterDay(type: .duty, code: "ECN", label: "Pristina turn, night to Ercan", flights: [
            RosterFlight(number: "TK1019", route: "IST 15:55 → PRN 17:35"),
            RosterFlight(number: "TK1020", route: "PRN 18:25 → IST 20:05"),
            RosterFlight(number: "TK964", route: "IST 22:10 → ECN 23:45"),
        ], layoverStation: "ECN", layoverHotel: "Concorde Tower Hotel"),
        10: RosterDay(type: .duty, code: "COV", label: "Ercan return + Coventry turn", flights: [
            RosterFlight(number: "TK979", route: "ECN 13:55 → IST 15:40"),
            RosterFlight(number: "TK2474", route: "IST 17:35 → COV 19:10"),
            RosterFlight(number: "TK2475", route: "COV 19:55 → IST 21:40"),
        ]),
        11: RosterDay(type: .duty, code: "ZAG", label: "Zagreb turn · duty 7:05", flights: [
            RosterFlight(number: "TK1055", route: "IST 15:25 → ZAG 17:35"),
            RosterFlight(number: "TK1056", route: "ZAG 18:30 → IST 20:45"),
        ]),
        12: RosterDay(type: .off),
        13: RosterDay(type: .off),
        14: RosterDay(type: .duty, code: "KGL", label: "Kigali — continues to Entebbe", flights: [
            RosterFlight(number: "TK606", route: "IST 15:45 → KGL 22:50"),
        ], hasMalariaWarning: true),
        15: RosterDay(type: .duty, code: "EBB", label: "Entebbe layover", flights: [
            RosterFlight(number: "TK606", route: "KGL 00:10 → EBB 01:15"),
        ], layoverStation: "EBB", layoverHotel: "Speke Resort & Conference Centre", hasMalariaWarning: true),
        16: RosterDay(type: .duty, code: "IST", label: "Return · duty 8:05", flights: [
            RosterFlight(number: "TK612", route: "EBB 02:10 → IST 09:15"),
        ], hasMalariaWarning: true),
        17: RosterDay(type: .off),
        18: RosterDay(type: .off),
        19: RosterDay(type: .duty, code: "KYA", label: "Konya + Gaziantep, four legs", flights: [
            RosterFlight(number: "TK2036", route: "IST 07:15 → KYA 08:30"),
            RosterFlight(number: "TK2037", route: "KYA 09:15 → IST 10:45"),
            RosterFlight(number: "TK2228", route: "IST 13:10 → GZT 14:50"),
            RosterFlight(number: "TK2229", route: "GZT 15:35 → IST 17:30"),
        ]),
        20: RosterDay(type: .off),
        21: RosterDay(type: .off),
        22: RosterDay(type: .duty, code: "BOG", label: "Bogotá — duty 14:55", flights: [
            RosterFlight(number: "TK801", route: "IST 06:40 → BOG 20:05"),
        ], layoverStation: "BOG", layoverHotel: "Hilton Bogotá Corferias"),
        23: RosterDay(type: .duty, code: "PTY", label: "Bogotá → Panama City", flights: [
            RosterFlight(number: "TK800", route: "BOG 21:35 → PTY 23:25"),
        ], layoverStation: "PTY", layoverHotel: "Sortis Hotel"),
        24: RosterDay(type: .duty, code: "PTY", label: "Panama City layover",
                       layoverStation: "PTY", layoverHotel: "Sortis Hotel"),
        25: RosterDay(type: .duty, code: "IST", label: "Return · duty 13:55", flights: [
            RosterFlight(number: "TK801", route: "PTY 01:10 → IST 14:05"),
        ]),
        26: RosterDay(type: .standby, label: "Airport standby (AG)"),
        27: RosterDay(type: .off),
        28: RosterDay(type: .duty, code: "SKG", label: "Thessaloniki turn", flights: [
            RosterFlight(number: "TK1893", route: "IST 16:00 → SKG 17:25"),
            RosterFlight(number: "TK1894", route: "SKG 18:15 → IST 19:40"),
        ]),
        29: RosterDay(type: .duty, code: "ASB", label: "Ashgabat — lands 02:30", flights: [
            RosterFlight(number: "TK322", route: "IST 17:15 → ASB 20:55"),
        ]),
        30: RosterDay(type: .duty, code: "IST", label: "Return, early hours", flights: [
            RosterFlight(number: "TK323", route: "ASB 22:15 → IST 02:30"),
        ]),
        31: RosterDay(type: .standby, label: "Call for roster"),
    ]

    // August 2026 starts on a Saturday: 5 leading blanks, 6 trailing, 42 cells total.
    var rosterCalendarCells: [CalendarCell] {
        var cells: [CalendarCell] = Array(repeating: .blank, count: 5)
        cells.append(contentsOf: (1...31).map { .day($0) })
        cells.append(contentsOf: Array(repeating: .blank, count: 42 - cells.count))
        return cells
    }

    var rosterSelectedDay: RosterDay {
        Self.rosterDays[selectedRosterDay] ?? RosterDay(type: .off)
    }

    var rosterCounts: (duty: Int, off: Int, standby: Int, leave: Int) {
        var duty = 0, off = 0, standby = 0, leave = 0
        for day in 1...31 {
            switch (Self.rosterDays[day] ?? RosterDay(type: .off)).type {
            case .duty: duty += 1
            case .off: off += 1
            case .standby: standby += 1
            case .leave: leave += 1
            }
        }
        return (duty, off, standby, leave)
    }

    var rosterStatsString: String {
        let c = rosterCounts
        return "\(c.duty) duty · \(c.off) off · \(c.standby) standby · \(c.leave) leave"
    }
}

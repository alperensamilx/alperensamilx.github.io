import SwiftUI
import simd

// MARK: - Map data (from flight-map.js in the design handoff)

enum MapData {
    struct City {
        let code: String
        let lon: Double
        let lat: Double
    }

    static let cities: [City] = [
        City(code: "JFK", lon: -73.78, lat: 40.64),
        City(code: "SFO", lon: -122.38, lat: 37.62),
        City(code: "YYZ", lon: -79.63, lat: 43.68),
        City(code: "LHR", lon: -0.45, lat: 51.47),
        City(code: "CDG", lon: 2.55, lat: 49.01),
        City(code: "AMS", lon: 4.76, lat: 52.31),
        City(code: "FRA", lon: 8.57, lat: 50.03),
        City(code: "MAD", lon: -3.57, lat: 40.49),
        City(code: "FCO", lon: 12.25, lat: 41.80),
        City(code: "ATH", lon: 23.94, lat: 37.94),
        City(code: "VIE", lon: 16.57, lat: 48.11),
        City(code: "ZRH", lon: 8.56, lat: 47.46),
        City(code: "NRT", lon: 140.39, lat: 35.77),
        City(code: "ICN", lon: 126.45, lat: 37.46),
        City(code: "BKK", lon: 100.75, lat: 13.69),
        City(code: "SIN", lon: 103.99, lat: 1.36),
        City(code: "KUL", lon: 101.71, lat: 2.75),
        City(code: "DXB", lon: 55.36, lat: 25.25),
        City(code: "JNB", lon: 28.24, lat: -26.13),
        City(code: "GRU", lon: -46.47, lat: -23.43),
        City(code: "EZE", lon: -58.54, lat: -34.82),
    ]

    // ISO 3166-1 numeric codes of visited countries; Turkey (792) is home.
    static let visited: Set<String> = [
        "840", "124", "826", "250", "528", "276", "724", "380", "300", "040",
        "756", "392", "410", "764", "702", "458", "784", "710", "076", "032",
    ]
    static let homeID = "792"
    static let home = City(code: "IST", lon: 28.98, lat: 41.0)
    static let currentCityCode = "JFK"

    // Great-circle interpolation between two coordinates, in degrees.
    static func greatCircle(from a: City, to b: City, segments: Int = 48) -> [(lon: Double, lat: Double)] {
        func vector(lon: Double, lat: Double) -> SIMD3<Double> {
            let l = lon * .pi / 180
            let f = lat * .pi / 180
            return SIMD3(cos(f) * cos(l), cos(f) * sin(l), sin(f))
        }
        let v1 = vector(lon: a.lon, lat: a.lat)
        let v2 = vector(lon: b.lon, lat: b.lat)
        let angle = acos(max(-1, min(1, simd_dot(v1, v2))))
        guard angle > 1e-6 else {
            return [(a.lon, a.lat), (b.lon, b.lat)]
        }
        return (0...segments).map { step in
            let t = Double(step) / Double(segments)
            let v = simd_normalize(sin((1 - t) * angle) * v1 + sin(t * angle) * v2)
            return (atan2(v.y, v.x) * 180 / .pi, asin(max(-1, min(1, v.z))) * 180 / .pi)
        }
    }
}

// MARK: - Country geometry (bundled, derived from world-atlas countries-110m)

struct CountryShape {
    let id: String
    let rings: [[SIMD2<Double>]]   // lon/lat rings; holes handled by even-odd fill
}

enum WorldGeometry {
    private struct RawCountry: Decodable {
        let i: String
        let p: [[[Double]]]
    }

    static let countries: [CountryShape] = {
        guard let url = Bundle.main.url(forResource: "world-countries", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let raw = try? JSONDecoder().decode([RawCountry].self, from: data) else {
            return []
        }
        return raw.map { country in
            CountryShape(id: country.i, rings: country.p.map { ring in
                ring.compactMap { pair in
                    pair.count >= 2 ? SIMD2(pair[0], pair[1]) : nil
                }
            })
        }
    }()
}

// MARK: - Natural Earth projection (port of d3.geoNaturalEarth1)

enum NaturalEarthProjection {
    static func project(lon: Double, lat: Double) -> (x: Double, y: Double) {
        let l = lon * .pi / 180
        let f = lat * .pi / 180
        let f2 = f * f
        let f4 = f2 * f2
        let x = l * (0.8707 - 0.131979 * f2 + f4 * (-0.013791 + f4 * (0.003971 * f2 - 0.001529 * f4)))
        let y = f * (1.007226 + f2 * (0.015085 + f4 * (-0.044475 + 0.028874 * f2 - 0.005916 * f4)))
        return (x, y)
    }

    // Projected sphere extents: x is widest on the equator, y at the poles.
    static let maxX = Double.pi * 0.8707
    static let maxY = project(lon: 0, lat: 90).y
}

// MARK: - View

struct WorldMapView: View {
    @Environment(\.palette) private var p

    var body: some View {
        Canvas { context, size in
            let scale = min(size.width / (2 * NaturalEarthProjection.maxX),
                            size.height / (2 * NaturalEarthProjection.maxY))

            func point(_ lon: Double, _ lat: Double) -> CGPoint {
                let raw = NaturalEarthProjection.project(lon: lon, lat: lat)
                return CGPoint(x: size.width / 2 + raw.x * scale,
                               y: size.height / 2 - raw.y * scale)
            }

            // Countries
            for country in WorldGeometry.countries {
                var path = Path()
                for ring in country.rings {
                    guard let first = ring.first else { continue }
                    path.move(to: point(first.x, first.y))
                    for vertex in ring.dropFirst() {
                        path.addLine(to: point(vertex.x, vertex.y))
                    }
                    path.closeSubpath()
                }
                let fill: Color = country.id == MapData.homeID ? p.accent
                    : MapData.visited.contains(country.id) ? p.mapVisited
                    : p.mapLand
                context.fill(path, with: .color(fill), style: FillStyle(eoFill: true))
                context.stroke(path, with: .color(p.mapStroke), lineWidth: 0.5)
            }

            // Route arcs: IST -> each city
            for city in MapData.cities {
                let samples = MapData.greatCircle(from: MapData.home, to: city)
                guard let first = samples.first else { continue }
                var path = Path()
                path.move(to: point(first.lon, first.lat))
                for sample in samples.dropFirst() {
                    path.addLine(to: point(sample.lon, sample.lat))
                }
                context.stroke(path, with: .color(p.accent.opacity(0.4)), lineWidth: 0.7)
            }

            // City dots
            for city in MapData.cities {
                let center = point(city.lon, city.lat)
                let dot = CGRect(x: center.x - 1.8, y: center.y - 1.8, width: 3.6, height: 3.6)
                context.fill(Path(ellipseIn: dot), with: .color(p.accentText))
            }

            // Home: filled square with dot-colored border
            let home = point(MapData.home.lon, MapData.home.lat)
            let square = CGRect(x: home.x - 2.4, y: home.y - 2.4, width: 4.8, height: 4.8)
            context.fill(Path(square), with: .color(p.accent))
            context.stroke(Path(square), with: .color(p.accentText), lineWidth: 0.8)

            // Current city: ring
            if let current = MapData.cities.first(where: { $0.code == MapData.currentCityCode }) {
                let center = point(current.lon, current.lat)
                let ring = CGRect(x: center.x - 5, y: center.y - 5, width: 10, height: 10)
                context.stroke(Path(ellipseIn: ring), with: .color(p.accent), lineWidth: 1)
            }
        }
        .aspectRatio(1 / 0.52, contentMode: .fit)
        .accessibilityLabel("World map of destinations flown")
    }
}

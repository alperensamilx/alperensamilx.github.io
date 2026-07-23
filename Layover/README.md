# Layover — Crew Companion App

SwiftUI implementation of the **Layover v6 "Keeper"** design handoff: a mobile companion
app for airline crew. One duty day at a glance — next-flight briefing with a live day
timeline, a monthly roster calendar, an EASA minimum-rest calculator with a jet-lag shift
plan, a curated London layover guide with crew recommendations and a currency converter,
a role-aware packing checklist, and a personal travel atlas.

## Requirements

- Xcode 16 or newer (the project uses the folder-synchronized project format)
- iOS 17.0+ deployment target (uses the `@Observable` macro)

## Running

Open `Layover.xcodeproj`, select an iPhone simulator, and run. Everything is local and
hard-coded — no networking, no accounts.

## Structure

```
Layover/
├── LayoverApp.swift        App entry; registers bundled fonts
├── AppModel.swift          Single @Observable model: state + scenario data
├── Theme.swift             Design tokens (light/dark palettes), typography, card style
├── Components.swift        Pills, kickers, hairlines, press states, entrance animation
├── RootView.swift          Top bar, tab switching, translucent dock
├── Views/                  Today · Roster · Rest · City · Kit · Atlas
├── Map/WorldMapView.swift  Canvas world map (Natural Earth projection, great-circle arcs)
├── Fonts/                  Hanken Grotesk 400/600/700/800 (SIL OFL, see OFL.txt)
└── Resources/
    └── world-countries.json  Country outlines derived from world-atlas countries-110m
```

## Notes

- The in-app sun/moon toggle drives the light/dark palette; it defaults to the system
  appearance until first toggled.
- `AppModel.flightStatus` is the config flag from the handoff: set it to `.delayed` to
  preview the amber "DELAYED 45 M" state (STD 09:20, STA 11:25).
- The Roster tab's "Update roster PDF" link opens a real document picker for fidelity
  with the handoff's hidden file input, but doesn't parse the PDF — production behavior
  (parsing Carmen roster codes) is out of scope; the prototype only loads sample data.
- Fonts are registered at runtime (`CTFontManagerRegisterFontsForURL`), so no Info.plist
  `UIAppFonts` entry is needed; if the TTFs are removed the UI falls back to SF Pro.
- Map geometry comes from [world-atlas](https://github.com/topojson/world-atlas)
  (Natural Earth data, public domain), converted to a compact ring list.

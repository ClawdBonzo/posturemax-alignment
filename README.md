# PostureMax

**Daily posture alignment tracker • Stand taller every day**

A beautiful, private SwiftUI habit tracker built with 100% on-device SwiftData. Track your posture, eliminate back and neck pain, and see your transformation over time — all without a single byte leaving your phone.

## Features

- **Woofz-style onboarding flow** — Splash, name entry, 5-page posture self-assessment quiz, photo upload, routine selection, animated loading screen, and paywall
- **Daily posture logger** — 0–10 posture and pain ratings, 5 alignment trait sliders (neck, shoulders, spine, hips, mobility), 8-item daily checklist, photo capture, and notes
- **Photo journal with timeline slider** — Grid gallery, scrubable timeline, and side-by-side before/after compare mode
- **Progress charts per trait** — Swift Charts with line, area, and point marks across 7 traits and 4 time ranges (7D, 30D, 90D, All)
- **Routine library** — 12 pre-built routines across 6 categories (Desk Setup, Stretches, Strengthening, Mobility, Breathing, Breaks) with built-in step timer
- **Dashboard** — Today's posture score ring, streak badge, stats grid, week-at-a-glance, and rotating daily tips
- **RevenueCat subscriptions** — 3 plans (weekly, monthly, annual) with 3-day free trial highlighted
- **WidgetKit widgets** — Small and medium home screen widgets showing posture score and streak
- **PDF export reports** — Generate and share detailed progress reports with averages and log history
- **100% private** — All data stays on-device via SwiftData with no external databases or servers

## Tech Stack

- Swift 6 + SwiftUI
- SwiftData (100% local & private)
- RevenueCat
- WidgetKit + Swift Charts
- MVVM + @Observable

## Screenshots

| Onboarding | Dashboard | Daily Logger | Progress |
|:---:|:---:|:---:|:---:|
| *placeholder* | *placeholder* | *placeholder* | *placeholder* |

| Photo Journal | Routines | Paywall | Widget |
|:---:|:---:|:---:|:---:|
| *placeholder* | *placeholder* | *placeholder* | *placeholder* |

## Quick Start

1. Open `PostureMax.xcodeproj` in Xcode 16+
2. Set your team and bundle identifier under Signing & Capabilities
3. Add RevenueCat SPM package: `https://github.com/RevenueCat/purchases-ios`
4. Replace `YOUR_REVENUECAT_API_KEY` in `RevenueCatService.swift` with your public key
5. Build & run on iOS 18+ simulator or device

## Project Structure

```
PostureMax/
├── Models/          — SwiftData models (UserProfile, DailyLog, PosturePhoto, RoutineItem, StreakRecord)
├── Views/           — All SwiftUI screens organized by feature
│   ├── Onboarding/  — 7-screen onboarding flow
│   ├── Dashboard/   — Main dashboard with score ring and stats
│   ├── Logger/      — Daily posture and pain logger
│   ├── PhotoJournal/— Photo gallery with compare mode
│   ├── Progress/    — Charts and trait breakdowns
│   ├── Routines/    — Routine library with step timer
│   └── Settings/    — Profile, export, and data management
├── Components/      — Reusable UI (PMButton, ScoreRing, PhotoPicker, StatCard)
├── Extensions/      — Color theme and Date helpers
├── Services/        — Business logic (Streak, Photo, PDF, RevenueCat, Routine data)
└── Resources/       — Asset catalog and Info.plist
```

---

Built as part of a 10-app portfolio targeting $10k+/mo each.

Made with ❤️ by ClawdBonzo

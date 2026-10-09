# SocietyOS · GFG KIIT

One app to run a student chapter: tasks, events with live check-in, funds with a multi-step
approval chain, announcements, meetings, people and recruitment, analytics, and a term handover
that keeps everyone's history.

This build is **frontend complete and backend ready**. All data is local (seeded GFG KIIT demo
data) behind repository interfaces, so Firebase can be plugged in without touching a screen.
See [BACKEND.md](BACKEND.md).

## Two doors

- **Visitors** (anyone not signed in) land on the public home: live and upcoming events with
  registration, a Study tab that features [KIIT Katalog](https://kiitkatalog.gfgkiit.in/), and a
  snake game played on the contribution graph. A **Member login** button sits on every tab.
- **Members** sign in and get the full panel below. Organisers choose per event whether it is
  open to non-members and whether it is solo or for teams (fewest and most members). Team events
  ask the leader for a team name and each teammate's name and email. Guest registrations, with
  full team rosters, show on the event's People tab.

## Run

```bash
flutter pub get
flutter run -d chrome        # or any device
flutter test                 # 37 tests: rules, flows, snake, and a walk of every screen
```

Demo accounts (password `gfg@1234`): President `2105101`,
Technical Head `2205140`, App Dev Lead `2205211`, Member `2305318`, Applicant `2405522`
(all `@kiit.ac.in`). Settings → *Reset demo data* restores the sample state.
Set `kDemoMode = false` in `lib/app/app.dart` for a real release.

## Structure

```
lib/
  app/        app shell, router with auth guards, theme mode
  core/       design system: theme, palette, widgets, formatting
  data/       models, Repository/AuthRepository interfaces, local impl, seed, providers
  domain/     roles and permissions as data, Access, expense rules, check-in codes, actions
  features/   one folder per module (home, tasks, events, funds, people, ...)
test/         unit, flow and full-app smoke tests
firestore.rules   ready for the backend phase
```

Rules live in `lib/domain` (`Access`, `ExpenseRules`, `CheckInCode`). The UI only reflects them.

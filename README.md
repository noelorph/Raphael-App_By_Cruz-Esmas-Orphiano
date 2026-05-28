# Raphael

Raphael is a Flutter wellness app with Firebase-backed authentication, profile
data, reminders, goals, recommendations, chatbot support, and weight/BMI
tracking.

## Project Structure

The app is organized by responsibility so UI files stay focused on presentation
and navigation:

- `lib/main.dart` initializes Firebase and configures the app themes.
- `lib/screens/` contains top-level screens and page flows.
- `lib/widgets/` contains reusable UI pieces shared by screens.
- `lib/models/` contains typed app data and domain enums.
- `lib/services/` contains Firebase access, formatting helpers, validation, and
  other reusable business logic.
- `lib/controllers/` coordinates screen state that is too involved to live
  directly inside widgets.

## Important Conventions

- Keep Firestore/Auth access inside services.
- Keep reusable domain rules, such as BMI categories and measurement validation,
  outside screens so every feature uses the same behavior.
- Put reusable visual pieces in `lib/widgets/` when they are not full screens.
- Prefer small controllers for stateful workflows that combine user input,
  persistence, and derived values.
- Avoid keeping temporary demo screens or large commented blocks in `lib/`.

## Weight And BMI Flow

The weight tracker is split across a few focused files:

- `WeightTrackerScreen` renders the tracker, add-entry sheet, and history sheet.
- `WeightTrackerController` owns text controllers, loading, saving, updating,
  chart points, and latest-entry derivations.
- `WeightTrackerService` reads/writes weight entries and profile body metrics.
- `BmiCategory` centralizes BMI labels, colors, and recommendation copy.
- `MeasurementService` centralizes entry validation and input formatting.
- `DateFormatService` centralizes compact date/time labels.
- `WeightDeltaChart` renders the dashboard mini chart.
- `HistoryMetric` renders the reusable history metric chips.

## Common Commands

```sh
flutter pub get
dart format lib test
flutter analyze
flutter test
```

## Notes For Future Maintenance

This cleanup intentionally preserves app behavior while reducing duplication.
When adding a feature, first check whether an existing service/model/widget
already owns the rule or visual pattern you need. If a screen starts collecting
formatting, Firestore, validation, or custom paint code, move that logic into
the appropriate folder before it spreads.

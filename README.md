# gplx_vn

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Architecture notes

- Bottom navigation uses GoRouter as the source of truth. The `MainNavigationScreen` derives the active tab from the current route and uses a custom bottom bar. Top-level tab routes (`/home`, `/settings`, `/info`) use `NoTransitionPage` to avoid platform page slide animations when switching tabs.
- Avoid magic numbers/strings for tabs and routes. Use `lib/constants/navigation_constants.dart` (`MainNav.tabHome|tabSettings|tabInfo`, `MainNav.routeHome|routeSettings|routeInfo`, `MainNav.tabCount`).
- The previous `mainNavIndexProvider` is removed. Navigation is driven by routes instead of global state.
- Reminder settings are reactive via `reminderSettingsProvider` (`StateNotifierProvider`). Settings updates persist to Hive and update provider state; Home’s `ShortcutGridSection` watches the provider so the UI updates immediately under `IndexedStack`.
- License type still uses a `FutureProvider<String?>` (`licenseTypeProvider`). After changing license type in Settings, call `ref.refresh(licenseTypeProvider)` to propagate updates. Consider migrating it to a notifier if you prefer push-based updates similar to reminder.

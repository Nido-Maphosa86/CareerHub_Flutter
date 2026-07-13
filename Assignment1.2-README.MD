# CareerHub — Assignment 1.3

This version of the app uses live state and reactive filters.

* Filter chips now work
* A loading spinner shows while jobs load
* An error screen with a retry button shows if loading fails
* A message shows when no jobs match a filter

There is:

* No `setState`
* No callbacks passed through widgets

Written decisions were completed on 10 July 2026 before coding.

---

## Setup

Add Riverpod to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
```

Then run:

```bash
flutter pub get
flutter run
flutter test
```

---

## Part 1 — Written decisions

### Question 1 — ref.watch vs ref.read

These two methods work differently.

* `ref.watch`

  * Reads the value
  * Subscribes to updates
  * Rebuilds UI when data changes

* `ref.read`

  * Reads value once
  * Does NOT subscribe

In `build()`:

* You must use `ref.watch`
* Otherwise the UI will not update

Example problem:

* User taps "Remote"
* State changes
* UI does NOT update because nothing is watching

In callbacks (like `onSelected`):

* Use `ref.read`
* Because callbacks are not part of build

If you use `ref.watch` in a callback:

* It creates multiple subscriptions
* Causes repeated rebuilds
* May crash in debug mode

**Rule:**

* Watch when displaying UI
* Read when handling actions

---

### Question 2 — Choosing providers

| Data             | Provider type                     | Reason                        |
| ---------------- | --------------------------------- | ----------------------------- |
| Job list (async) | `FutureProvider<List<Job>>`       | Data loads later and can fail |
| Selected filter  | `StateProvider<String>`           | Simple value updated on tap   |
| Filtered jobs    | `Provider<AsyncValue<List<Job>>>` | Derived from other providers  |

Why NOT store filtered jobs?

If you store it:

* You create duplicate data
* It can go out of sync

Example:

* User selects "Remote"
* Filter updates correctly
* Jobs reload later
* Filtered list does NOT update

Now UI shows old data → bug

Solution:

* Always derive filtered list
* Never store it separately

---

### Question 3 — AsyncValue UI states

There are 3 main states:

1. **Loading**

   * Show spinner (`CircularProgressIndicator`)
   * Lets user know work is happening

2. **Error**

   * Show icon + message + retry button
   * Helps user recover

3. **Data**

   * Show job list/grid

Extra case:

4. **Empty list**

   * Happens when filter finds no jobs
   * If not handled → blank screen

Solution:

* Check `jobs.isEmpty`
* Show `_EmptyView` with message

---

### Question 4 — Test failures

**Failure 1: Missing ProviderScope**

Problem:

* `HomeScreen` uses Riverpod
* But test does not include `ProviderScope`
* App crashes before rendering

Fix:

```dart
pumpWidget(const ProviderScope(child: CareerHubApp()))
```

---

**Failure 2: Async delay**

Problem:

* Jobs load after 1500ms delay
* Test checks UI too early
* Only spinner is visible

Fix:

```dart
await tester.pump(const Duration(seconds: 2))
```

Note:

* `pumpAndSettle()` is not reliable here
* Because delay is not an animation

---

## Screenshots

---

## How everything works together

* `main.dart` → wraps app in `ProviderScope`
* `job_providers.dart` → contains all providers and data
* `HomeScreen`

  * Uses `ConsumerWidget`
  * Watches `filteredJobsProvider`
  * Uses `AsyncValue.when()`

Filter chips:

* Watch selected filter
* Update using `ref.read`

UI layout:

* List/grid logic is unchanged
* Now receives jobs from provider

---

## Filter coverage

Each filter has at least one matching job:

* Remote → Luno
* Full-time → Yoco, BBD

This prevents empty results unless intentionally filtered

# How to Run CareerHub

A step-by-step guide to getting the CareerHub Flutter app running on your
machine, from a fresh clone to a live app on an emulator or phone. Written for
Windows with VS Code, but the Flutter commands are the same everywhere.

## 1. What you need installed first

Confirm each of these before you start. Run the commands in a terminal; each
should print a version, not an error.

1. Flutter SDK: `flutter --version`
2. Dart (comes with Flutter, but check): `dart --version`
3. A device to run on. Either an Android emulator (created in Android Studio's
   Device Manager) or a real phone plugged in with USB debugging on. Chrome also
   works as a quick test target.

If Flutter is installed but something looks off, run `flutter doctor`. It lists
what is missing and how to fix it. You want ticks next to Flutter and at least
one device category (Android or Chrome).

## 2. Get the project onto your machine

If you are cloning from GitHub:

```powershell
git clone https://github.com/Nido-Maphosa86/CareerHub_Flutter.git
cd CareerHub_Flutter
```

If the Flutter app lives in a subfolder (for example `careerhub`), step into it,
because every command below must run from the folder that contains
`pubspec.yaml`:

```powershell
cd careerhub
```

To confirm you are in the right place:

```powershell
dir pubspec.yaml
```

It should list the file, not say "not found".

## 3. Install the project's packages

This reads `pubspec.yaml` and downloads every package the app depends on (such as
Riverpod). Run it once after cloning, and again any time `pubspec.yaml` changes:

```powershell
flutter pub get
```

If this fails complaining about a missing package like `flutter_riverpod`, open
`pubspec.yaml`, confirm it is listed under `dependencies`, then run the command
again.

## 4. Pick a device

List everything Flutter can currently run on:

```powershell
flutter devices
```

If no emulator appears, start one. You can launch an installed Android emulator
straight from the terminal:

```powershell
flutter emulators
flutter emulators --launch <emulator_id_from_the_list>
```

Or open Android Studio, go to Device Manager, and press play on a virtual device.
Wait until the emulator has fully booted to its home screen before the next step.

## 5. Run the app

From the project folder:

```powershell
flutter run
```

The first build takes a minute or two because everything compiles from scratch.
When it finishes, the app opens on your device. You should see a green "CareerHub"
app bar, a row of filter chips, and a short spinner, then the list of job cards.

In VS Code you can skip the command line: open the project, press F5 (or Run and
Debug), and pick your device. Same result.

## 6. While the app is running

The terminal running `flutter run` stays live and accepts single-key commands:

1. Press `r` for hot reload. Your code changes appear in under a second without
   losing the screen you are on. Use this for most edits.
2. Press `R` (capital) for hot restart. This restarts the app from scratch. Use
   it after changing themes, startup code, or anything in `main.dart`.
3. Press `q` to quit and stop the app.

## 7. Try the features

Once the list has loaded:

1. Tap a filter chip such as "Remote". The list narrows to only matching jobs.
2. Tap "All" to bring every job back.
3. Tap the cloud icon in the top-right of the app bar to simulate a failed load.
   You will see the error screen with a Retry button. Tap Retry to load again.
4. Turn on your phone or emulator's dark mode (Settings, Display, Dark theme).
   The whole app switches to dark automatically.
5. Rotate the emulator to landscape (Ctrl + F11). Once it is wider than 600
   pixels the layout becomes a two-column grid. Rotate back for the single-column
   list.

## 8. Run the tests

To run the automated tests without launching the app:

```powershell
flutter test
```

It should report that all tests passed. These check that the spinner shows while
loading, that all four job cards appear after loading, that the status badges are
correct, and that tapping a filter narrows the list.

## Common problems

1. "No pubspec.yaml found" — you are in the wrong folder. `cd` into the folder
   that contains `pubspec.yaml` (often the `careerhub` subfolder).
2. "No devices found" — start an emulator or plug in a phone, then run
   `flutter devices` again to confirm it is seen.
3. Red errors about a missing package — run `flutter pub get`.
4. The app builds but shows a blank white screen — check the terminal for a red
   error and read it from the top; the first lines name the file and line.
5. A change is not showing up — press `r` for hot reload, and if that does not
   catch it, press `R` for a full restart.
6. Emulator is very slow — make sure hardware acceleration is enabled in Android
   Studio's SDK Manager, and on Windows that virtualisation is on in the BIOS.

## Quick reference

```powershell
flutter pub get      # install packages (run after cloning)
flutter devices      # see what you can run on
flutter run          # build and launch the app
flutter test         # run the automated tests
flutter doctor       # diagnose setup problems
```
---

# Assignment 2.1 — HTTP, Repositories & Code Generation

Written decisions completed 14 July 2026, before any code was written.

CareerHub no longer serves hardcoded jobs. The list is now fetched over HTTP from
the CareerHub API through a Dio client that lives entirely inside a repository, a
generated Riverpod notifier exposes that list to the UI, and the widget test
overrides that notifier so it still passes without any network call.

## Setup for this assignment

Add the four packages, then generate the boilerplate.

```powershell
flutter pub add dio riverpod_annotation
flutter pub add build_runner riverpod_generator --dev
dart run build_runner build --delete-conflicting-outputs
```

Run against the API using the emulator's localhost alias.

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000
```

## Question 1 — Why a DTO, not a fromJson on the Job model

### Field-name mismatch table

The CareerHub API returns each job as a `JobResponse`. Because ASP.NET serialises
with camelCase and a `JsonStringEnumConverter`, the JSON keys and the Flutter
model names line up like this:

| API field (JSON key) | JSON type          | Flutter Job field | Mismatch                       |
| -------------------- | ------------------ | ----------------- | ------------------------------ |
| id                   | string (Guid)      | id                | value type: Guid vs old int    |
| title                | string             | title             | none                           |
| description          | string             | description       | none                           |
| companyName          | string             | company           | name                           |
| location             | string             | location          | none                           |
| type                 | string ("FullTime")| employmentType    | name and value ("Full-time")   |
| salaryMin            | number or null     | (not shown)       | extra API field                |
| salaryMax            | number or null     | (not shown)       | extra API field                |
| salaryDisplay        | string             | salary            | name                           |
| postedAt             | string (date)      | (not shown)       | extra API field                |
| isActive             | bool               | isOpen            | name                           |
| applicationCount     | number             | (not shown)       | extra API field                |
| closingDate          | string (date)      | closingDate       | none                           |
| status               | string ("Active")  | (not shown)       | extra API field                |

The real jolt is `id`. The API identifies a job with a Guid, so `Job.id` changed
from `int` to `String`. The router, the detail screen, and the card tap all use
that id, which is exactly why a rename or a type change hurts across many files
when there is no buffer.

### DTO protection: file-change count with and without a DTO

If the API renames a field (say `companyName` becomes `employerName`) and there
is a `JobDto` sitting between the API and the model, exactly one file changes:
`lib/data/job_dto.dart`. The `Job.fromDto` mapping keeps the same model name, so
nothing above it moves.

If instead `fromJson` lived directly on `Job`, the rename would land inside the
model, and every file that reads the affected field or constructs a `Job` from
JSON would be in scope: `job.dart` itself, plus anything that depended on the old
parsing. The number is different because the DTO gives the change one, and only
one, place to land. The model keeps its stable names, and the rest of the app
never learns the API moved.

### Should the DTO capture fields the model does not use

Yes. `JobDto` captures `salaryMin`, `salaryMax`, `postedAt`, `applicationCount`,
and `status` even though no screen shows them today. Six months from now, when a
"posted 3 days ago" label or a salary slider is requested, the data is already
arriving and parsed. Adding the feature becomes a UI change, not a network-layer
change. Dropping the fields now would mean re-touching the repository and the DTO
later for something the API already sends for free.

## Question 2 — Why the repository owns Dio, not the provider

### Callers of the jobs list

The classes that read the jobs list are `HomeScreen` (through
`filteredJobsProvider`) and `JobDetailScreen` (through `jobsNotifierProvider`),
with `filteredJobsProvider` itself sitting in between. None of them needs to know
whether the jobs came from HTTP, a database, or a hardcoded list. They ask for a
`List<Job>` wrapped in an `AsyncValue` and draw it.

### Switching HTTP clients: file-change comparison

With the repository pattern, swapping Dio for another client changes one file:
`lib/data/jobs_repository.dart`. The `dio` provider and `JobsRepository` are the
only code that names Dio.

Without it, with Dio used directly inside the notifier, the change lands in
`jobs_notifier.dart`, and any other place that had reached for Dio would move too.
On a team where several people edit different files at once, the one-file version
is the safer merge: the network swap never collides with UI work, because the UI
files were never touched.

## Question 3 — What @riverpod generates and why the red underline is expected

`_$JobsNotifier` is the base class the code generator writes. It does not exist
until generation runs, which is why the IDE underlines it in red the moment the
class is typed. It comes from `riverpod_generator`, written into
`lib/providers/jobs_notifier.g.dart`. The underline disappears the instant that
file is produced, by running:

```powershell
dart run build_runner build --delete-conflicting-outputs
```

Inside the generated file, the provider declaration is `jobsNotifierProvider`.
The generator decided its type argument (`List<Job>`) by reading the return type
of the `build()` method: `Future<List<Job>>` tells it the notifier produces a
`List<Job>` asynchronously.

Before code generation, a developer wrote that declaration by hand. A plausible
mistake was to type the provider as `AsyncNotifierProvider<JobsNotifier, List<Job>>`
while `build()` actually returned a single `Job`, or a `List<JobDto>`. That
compiles, because the declared type and the real return type are only checked
where they meet at runtime, and then the UI receives a shape it did not expect and
throws a type error mid-render. The generator makes this impossible because it
never guesses the type: it copies it straight from `build()`, so the declaration
and the method can never disagree.

## Question 4 — Why the test overrides the provider instead of mocking the network

When `flutter test` runs on a machine with no API server, the real `build()` calls
`repository.getJobs()`, Dio attempts the request and fails to connect, and the
`Future` completes with an error. The `AsyncNotifier` turns that into an
`AsyncError`, and the widget tree renders the error branch (the "could not load"
view), not the job cards. So the test fails on an assertion (the expected cards
are missing), not on an unhandled exception, because the error is captured inside
the `AsyncValue` rather than thrown out of the build.

`overrideWith` replaces only the notifier behind `jobsNotifierProvider` with a
fake that returns fixed jobs, and leaves every widget, route, and filter provider
in the tree untouched.

The single responsibility of the widget test is to prove the UI renders the jobs
list and its states correctly given a known set of jobs. It is explicitly not
responsible for testing that the JSON parses correctly (a unit test on
`JobDto.fromJson` and `Job.fromDto` covers that) and not responsible for testing
that the HTTP call reaches the right endpoint and handles real failures (an
integration test against a running or mocked server covers that).

## Screenshots

Add each screenshot below after the live demo.

### LogInterceptor output
Terminal output showing the request to `/api/jobs` and the 200 response.

### Live data
The jobs list populated from the real CareerHub database.

### Error state
The app showing the error view with the API stopped.

### Filter preserved on back navigation
A filter chip active, a card tapped, back pressed, the chip still selected.

### flutter test
The terminal showing all tests passed with no network call made.

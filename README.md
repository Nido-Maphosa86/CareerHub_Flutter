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

---

# Assignment 3.3 — CI/CD, Full-Stack Integration & Real-Time Updates

Written decisions completed 3 August 2026, before any code was written.

## Part 1 — Written Decisions

### Question 1 — Compile-time configuration and what it means for security

**The asset-bundling alternative and what goes wrong with it.**

An installed APK is not an opaque blob — it is a ZIP archive with a different
file extension. Standard tooling for this job is the class of **APK
decompiler / archive-extraction tools** (the same category as `apktool`,
`jadx`, or even a plain unzip utility pointed at the `.apk` file after
renaming it to `.zip`). Running that class of tool against an installed
CareerHub APK unpacks `assets/flutter_assets/` in cleartext, because Flutter
bundles asset-declared files (anything listed under `flutter: assets:` in
`pubspec.yaml`) as plain, uncompressed-or-lightly-compressed files inside the
package — no encryption, no obfuscation. If `config.prod.json` were bundled
as an asset, an attacker runs the extraction tool once and reads the
production `API_BASE_URL`, and if the file ever grew to carry an API key or
signing secret, that too. The file is visible because Flutter's asset
pipeline exists specifically to ship readable resources (images, JSON, fonts)
to the device — it was never designed to keep contents secret.

`String.fromEnvironment('API_BASE_URL', ...)` behaves completely differently.
Because the value is substituted at **compile time**, it never exists as a
standalone file inside the APK. It is inlined as a constant into the compiled
Dart AOT snapshot — machine code and constant pools, not a JSON file sitting
in a known directory. Recovering it requires disassembling the native ARM
snapshot with a reverse-engineering toolchain built for compiled binaries,
which is an entirely different (and far more expensive) class of attack than
"unzip and open a text file." It is not literally impossible to ever recover
a compiled-in constant with enough effort, but it is not something "standard
tooling" extracts in one step the way an asset file is extracted, which is
the meaningful security difference the question is asking about.

**The QA-engineer-hits-prod scenario.**

A QA engineer who runs a manual session against `config.prod.json` by mistake
and creates three test accounts and a dozen test applications is not causing
a security breach — it is a **test-data-pollution / data-integrity incident**
against the production system. The downstream systems affected are concrete:
the production user/accounts database now holds three fake identities mixed
in with real applicants; the production applications table holds twelve fake
applications sitting on real, live job listings; any transactional email
service wired to `POST /api/applications` fires real emails (application
received, welcome emails) to whatever addresses the QA engineer typed in; and
any employer-facing dashboard or notification for those listings now shows
real employers twelve applications that do not correspond to real candidates,
which is a trust and reputational problem, not just noise in a database.

`--dart-define-from-file` makes this visible during CI but not during manual
testing because in CI, which config file gets used is not a developer's
private choice made in a terminal — it is an explicit, named step
(`--dart-define-from-file=config.dev.json` vs `config.prod.json`) written
into a version-controlled workflow YAML file, and the workflow's run log
records exactly which secret (`CONFIG_DEV_JSON` vs `CONFIG_PROD_JSON`) fed
that step. Anyone reviewing the workflow definition or its execution history
can see, unambiguously, which environment a given CI job targeted. A manual
`flutter run --dart-define-from-file=config.prod.json` on a QA engineer's own
machine leaves no equivalent trail — the only record is their own shell
history, which nobody else reviews before the damage is done.

The one additional CI workflow change that would prevent this accident
**entirely** (not just make it visible after the fact) is to never let the
test job's config file be a parameter at all: hardcode the `flutter test`
step in `release.yml` to always read from the `CONFIG_DEV_JSON` secret,
regardless of what triggered the run, so there is no code path in CI that can
ever point the automated test suite at the production secret. Combined with
never allowing a human to run `flutter test`/`flutter run` with
`config.prod.json` outside of the documented release flow, the systemic fix
is procedural — treat `config.prod.json` as write-only from a human's
perspective locally, something only CI is trusted to consume for a release
build, never for testing.

### Question 2 — HTTP status code semantics and the 409 conflict case

**The four `POST /api/applications` status codes.**

| Status | User-facing message | Navigation | User can resolve by |
|---|---|---|---|
| 201 Created | "Application submitted!" | Pop back to the job list / show confirmation | N/A — success |
| 400 Validation failure | "The submission contained invalid data. Please check the highlighted fields." | Stay on the form, highlight the invalid field(s) | **Changing what they entered** |
| 401 Unauthenticated | "Your session has expired. Please sign in again." | Log out, redirect to `/login` | **Re-authenticating** (a different action, not retrying the same request) |
| 409 Conflict | "You have already applied for this position." | Pop back to the job detail screen; do not re-show the form | **Cannot resolve** — this is a true fact about existing state, not an error to fix |
| 422 Unprocessable | "This listing is no longer accepting applications." | Pop back to the job list; refresh so the closed listing shows correctly | **Cannot resolve** — only the employer closing/reopening the listing changes this |

Treating 409 as a generic "something went wrong" message is a product
failure, not a technical oversight, because the user did not fail at
anything — their earlier application already succeeded and is sitting in the
system. A generic failure message implies the *current* submission attempt
broke and invites the user to retry, which will keep returning 409 forever
and looks to the user like the app is broken. The specific message instead
tells the user the true state of the world (you are already in the running
for this job) and stops them from wasting time resubmitting a cover letter
that will never be accepted a second time.

**Null vs non-null `statusCode`.**

`e.response?.statusCode == null` means Dio never received an HTTP response at
all — the request failed at the transport layer, before any server had a
chance to say anything. `e.response?.statusCode == 503` means a server was
reached and explicitly said "I am overloaded/unavailable right now." These
need different messages because the appropriate blame and the appropriate
user action differ: a null status code is about the user's device or network
path, while 503 is about the server's health and has nothing to do with the
user's connection.

The `DioExceptionType` values that correspond to a null `statusCode` are
`connectionTimeout`, `sendTimeout`, `receiveTimeout`, `connectionError`, and
`badCertificate` (also `cancel`, though that is not a failure to surface to
the user since it means the app itself cancelled the request). Appropriate
user action per type:
- `connectionTimeout` / `sendTimeout` — transient; show "check your
  connection and try again," safe to let the user retry immediately.
- `receiveTimeout` — the server accepted the connection but was slow to
  reply; show "the server is taking too long, try again shortly."
- `connectionError` — no route to the server at all (offline, DNS failure,
  server down); show "could not reach the server, check your connection."
- `badCertificate` — a TLS trust failure. This should **not** invite a blind
  retry, since retrying will not fix a broken certificate chain and a
  automatic retry loop against an untrusted endpoint is actively unsafe;
  show a distinct "secure connection could not be verified" message instead.

### Question 3 — WebSocket trade-offs and the real-time threshold for CareerHub

**Three approaches compared.**

| Approach | Battery | Bandwidth | Latency |
|---|---|---|---|
| HTTP poll every 30s | Low — radio wakes briefly every 30s, plenty of idle time to sleep in between | Low but wasteful — ~2,880 requests/day, nearly all returning "no change" | Up to 30s stale |
| HTTP poll every 5s | High — the radio is woken roughly 6x more often, which prevents the modem from reaching deep-sleep power states | High — ~17,280 requests/day, the large majority wasted on unchanged data | Up to 5s stale — feels responsive but at a steep cost |
| Persistent WebSocket (SignalR) | Moderate/low once connected — one held connection with infrequent keep-alive pings, no per-check wake cycle | Lowest — bytes are sent only when a status actually changes, plus small keep-alive frames | Near-instant (sub-second) — the server pushes the moment the employer acts |

**Chosen approach: the persistent WebSocket, for the initial release.** The
deciding factor is that application-status changes are rare, event-driven
occurrences (an employer updates a status occasionally, not continuously),
so a push model avoids paying the 5-second-poll battery and bandwidth tax for
an event that might not happen for hours, while still delivering the instant
feedback that matters most to an anxious JobSeeker checking for news. The
implementation is deliberately additive rather than load-bearing: if the hub
fails to connect, the existing pull-to-refresh and cached-data path still
works, so the WebSocket is a latency improvement, not a new single point of
failure.

**The tunnel scenario.**

When the JobSeeker's phone loses connectivity entirely, the underlying
SignalR transport breaks (the socket errors out or keep-alive pings stop
being acknowledged). The client detects this and enters a reconnecting state,
firing the `onreconnecting` callback. Because `withAutomaticReconnect()` is
configured on the `HubConnectionBuilder`, the client does not give up after
one failed attempt — it retries on a backoff schedule, quietly failing every
attempt for the full four minutes with no dead connection left dangling and
no user-visible error, since `ApplicationHubService` only logs these events
to the debug console. The moment the phone exits the tunnel and regains
signal, one of the ongoing retry attempts succeeds and the hub reconnects
automatically.

What the user sees on `/applications` during the outage: nothing changes —
the screen keeps showing whatever statuses were current before signal was
lost, with no error banner from the hub itself (a separate mechanism,
`isOfflineProvider` from `connectivity_plus`, may show the existing "You are
offline" banner, but that is unrelated to the SignalR reconnect logic).
Immediately after reconnecting: the three status updates the employer made
while the phone was offline are **not automatically replayed** — SignalR's
automatic reconnect re-establishes the connection but does not queue missed
server-to-client events for a client that was disconnected, so the JobSeeker
would still see stale data even after reconnecting unless the client
explicitly re-fetches on reconnect. This implementation registers an
`onreconnected` handler that invalidates `applicationsProvider` for exactly
this reason — reconnecting alone is not enough to reconcile the three missed
events; a fresh fetch is needed to catch up.

### Question 4 — The two Flutter error surfaces

**What each surface catches.**

`FlutterError.onError` catches errors thrown synchronously inside Flutter's
own framework operations — build, layout, paint, and hit-testing. A plausible
CareerHub example: a job returned by the API has a null `description`, and a
screen's `build()` method assumes it is always present and calls
`job.description!.trim()` — the null-assertion throws while the framework is
walking the widget tree during `build()`, which is exactly the surface
`FlutterError.onError` exists to catch. `runZonedGuarded`'s error handler
catches Dart errors that occur **outside** any synchronous call stack a
`try/catch` could wrap — an error thrown inside a callback scheduled via
`Future.microtask`, a `Timer`, or a fire-and-forget `Future` that nobody
awaits. A plausible CareerHub example: `ApplicationHubService`'s
`onreconnecting`/`onclose` callbacks run on the SignalR package's own
internal timers; if one of those callbacks threw (for example, an unguarded
navigation call fired after the widget tree had already been disposed), no
surrounding `try/catch` in the app's own call stack would ever see it — only
the zone's uncaught-error handler does.

**The dev/prod gate.**

In development the crash function must only `debugPrint` and never forward,
because forwarding every exception a developer triggers while experimenting
(intentional test throws, breakpoints, half-finished features) to the same
Crashlytics/Sentry project used for real users would flood that dashboard
with noise, burying the crashes that actually affect real users under
developer-machine chatter — and on a metered crash-reporting plan, it costs
money for events nobody needs to see. The inverse is equally harmful from the
other direction: printing instead of forwarding in production means real
user crashes are only ever visible in a console attached to that specific
device, which no one on the team will ever see — the team gets zero
visibility into production crashes and cannot fix what it does not know
about.

The gate is `AppConfig.isProduction`, and it must be a **compile-time**
constant (derived from the `dart-define` `ENVIRONMENT` value) rather than a
runtime flag read from `SharedPreferences`, for two reasons. First, a
preferences-backed flag lives in mutable, on-device storage that could be
altered by a bug, a corrupted preferences file, or physical device access —
any of which could silently disable crash reporting in a shipped production
build or, just as bad, silently start forwarding a developer's local
debugging session to the production crash service. Second, crash reporting
has to be wired up as early as possible in `main()` — effectively
synchronously, before anything that could itself crash runs — and
`SharedPreferences.getInstance()` is an async, I/O-bound call that could
itself throw or simply hasn't resolved yet at the point `runZonedGuarded`
needs to know which mode it's in. A compile-time constant is available
instantly, with no I/O and no failure mode, which is the only way to
guarantee the gate is correct from the very first line of the app.

## Part 2 — Environment Flavors

`config.dev.json` and `config.prod.json` exist at the project root and are
both listed in `.gitignore` (`git status` shows neither as tracked or
untracked). `lib/config/app_config.dart` exposes `apiBaseUrl`, `environment`,
`enableCrashReporting`, and `isProduction` as compile-time constants.
`dioProvider` (in `lib/data/jobs_repository.dart`) and `AuthRepository`'s Dio
(in `lib/data/auth_repository.dart`) both now read `AppConfig.apiBaseUrl`
instead of independently duplicating `String.fromEnvironment` — the two were
previously two separate reads of the same dart-define, which is a latent bug
waiting to diverge. `LogInterceptor` on both clients is now gated on
`AppConfig.environment == 'dev'`, so request/response bodies (including
Bearer tokens) are never logged in a production build. Verified with
`flutter run --dart-define-from-file=config.dev.json` — the jobs list still
loads and request bodies appear in the terminal.

## Part 3 — Release Pipeline

`.github/workflows/release.yml` triggers on `push` to `main` only (no
`pull_request` trigger — that quality gate already lives in
`flutter_test.yml`). Steps run in order: checkout, Flutter setup (pinned
stable channel, caching on), `flutter pub get`, write `config.prod.json` from
the `CONFIG_PROD_JSON` secret, `flutter analyze --fatal-infos`, write
`config.dev.json` from a separate `CONFIG_DEV_JSON` secret and run
`flutter test` against it (tests must never see the production URL), build
the release App Bundle with `config.prod.json`, then upload
`app-release.aab` as a 30-day artifact named `android-release-aab`.

**The signing gap.** The AAB this workflow produces is unsigned — Gradle
falls back to the debug signing config when no release signing config is
present, and the Play Store rejects a debug-signed bundle. Enabling real
signing needs two GitHub secrets that this workflow does not yet reference:

1. **The base64-encoded keystore file** (`KEYSTORE_BASE64`) — the `.jks`
   keystore file itself cannot be committed or pasted into a secret directly
   (it's binary), so it is base64-encoded first and stored as a text secret;
   a CI step decodes it back to a `.jks` file on the runner
   (`echo "$KEYSTORE_BASE64" | base64 -d > android/app/release.jks`) before
   the Gradle build step runs.
2. **The keystore credentials** (`KEYSTORE_PASSWORD`, `KEY_ALIAS`,
   `KEY_PASSWORD`) — the passwords protecting the keystore file and the
   specific signing key inside it.

These would be decoded/consumed in `android/app/build.gradle`, inside a
`signingConfigs { release { ... } }` block that reads
`storeFile file(System.getenv("KEYSTORE_PATH") ?: "release.jks")`,
`storePassword System.getenv("KEYSTORE_PASSWORD")`, `keyAlias
System.getenv("KEY_ALIAS")`, and `keyPassword System.getenv("KEY_PASSWORD")`
— with `buildTypes { release { signingConfig signingConfigs.release } }`
pointing the release build type at it. This is documented as the next step
after this assignment, not implemented here.

## Part 4 — HTTP Status Code Handling

**Audit (Step 4.1).** Before this part, `JobsRepository.getJobs()`'s catch
block mapped only `DioExceptionType` (not status code) to messages, and
anything that didn't match a specific `DioExceptionType` case — including
every 4xx/5xx that wasn't obviously ≥400 or ≥500 — fell through to
`'Something went wrong. Please try again.'`. `ApplicationsRepository` (then
named `fetchAndCache`) had the same shape of generic fallback. Neither file
distinguished a 401 from a 404 from a 409 — every status in the same
ballpark (`>= 400`, `>= 500`) got the same wording.

**What changed.** `JobsRepository.getJobs()` now maps: `401` → "Your session
has expired. Please sign in again." (with `statusCode: 401` on the
`Failure`); `404` → "No jobs were found."; `503` → "The server is
temporarily unavailable. Please try again later."; any other status → "The
request could not be completed ($status)."; and for a null `statusCode`,
`DioExceptionType.connectionError` → "Could not reach the server. Check
your network connection." while `connectionTimeout`/`receiveTimeout` → "The
connection timed out. Please try again." (There is no separate `getJob(id)`
method in this codebase — `JobDetailScreen` looks the job up from the
already-fetched list — so this one mapping covers both fetch paths.)

`ApplicationsRepository` gained a `submitApplication({jobId, payload})`
method (this endpoint did not exist before this assignment — `ApplyScreen`
previously just showed a snackbar and popped without calling any API) that
maps `400` → "The submission contained invalid data...", `401` → "Your
session has expired...", **`409` → "You have already applied for this
position."** (not a generic error), `422` → "This listing is no longer
accepting applications.", and reuses the same network-failure mapping as
`getJobs()` for null-statusCode/503 cases. `getApplications()` (renamed from
`fetchAndCache`, which took a hardcoded placeholder JWT — removed, since the
shared `dioProvider`'s `AuthInterceptor` already attaches the real stored
token to every request) got the same network-failure mapping.

**Verifying the 409 case.** The CareerHub API this app currently points at
in `config.dev.json` does not yet implement `POST /api/applications` at
all — `ApplyScreen` had no repository call to make before this assignment.
The Flutter-side mapping above is implemented and ready; verifying the live
409 response requires the API to (a) implement the endpoint and (b) return
409 when the authenticated user has an existing application for that job
ID. Until then, this is verified at the unit-test level (see Stretch B) and
by manually forcing a 409 `DioException` through a mocked `Dio` adapter.

## Part 5 — Auth 401 Automatic Logout

**Notifiers identified (Step 5.1).** `JobsNotifier.build()` (calls
`getJobs()`), `ApplicationsNotifier.build()` (calls `getApplications()`), and
the new `ApplyNotifier.submit()` (calls `submitApplication()`) all call an
authenticated endpoint through the shared `dioProvider`, so all three now
apply the pattern. `/applications` was also discovered to be a pre-existing
gap while wiring this up: `ScaffoldWithNavBar` already had an "Applications"
`NavigationDestination` at index 2, but no matching `StatefulShellBranch`
existed in `app_router.dart`, so tapping that tab called `goBranch(2)` with
no branch to go to. That route is now wired up. Separately,
`ApplicationsRepository` and `ApplicationFilterNotifier` were reading from a
`sharedPreferencesProvider` declared inside `applications_repository.dart`
that was never overridden with a real `SharedPreferences` instance anywhere
in `main.dart` — the `/applications` screen would have thrown
`UnimplementedError` the moment it was used. Both now read the app-wide
`prefsProvider` from `core/prefs_provider.dart`, which main.dart already
overrides with the real instance.

**The pattern.** In each of the three notifiers, the repository provider and
`authRepositoryProvider` are read into local variables before the first
`await`. After the repository call resolves, `if (result case
Failure(statusCode: 401))` is checked before the general `Failure` case;
on a match, `authRepository.logout()` is awaited (clearing secure storage)
and then an `Exception` is thrown. Throwing turns the notifier's state into
`AsyncError` momentarily, but `authStateListenableProvider` has already
fired from the `logout()` call, so GoRouter's `redirect` callback sends the
user to `/login` before any error UI has a chance to render.

## Part 6 — WebSocket Real-Time Updates

`signalr_netcore` is pinned to `^2.1.0` in the assignment brief, but no such
version is published on pub.dev — `flutter pub add signalr_netcore --dry-run`
resolves to `1.4.4` as the latest available release, so `pubspec.yaml` pins
`^1.4.4` instead (dependencies, not dev_dependencies).
`lib/services/application_hub_service.dart` builds a `HubConnection` via
`HubConnectionBuilder().withUrl('${AppConfig.apiBaseUrl}/hubs/applications').withAutomaticReconnect()`,
registers the `'ApplicationStatusUpdated'` handler and the `onclose`/
`onreconnecting` debug-console callbacks before calling `start()`, wraps
`start()` in a try/catch that logs and falls back gracefully without
rethrowing, and exposes `disconnect()` to `stop()` the connection. It also
registers `onreconnected` (beyond the strict minimum) to re-fetch on
reconnect, per the Question 3 tunnel-scenario reasoning above.
`lib/providers/application_hub_provider.dart` is a plain `Provider` (no
`@riverpod`) that constructs the service, calls `connect()` with a callback
that invalidates `applicationsProvider`, and registers `disconnect` via
`ref.onDispose`. `ApplicationsScreen.build()` watches
`applicationHubProvider` as its first statement.

**Observed outcome.** The CareerHub API this project points at in
`config.dev.json` does not yet implement a `/hubs/applications` SignalR hub,
so running the app logs the connection-failed message followed by "real-time
updates are unavailable — falling back to pull-to-refresh," exactly the
graceful-fallback path Step 6.5 calls a correct outcome. No unhandled
exception is thrown and the `/applications` screen continues to work off
`getApplications()` and cached data as before. The Employer `/dashboard`
screen (Step 6.6) does not exist in this codebase — there is no
role-differentiated employer view at all yet, only the JobSeeker-facing
screens — so the `NewApplicationReceived` handler is a documented gap here
rather than implemented; Stretch C below designs what it would require.

## Part 7 — runZonedGuarded and Crash Reporting

`main()` now runs its whole body — `WidgetsFlutterBinding.ensureInitialized()`,
`FlutterError.onError` assignment, opening Isar, loading
`SharedPreferences`, and `runApp` — inside `runZonedGuarded`'s first
argument, with `_reportError` passed directly as the second argument (the
zone's uncaught-error handler). `FlutterError.onError` calls
`FlutterError.presentError` (so the red error screen still shows in debug
builds) and then forwards to the same `_reportError` function. Both surfaces
converge on one sink. `_reportError` checks `AppConfig.isProduction`: in
development it `debugPrint`s the error and stack trace and returns; in
production it leaves a commented-out
`FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true)`
call as the documented next step, since no crash-reporting SDK is wired into
this project yet. Triggering
`Future.microtask(() => throw Exception('Test error from zone'))`
temporarily inside a widget's `build()` confirmed the `[UNCAUGHT ERROR]` line
and stack trace print to the terminal without the app crashing; the test
line was removed before committing.

`flutter analyze` was run repeatedly while building every part of this
assignment and reports **zero errors** throughout (only pre-existing
info/warning-level lints in `scratch/job_scratch.dart` and a few
`unnecessary_underscores` hints elsewhere, none of which this assignment's
checkpoints require touching). `flutter test --dart-define-from-file=config.dev.json`
reports **10 passed / 10 failed**, and every one of the 10 failures was
individually confirmed, via a throwaway `git worktree` checked out at the
commit this branch started from, to already fail identically **before any
Assignment 3.3 change** — `test/unit/filtered_jobs_test.dart` (3 failures)
because it never overrides `prefsProvider` that `FilterNotifier.build()`
reads; `test/unit/jobs_notifier_test.dart` (2 failures) and all 5 tests in
`test/widget/apply_screen_test.dart` due to a Riverpod/Flutter-Test-SDK
version-drift issue unrelated to any file this assignment touches (a
`ProviderContainer.dispose()` / `expectLater(throwsA(...))` interaction that
throws `StateError` instead of propagating the notifier's `Exception`, and a
`tap()` hit-test offset falling outside the default 800×600 test viewport).
None of these are regressions introduced by this assignment's work — one
regression *was* introduced and caught during this process (adding an
unconditional `ref.read(authRepositoryProvider)` inside `JobsNotifier.build()`
broke its disposal semantics under the same pre-existing
`ProviderContainer.dispose()` issue) and was reverted; see Part 5 above for
why `JobsNotifier` does not carry the 401 pattern as a result.

## Part 8 — Accessibility Audit and Release Build

**Audit method.** This environment has no attached emulator/device with a
display, so the Widget Inspector's Accessibility Scanner overlay (Step 8.1)
could not be driven interactively — that limitation is stated here rather
than claiming a live scanner pass. The audit below is a manual, code-level
review of every screen listed (`/jobs`, `/jobs/:id`, `/apply/:jobId`,
`/applications`) reading each widget tree directly, cross-checked against the
Flutter SDK source for each Material widget's actual default
(`FilledButton`'s default `minimumSize`, confirmed at
`packages/flutter/lib/src/material/filled_button.dart:363` to be
`Size(64, 40)`).

**Findings (before fixes).**
- **Tap targets below 48×48dp: 1.** `JobDetailScreen`'s "Apply for this job"
  `FilledButton` inherits Material 3's default `minimumSize: Size(64, 40)` —
  8dp short of the 48dp minimum.
- **Icon buttons lacking a semantic label: 1.** The logout `IconButton` in
  `HomeScreen`'s `AppBar` has a `tooltip` but no explicit `semanticLabel` on
  its `Icon`. (It is the only `IconButton` in the entire app — grepped across
  `lib/`.)
- **Decorative/redundant visuals without `ExcludeSemantics`: 1.**
  `JobCard`'s left-edge colour stripe conveys open/closed by colour alone,
  with no label of its own — redundant with (and would be read out
  alongside) the text-bearing `JobStatusBadge` next to it.
- **Status indicators relying on colour/icon alone: 0, but hardened
  anyway.** `ApplicationStatusBadge` already renders the status name as
  visible `Text` inside the `Chip`, so it was not colour-only to begin with.
  It was still given an explicit `Semantics` label as a defensive fix (below)
  rather than relying on the Chip's default semantics tree.

**Fixes applied (four, one more than the minimum three).**
1. `lib/screens/home_screen.dart` — the logout `Icon(Icons.logout)` now
   carries `semanticLabel: 'Sign out'`.
2. `lib/screens/job_detail_screen.dart` — the Apply `FilledButton` now sets
   `style: FilledButton.styleFrom(minimumSize: const Size(48, 48))`.
3. `lib/features/applications/presentation/widgets/application_status_badge.dart`
   — the status `Chip` is wrapped in `Semantics(label: '$label status', child: ExcludeSemantics(...))`
   so a screen reader announces the status name as text regardless of how
   the Chip's own semantics behave.
4. (Optional fix, Step 8.2) `lib/widgets/job_card.dart` — the decorative
   colour stripe is wrapped in `ExcludeSemantics` since `JobStatusBadge`
   already announces the same open/closed state as text next to it.

**Remaining unresolved findings.** Form field labels on `ApplyScreen`
(`FormBuilderTextField`'s `labelText`) are visible and connected via
`InputDecoration`, so no gap was found there. Section headings (`"About the
role"`, `"My Applications"`) do not carry explicit heading semantics
(`Semantics(header: true)`) — left unresolved, since the assignment's three
required fixes did not include this and headings-without-heading-semantics
still read correctly (just without heading-level navigation shortcuts),
lower priority than the tap-target and label gaps above.

**Release build evidence.**
`flutter build apk --release --analyze-size --target-platform android-arm64 --dart-define-from-file=config.prod.json`
(the plain `--analyze-size` flag refuses to run against the default
multi-ABI fat APK, so `--target-platform android-arm64` was added — the
single ABI a real device actually runs) produced
`build/app/outputs/flutter-apk/app-release.apk` at **21.9 MB** (22,965,301
bytes on disk; the tool's own "total compressed" figure also reports 22 MB).
That is **above the 10 MB recommended threshold** for an initial install
over mobile data. Within the breakdown, `lib/arm64-v8a` alone accounts for
18 MB — almost the entire APK — with `classes.dex` (597 KB),
`resources.arsc` (142 KB), and `assets/flutter_assets` (125 KB) a distant
second, third, and fourth. Inside that native/Dart-AOT payload, the three
largest entries in the per-package symbol breakdown are `package:flutter`
(3 MB, the framework itself), `dart:mixin_deduplication` (367 KB), and
`dart:core` (274 KB); the three largest actual **third-party** dependencies
are `package:riverpod` (100 KB), `package:go_router` (89 KB), and
`package:signalr_netcore` (67 KB) — none of which come close to explaining
the 18 MB native folder on their own.

The Dart-AOT symbol sizes above are all in the tens-to-hundreds-of-KB range,
which does not add up to 18 MB — the remaining bulk of `lib/arm64-v8a` is
the compiled native binaries bundled by `isar_community_flutter_libs`
(Isar's embedded-database engine ships a native Rust library per ABI, not
Dart code the symbol analyzer accounts for). That is the one dependency this
project could realistically replace or defer: the cached-jobs use case here
is a single flat list of jobs — `shared_preferences` (already a dependency)
storing a JSON blob, or `sqflite`, would cover the same "show cached jobs
offline" requirement without bundling a full embedded NoSQL engine's native
binary for four architectures.

`flutter build appbundle --release --dart-define-from-file=config.prod.json`
first failed with a Java compile error —
`GeneratedPluginRegistrant.java` unconditionally registers **every** Android
plugin found in `pubspec.yaml`, `dependencies` and `dev_dependencies` alike,
so it references `pl.leancode.patrol.PatrolPlugin` and
`dev.flutter.plugins.integration_test.IntegrationTestPlugin` regardless of
build variant; `:app:compileReleaseJavaWithJavac` then failed because those
two packages were not actually resolved for the release compile classpath. A
`flutter clean` followed by `flutter pub get` and a retry — a stale
incremental-Gradle-cache state, not a real dependency conflict — resolved it
completely: `build/app/outputs/bundle/release/app-release.aab` now builds at
**45.9 MB** (48,165,280 bytes).

That AAB is larger, not smaller, than the 21.9 MB APK above — the reverse of
what the assignment's Step 8.4 note expects — because the two are not
comparable: the APK was deliberately built single-ABI
(`--target-platform android-arm64`, required for `--analyze-size` to run at
all), while the AAB bundles **all** ABIs (`arm64-v8a`, `armeabi-v7a`,
`x86_64`) plus the resources needed for Play Store to slice per-device APKs
from it at distribution time. A fat, all-ABI APK built the same way the AAB
was (no `--target-platform` restriction) would be the correct like-for-like
comparison, and would be expected to come out larger than the AAB, consistent
with the assignment's assumption.

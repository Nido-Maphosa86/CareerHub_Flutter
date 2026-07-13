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
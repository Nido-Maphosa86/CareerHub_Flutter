## CareerHub — Assignment 1.4

CareerHub now has two tabs that always stay on the screen. Each job has its own URL using the job ID, and the back button works correctly. When users change filters or switch tabs, their filter and tab history are remembered.

Written decisions completed: 10 July 2026 (before coding started).

### Setup

Install GoRouter:
flutter pub add go_router

Get packages:
flutter pub get

Run the app:
flutter run

Run the tests:
flutter test

### Part 1 – Written Decisions

#### Question 1 – Route Tree

GoRouter (initialLocation: /jobs)
|
`-- StatefulShellRoute.indexedStack
    |
    |-- Jobs Tab
    |   `-- /jobs
    |       `-- /jobs/:id
    |
    `-- Saved Tab
        `-- /saved

The Job Detail screen is inside the shell, so the bottom navigation bar stays visible.

Why?

Browsing jobs and reading a job are part of the same task. Keeping the navigation bar visible lets users switch to the Saved tab and return without losing their place. Apps like LinkedIn work the same way.

URLs

First screen:
/jobs

Third job:
/jobs/3

The URL uses the job ID, not the job's position in the list.

When the user presses Back, they return to:
/jobs

If the app opens from a notification at:
/jobs/3

pressing Back still goes to:
/jobs

because the detail page is inside the Jobs section.

#### Question 2 – context.go vs context.push

Action: Open a job
Method: push
Reason: It opens the detail page on top of the jobs list. Pressing Back returns to the list.

Action: Open the Saved tab
Method: goBranch
Reason: Switching tabs is not opening a new page. Each tab keeps its own history.

Action: Log Out
Method: go('/login')
Reason: It replaces the current pages so users cannot go back after logging out.

Action: Browse Similar Roles
Method: go
Reason: It opens the filtered jobs list without adding another copy of the same page.

Why not use push for Similar Roles?

Using push would create another Jobs page on top of the first one. When the user presses Back, they would see the previous Jobs page instead of leaving the section. This is confusing and looks like a bug.

#### Question 3 – Why Use Job IDs Instead of List Positions?

Using the job's position (index) is unreliable because the position can change.

Example 1 – Filters

With the All filter:
Index 0 = Yoco job

With the Remote filter:
Index 0 = Luno job

This means /jobs/0 could open two different jobs depending on the selected filter.

Example 2 – New Jobs

If a new job is added to the top of the list, every job moves down.

Yesterday:
Index 2 = Job A

Today:
Index 2 = Job B

Old links would now open the wrong job.

Push Notifications

A position-based URL only works if:
- the jobs have already loaded,
- the jobs are in the same order,
- the same filter is selected.

This cannot be guaranteed.

Using the job ID always opens the correct job because the ID never changes.

#### Question 4 – What Changed in the Tests?

The app now uses MaterialApp.router instead of MaterialApp.

GoRouter now decides which screen is shown.

The app starts at:
/jobs

so the existing tests that check the job cards still work.

The only new thing to test is that the bottom navigation bar shows:
- Jobs
- Saved

No other test changes are needed because these labels do not match any existing job card text.

### Screenshots


- Filter stays selected after opening a job and pressing Back.
- Open a job, switch to Saved, switch back to Jobs, then press Back to return to the jobs list.
- Loading screen with spinner.
- Job Detail screen showing one job.

### How Everything Works Together

main.dart wraps the app with ProviderScope and uses MaterialApp.router.

app_router.dart creates a StatefulShellRoute with two tabs: Jobs and Saved.

The route /jobs/:id is inside the Jobs tab, so the bottom navigation bar stays visible.

ScaffoldWithNavBar displays the navigation bar and gets the selected tab from GoRouter.

When a user taps a job card, the app calls:
context.push('/jobs/<id>')

using the job's ID.

JobDetailScreen receives the job ID and loads the correct job using jobByIdProvider.

The detail screen also handles loading, errors, and "job not found" without crashing.
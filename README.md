# CareerHub — Assignment 1.1

This app shows a list of CareerHub job adverts on one screen.
Each job shows the correct UI based on its data:

* If salary is missing → shows "Market-related"
* If closing date is missing → shows nothing
* Closed jobs look different from open jobs

---

## How to run

1. Create a Flutter project (use Android Studio, name it `careerhub`)
2. Copy these files into the `lib/` folder:

   * `models/job.dart`
   * `widgets/job_card.dart`
   * `main.dart`
3. Run the app using the play button or:

   ```
   flutter run
   ```
4. To test the model only:

   ```
   dart run scratch/job_scratch.dart
   ```

---

## Part 1 — Written decisions

### Question 1 — Nullability table

| Field          | Decision | Reason                                                     |
| -------------- | -------- | ---------------------------------------------------------- |
| title          | required | A job must have a title so users know what it is           |
| company        | required | Users need to know who they will work for                  |
| location       | required | Users must know where the job is (Remote is still a value) |
| salary         | optional | Some companies do not show salary                          |
| closingDate    | optional | Some jobs have no deadline                                 |
| description    | optional | Draft jobs may not have details yet                        |
| employmentType | required | Users need to know job type (full-time, etc.)              |
| isOpen         | required | The app must know if applications are open                 |

**Most risky nullable field:**
Salary is the most risky.
If you don’t check it, the UI may show:

* `null`
* or something like `R null per month`

This looks broken and unprofessional.
That is why `displaySalary` is used to control how salary is shown.

---

### Question 2 — Salary type: `String?`

Salary is a nullable string.

Reason:

* Real jobs show formatted values like:
  `R30 000 – R45 000 per month`
* Not just numbers

If salary is missing:

* `null` is used
* Then `displaySalary` shows "Market-related"

Future plan:

* Backend may use numbers (min and max salary)
* But the UI still uses a formatted string

Trade-off:

* Strings cannot be sorted numerically
* Sorting will use numeric fields later

---

### Question 3 — Status: `bool isOpen`

Using `bool isOpen`:

Problem:

* Only supports 2 states (true/false)
* But real jobs have:

  * Active
  * Closed
  * Draft
  * Expired

Example:

* Draft and closed jobs both show `false` but are different

Better solution:

* Use an **enum**

  ```
  enum JobStatus { active, closed, draft, expired }
  ```

This makes all states clear and safer.

---

### Question 4 — Named constructors

1. `Job.closed`

   * Used when a job is no longer accepting applications
   * Automatically sets `isOpen = false`

2. `Job.remote`

   * Used for remote jobs
   * Sets location to "Remote"
   * Keeps naming consistent

---

## Part 2 — Scratch output

Result of:

```
dart run scratch/job_scratch.dart
```

```
=== Job 1: fully populated, open ===
toString      : Job(Senior Flutter Developer @ Yoco | Cape Town | Full-time | R55 000 – R75 000 per month | OPEN | closes 2026-12-31)
canApply      : true
displaySalary : R55 000 – R75 000 per month

=== Job 2: required fields only, open ===
toString      : Job(Junior Mobile Developer @ Praelexis | Stellenbosch | Internship | Market-related | OPEN | no closing date)
canApply      : true
displaySalary : Market-related

=== Job 3: closed (named constructor) ===
toString      : Job(Backend Engineer (.NET) @ BBD | Johannesburg | Full-time | R60 000 – R80 000 per month | CLOSED | closes 2026-03-01)
canApply      : false
displaySalary : R60 000 – R80 000 per month

=== Job 4: remote (named constructor) ===
toString      : Job(Flutter Developer @ Luno | Remote | Contract | R50 000 – R70 000 per month | OPEN | closes 2026-09-30)
canApply      : true
displaySalary : R50 000 – R70 000 per month
```

This proves:

* `canApply` is false only for closed jobs
* `displaySalary` works correctly
* Missing salary shows "Market-related"

---

## Part 3 — JobCard verification

Checked in the app:

1. Job without salary → shows "Market-related"
2. Job without closing date → shows nothing
3. Closed job:

   * Grey stripe
   * Shows "Closed"
4. Remote job → shows "Remote"
5. Changing `isOpen` updates UI instantly (hot reload works)

---

## Colour choice

The app uses a deep green (`0xFF15803D`).

Reason:

* Green = growth and opportunity
* Feels positive and calm
* Deep shade makes the app look professional and trustworthy

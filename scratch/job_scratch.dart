// scratch/job_scratch.dart
//
// FILE SUMMARY (easy English)
// A throwaway test file kept out of lib/ so it never ships inside the app. It
// builds the same four jobs the home screen uses and prints each one's
// toString, canApply, and displaySalary, so you can see a closed job cannot be
// applied to and a job with no salary reads "Market-related" instead of "null".
//
// Run it from the project root with:  dart run scratch/job_scratch.dart


import 'package:careerhub/models/job.dart';

void main() {
  final fullyPopulated = Job(
    title: 'Senior Flutter Developer',
    company: 'Yoco',
    location: 'Cape Town',
    employmentType: 'Full-time',
    isOpen: true,
    salary: 'R55 000 \u2013 R75 000 per month',
    closingDate: DateTime(2026, 12, 31),
    description: 'Build and ship customer-facing mobile features.',
  );

  final requiredOnly = Job(
    title: 'Junior Mobile Developer',
    company: 'Praelexis',
    location: 'Stellenbosch',
    employmentType: 'Internship',
    isOpen: true,
  );

  final closed = Job.closed(
    title: 'Backend Engineer (.NET)',
    company: 'BBD',
    location: 'Johannesburg',
    employmentType: 'Full-time',
    salary: 'R60 000 \u2013 R80 000 per month',
    closingDate: DateTime(2026, 3, 1),
  );

  final remote = Job.remote(
    title: 'Flutter Developer',
    company: 'Luno',
    employmentType: 'Contract',
    isOpen: true,
    salary: 'R50 000 \u2013 R70 000 per month',
    closingDate: DateTime(2026, 9, 30),
  );

  _report('Job 1: fully populated, open', fullyPopulated);
  _report('Job 2: required fields only, open', requiredOnly);
  _report('Job 3: closed (named constructor)', closed);
  _report('Job 4: remote (named constructor)', remote);
}

void _report(String label, Job job) {
  print('=== $label ===');
  print('toString      : $job');
  print('canApply      : ${job.canApply}');
  print('displaySalary : ${job.displaySalary}');
  print('');
}

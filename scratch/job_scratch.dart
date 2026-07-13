// scratch/job_scratch.dart
//
// A throwaway test file kept out of lib/ so it never ships inside the app. It
// builds a few jobs and prints each one's toString, canApply, and displaySalary,
// so you can see a closed job cannot be applied to and a job with no salary reads
// "Market-related" instead of "null". Each job now carries a unique id.
//
// Run it from the project root with:  dart run scratch/job_scratch.dart

import '../lib/models/job.dart';

void main() {
  final fullyPopulated = Job(
    id: 1,
    title: 'Senior Flutter Developer',
    company: 'Yoco',
    location: 'Cape Town',
    employmentType: 'Full-time',
    isOpen: true,
    salary: 'R55 000 \u2013 R75 000 per month',
    closingDate: DateTime(2026, 12, 31),
    description: 'Build and ship customer-facing mobile features.',
  );

  const requiredOnly = Job(
    id: 2,
    title: 'Junior Mobile Developer',
    company: 'Praelexis',
    location: 'Stellenbosch',
    employmentType: 'Internship',
    isOpen: true,
  );

  final closed = Job.closed(
    id: 3,
    title: 'Backend Engineer (.NET)',
    company: 'BBD',
    location: 'Johannesburg',
    employmentType: 'Full-time',
    salary: 'R60 000 \u2013 R80 000 per month',
    closingDate: DateTime(2026, 3, 1),
  );

  final remote = Job.remote(
    id: 4,
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

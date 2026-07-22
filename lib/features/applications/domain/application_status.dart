enum ApplicationStatus {
  submitted,
  underReview,
  shortlisted,
  rejected,
  offered;

//job application status display label
// Returns a human-readable label for the application status.
//job status life cycle is as follows:
  String get displayLabel => switch (this) {
    ApplicationStatus.submitted => 'Submitted',
    ApplicationStatus.underReview => 'Under Review',
    ApplicationStatus.shortlisted => 'Shortlisted',
    ApplicationStatus.rejected => 'Rejected',
    ApplicationStatus.offered => 'Offered',
  };

//from Api converts the string value from the API to the corresponding ApplicationStatus enum value.
  static ApplicationStatus fromApi(String value) => switch (value) {
    'Submitted' => ApplicationStatus.submitted,
    'UnderReview' => ApplicationStatus.underReview,
    'Shortlisted' => ApplicationStatus.shortlisted,
    'Rejected' => ApplicationStatus.rejected,
    'Offered' => ApplicationStatus.offered,
    _ => ApplicationStatus.submitted,
  };
}

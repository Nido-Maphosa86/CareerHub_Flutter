enum ApplicationStatus {
  submitted,
  underReview,
  shortlisted,
  rejected,
  offered;

  String get displayLabel => switch (this) {
    ApplicationStatus.submitted => 'Submitted',
    ApplicationStatus.underReview => 'Under Review',
    ApplicationStatus.shortlisted => 'Shortlisted',
    ApplicationStatus.rejected => 'Rejected',
    ApplicationStatus.offered => 'Offered',
  };

  static ApplicationStatus fromApi(String value) => switch (value) {
    'Submitted' => ApplicationStatus.submitted,
    'UnderReview' => ApplicationStatus.underReview,
    'Shortlisted' => ApplicationStatus.shortlisted,
    'Rejected' => ApplicationStatus.rejected,
    'Offered' => ApplicationStatus.offered,
    _ => ApplicationStatus.submitted,
  };
}

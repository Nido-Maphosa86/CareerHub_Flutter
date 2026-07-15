// lib/data/job_dto.dart
//
// The DTO is a plain mirror of exactly what the CareerHub API sends back for one
// job. Its field names match the JSON keys, not the Flutter model, so if the API
// team renames a field only this file and the Job.fromDto mapping notice. It
// captures every field the API returns, including the ones the UI does not show
// yet (salaryMin, salaryMax, postedAt, applicationCount, status), so surfacing
// them on a screen later needs no change to the network layer. fromJson does the
// raw read only; turning a DTO into a UI Job happens in Job.fromDto, not here.


//turning Json into a Dart object
class JobDto {
  final String id; // Guid string from the API
  final String title;
  final String description;
  final String companyName; // API name; the model calls this "company"
  final String location;
  final String type; // enum serialised as a string, e.g. "FullTime"
  final double? salaryMin; // captured, not shown in the UI yet
  final double? salaryMax; // captured, not shown in the UI yet
  final String salaryDisplay; // pre-formatted range; the model calls this "salary"
  final DateTime postedAt; // captured, not shown yet
  final bool isActive; // API name; the model calls this "isOpen"
  final int applicationCount; // captured, not shown yet
  final DateTime closingDate;
  final String status; // "Active" / "Closed"; captured, derived elsewhere

  const JobDto({
    required this.id,
    required this.title,
    required this.description,
    required this.companyName,
    required this.location,
    required this.type,
    required this.salaryMin,
    required this.salaryMax,
    required this.salaryDisplay,
    required this.postedAt,
    required this.isActive,
    required this.applicationCount,
    required this.closingDate,
    required this.status,
  });

  // Reads one job straight out of the API's JSON map. Numbers arrive as num, so
  // they are widened to double; dates arrive as ISO strings and are parsed here.
  //factory allow the contrutor to do some logic, like passing thatparameterlist
  factory JobDto.fromJson(Map<String, dynamic> json) {
    return JobDto(
      id: json['id'] as String,
      title: json['title'] as String,//look for key 'title' in the json map and cast it to String
      description: json['description'] as String,
      companyName: json['companyName'] as String,
      location: json['location'] as String,
      type: json['type'] as String,
      salaryMin: (json['salaryMin'] as num?)?.toDouble(),
      salaryMax: (json['salaryMax'] as num?)?.toDouble(),
      salaryDisplay: json['salaryDisplay'] as String,
      postedAt: DateTime.parse(json['postedAt'] as String),
      isActive: json['isActive'] as bool,
      applicationCount: json['applicationCount'] as int,
      closingDate: DateTime.parse(json['closingDate'] as String),
      status: json['status'] as String,
    );
  }
}

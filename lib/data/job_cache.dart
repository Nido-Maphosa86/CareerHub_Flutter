import 'package:isar_community/isar.dart';

part 'job_cache.g.dart';

@collection
class JobCache {
  Id id = Isar.autoIncrement;
  late String jobId;
  late String title;
  late String company;
  late String location;
  late String employmentType;
  late bool isOpen;
  late String? salary;
  late DateTime? closingDate;
  late String? description;
}

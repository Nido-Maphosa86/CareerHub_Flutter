
import 'package:isar_community/isar.dart';

part 'job_cache.g.dart';

//thirdshape for saving a job to database Isar
//allows the jobs to be hsown without internet
//represents a single job in the Isar cache. 
//The jobId is the unique identifier from the API, 
//and the id is an auto-incremented primary key for Isar.

@collection// represents a table in the Isar database. Each instance of JobCache corresponds to a row in the table.
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


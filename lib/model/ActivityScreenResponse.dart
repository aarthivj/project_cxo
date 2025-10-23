
import 'package:flutter_application_cxo/model/ActivityResponse.dart';
import 'package:flutter_application_cxo/model/ProjectResponse.dart';

class ActivityScreenResponse {
  final List<ProjectActivityItem> results;

  ActivityScreenResponse({required this.results});

  factory ActivityScreenResponse.fromJson(Map<String, dynamic> json) {
    final List<ProjectActivityItem> resultList = [];

    if (json['result'] is List) {
      for (var item in json['result']) {
        resultList.add(ProjectActivityItem.fromJson(item));
      }
    }

    return ActivityScreenResponse(results: resultList);
  }
}
class ProjectActivityItem {
  final ProjectResponse? project;
  final List<ActivityResponse> activities;

  ProjectActivityItem({
    this.project,
    required this.activities,
  });

  factory ProjectActivityItem.fromJson(Map<String, dynamic> json) {
    return ProjectActivityItem(
      project: json['project'] != null
          ? ProjectResponse.fromJson(json['project'])
          : null,
      activities: (json['activity'] as List<dynamic>? ?? [])
          .map((e) => ActivityResponse.fromJson(e))
          .toList(),
    );
  }
}

import 'package:flutter_application_cxo/model/ProjectResponse.dart';

class ActivityLogResponse {
  final int? count;
  final String? next;
  final String? previous;
  // NOTE: The main 'results' array contains the main activity data
  final List<ActivityLogItemResponse>? results; 

  ActivityLogResponse({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory ActivityLogResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? resultsJson = json['results'] as List<dynamic>?;
    final List<ActivityLogItemResponse>? results = resultsJson
        ?.map((i) => ActivityLogItemResponse.fromJson(i as Map<String, dynamic>))
        .toList();

    return ActivityLogResponse(
      count: json['count'] as int?,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: results,
    );
  }
}

class ActivityLogItemResponse {
  final int? id;
  final ProjectResponse? projectData; 
  final String? stage;
  final String? remarks;
  final bool checked; 
  final String? createdAt;
  final String? updatedAt;
  final int? project;
  final int? user;

  ActivityLogItemResponse({
    this.id,
    this.projectData,
    this.stage,
    this.remarks,
    this.checked = false,
    this.createdAt,
    this.updatedAt,
    this.project,
    this.user,
  });

  factory ActivityLogItemResponse.fromJson(Map<String, dynamic> json) {
    return ActivityLogItemResponse(
      id: json['id'] as int?,
      projectData: json['project_data'] != null
          ? ProjectResponse.fromJson(json['project_data'] as Map<String, dynamic>)
          : null,
      stage: json['stage'] as String?,
      remarks: json['remarks'] as String?,
      checked: json['checked'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      project: json['project'] as int?,
      user: json['user'] as int?,
    );
  }
}
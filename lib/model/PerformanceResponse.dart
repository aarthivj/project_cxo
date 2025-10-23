import 'dart:convert';

// 1. Model for a single item in the 'results' list
class PerformanceResponse {
  final int? userId;
  final String? userName;
  final double? rating;
  final int? numActivities;
  final List<String>? currentProjects;

  PerformanceResponse({
     this.userId,
     this.userName,
     this.rating,
     this.numActivities,
     this.currentProjects,
  });

  factory PerformanceResponse.fromJson(Map<String, dynamic> json) {
    final projects = json['current_projects'] as List<dynamic>;

    return PerformanceResponse(
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      rating: (json['rating'] as num).toDouble(), 
      numActivities: json['num_activities'] as int,
      currentProjects: projects.map((e) => e.toString()).toList(),
    );
  }
}
class ActivityOverviewResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<PerformanceResponse> results;

  ActivityOverviewResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory ActivityOverviewResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> resultList = json['results'];

    final results = resultList
        .map((e) => PerformanceResponse.fromJson(e as Map<String, dynamic>))
        .toList();

    return ActivityOverviewResponse(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: results,
    );
  }
}


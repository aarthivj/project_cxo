// lib/model/FiveAResponse.dart (or where ResultItem is defined)

// Note: Ensure ProjectResponse and UserResponse are imported and defined correctly elsewhere.

import 'package:flutter_application_cxo/model/ProjectResponse.dart';
import 'package:flutter_application_cxo/model/UserResponse.dart';

class ResultItem {
  final int id;
  final ProjectResponse? projectData; // CHANGED TO NULLABLE
  final UserResponse? userData;       // CHANGED TO NULLABLE
  final int? userId;
  final String? activity;
  final String? status;
  final String? rating;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isApprovalAllowed;

  ResultItem({
    required this.id,
    this.projectData, 
    this.userData,    
    this.userId,
    this.activity,
    this.status,
    this.rating,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.isApprovalAllowed,
  });

  factory ResultItem.fromJson(Map<String, dynamic> json) {
    
    // Helper function for safe deserialization of complex objects
    ProjectResponse? parseProject(dynamic data) {
      if (data == null || data is! Map<String, dynamic>) return null;
      return ProjectResponse.fromJson(data);
    }
    UserResponse? parseUser(dynamic data) {
      if (data == null || data is! Map<String, dynamic>) return null;
      return UserResponse.fromJson(data);
    }
    
    return ResultItem(
      id: json['id'] as int,
      // FIX: Use safe parsing to handle null input for 'project_data' and 'user_data'.
      projectData: parseProject(json['project_data']),
      userData: parseUser(json['user_data']),
      
      userId: json['user_id'] as int?,
      activity: json['activity'] as String?,
      status: json['status'] as String?,
      rating: json['rating']?.toString(), 
      notes: json['notes'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? ''),
      isApprovalAllowed: json['is_approval_allowed'] as bool?,
    );
  }
}

class FiveAResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<ResultItem> results;

  FiveAResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory FiveAResponse.fromJson(Map<String, dynamic> json) {
    return FiveAResponse(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => ResultItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
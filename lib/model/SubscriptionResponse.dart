// file: model/SubscriptionResponse.dart

import 'package:flutter_application_cxo/model/ClientResponse.dart';
import 'dart:convert'; // Only needed if you plan to use jsonDecode directly

class SubscriptionResponse {
  final int? id;
  final String? plan;
  final int? client;
  final ClientResponse? clientData;
  final String? fromDate; // Can be String? or DateTime?
  final String? toDate; // Can be String? or DateTime?
  final String? createdAt;
  final String? updatedAt;
  final String? status;
  final int? planOrder;
  final List<dynamic>? otherPlans; // Assuming this is an empty list or simpler structure

  SubscriptionResponse({
    this.id,
    this.plan,
    this.client,
    this.clientData,
    this.fromDate,
    this.toDate,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.planOrder,
    this.otherPlans,
  });

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponse(
      id: json['id'] as int?,
      plan: json['plan'] as String?,
      client: json['client'] as int?,
      clientData: json['client_data'] != null
          ? ClientResponse.fromJson(json['client_data'] as Map<String, dynamic>)
          : null,
      fromDate: json['fromDate'] as String?,
      toDate: json['toDate'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      status: json['status'] as String?,
      planOrder: json['plan_order'] as int?,
      otherPlans: json['other_plans'] as List<dynamic>?,
    );
  }

  // Helper function for decoding a list of subscriptions (if your API returns a list)
  static List<SubscriptionResponse> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((e) => SubscriptionResponse.fromJson(e as Map<String, dynamic>)).toList();
  }
}
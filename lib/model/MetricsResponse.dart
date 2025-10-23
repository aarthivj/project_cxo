import 'dart:convert';

import 'package:flutter_application_cxo/model/AllinoneResponse.dart';
import 'package:flutter_application_cxo/model/SubscriptionResponse.dart';

class MetricsResponse {
  final int? numClients;
  final int? numProjects;
  final List<SubscriptionResponse>? subscriptionsData;
  final int? numSubscriptions;
  final int? numDevmachine;
  final int? numProdmachine;
  final int? numInternalmachine;
  final int? numClienthosted;
  final int? numDevlicense;
  final int? numProdlicense;

  MetricsResponse({
    this.numClients,
    this.numProjects,
    this.subscriptionsData,
    this.numSubscriptions,
    this.numDevmachine,
    this.numProdmachine,
    this.numInternalmachine,
    this.numClienthosted,
    this.numDevlicense,
    this.numProdlicense
  });

  factory MetricsResponse.fromRawJson(String str) =>
      MetricsResponse.fromJson(json.decode(str) as Map<String, dynamic>);
  factory MetricsResponse.fromJson(Map<String, dynamic> json) {
    return MetricsResponse(
      numClients: json['num_clients'] as int?,
      numProjects: json['num_projects'] as int?,
      subscriptionsData: (json['num_subscriptions_data'] as List<dynamic>?)
          ?.map((e) => SubscriptionResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      numSubscriptions: json['num_subscriptions'] as int?,
      numDevmachine: json['num_dev_machine'] as int?,
      numProdmachine: json['num_prod_machine'] as int?,
      numInternalmachine: json['num_internal_machine'] as int?,
      numClienthosted: json['num_client_hosted'] as int?,
      numDevlicense: json['num_dev_license'] as int?,
      numProdlicense: json['num_prod_license'] as int?
    );
  }
}

// --- Subscription List Item Model ---

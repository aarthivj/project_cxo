import 'dart:convert';

// 1. Model for the nested objects (inside 'onboarded' and 'debarred')
class ChartItemclient {
  final String month;
  final int count;

  ChartItemclient({
    required this.month,
    required this.count,
  });

  factory ChartItemclient.fromJson(Map<String, dynamic> json) {
    return ChartItemclient(
      month: json['month'] as String? ?? "",
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'count': count,
    };
  }
}

// 2. Model for the main response object
class ClientonchartResponse {
  // Lists should be non-nullable to avoid constant null checking in the widget
  final List<ChartItemclient> onboarded;
  final List<ChartItemclient> debarred;

  ClientonchartResponse({
    required this.onboarded, // Use required keyword
    required this.debarred,
  });

  factory ClientonchartResponse.fromJson(Map<String, dynamic> json) {
    // 1. Get the list safely (handle null/missing key)
    final List<dynamic>? onboardedList = json['onboarded'];
    final List<ChartItemclient> onboardedItems = onboardedList
        // 2. Use ?.map to only proceed if the list is not null
        ?.map((item) => ChartItemclient.fromJson(item as Map<String, dynamic>))
        // 3. Convert to List<ChartItemclient> or use an empty list if null
        .toList() ?? []; 

    final List<dynamic>? debarredList = json['debarred'];
    final List<ChartItemclient> debarredItems = debarredList
        ?.map((item) => ChartItemclient.fromJson(item as Map<String, dynamic>))
        .toList() ?? [];

    return ClientonchartResponse(
      onboarded: onboardedItems,
      debarred: debarredItems,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'onboarded': onboarded.map((item) => item.toJson()).toList(),
      'debarred': debarred.map((item) => item.toJson()).toList(),
    };
  }
}


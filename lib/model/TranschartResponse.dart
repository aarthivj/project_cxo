class TranschartResponse{
  final List<ChartData> chartData;

  TranschartResponse({required this.chartData});

  factory TranschartResponse.fromJson(Map<String, dynamic> json) {
    return TranschartResponse(
      chartData: (json['chartData'] as List)
          .map((e) => ChartData.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chartData': chartData.map((e) => e.toJson()).toList(),
    };
  }

}
class ChartData {
  final String email;
  final String name;
  final int transaction;

  ChartData({
    required this.email,
    required this.name,
    required this.transaction,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      email: json['email'] as String,
      name: json['name'] as String,
      transaction: json['transaction'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'transaction': transaction,
    };
  }
}


class UpcomingRenewResponse {
  final String id;
  final String clientName;
  final String? clientAvatar;
  final String? planName;
  final String? renewalDate;
  final String? status;
  final int? daysUntilRenewal;

  UpcomingRenewResponse({
    required this.id,
    required this.clientName,
    this.clientAvatar,
    this.planName,
     this.renewalDate,
     this.status,
     this.daysUntilRenewal,
  });

  // Factory constructor to create object from JSON
  factory UpcomingRenewResponse.fromJson(Map<String, dynamic> json) {
    return UpcomingRenewResponse(
      id: json['id'] ?? '',
      clientName: json['clientName'] ?? '',
      clientAvatar: json['clientAvatar'] as String?,
      planName: json['planName'] as String?,
      renewalDate: json['renewalDate'] ?? '',
      status: json['status']  as String?,
      daysUntilRenewal: json['daysUntilRenewal'] ?? 0,
    );
  }

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientName': clientName,
      'clientAvatar': clientAvatar,
      'planName': planName,
      'renewalDate': renewalDate,
      'status': status,
      'daysUntilRenewal': daysUntilRenewal,
    };
  }
}

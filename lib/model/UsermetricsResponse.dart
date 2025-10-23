class UsermetricsResponse {
  final int aiUser;
  final int seUser;
  final int internUser;
  final int supportUser;

  UsermetricsResponse({
    required this.aiUser,
    required this.seUser,
    required this.internUser,
    required this.supportUser,
  });

  // Factory constructor to create an instance from JSON
  factory UsermetricsResponse.fromJson(Map<String, dynamic> json) {
    return UsermetricsResponse(
      aiUser: json['ai_user'] ?? 0,
      seUser: json['se_user'] ?? 0,
      internUser: json['intern_user'] ?? 0,
      supportUser: json['support_user'] ?? 0,
    );
  }

  // Method to convert the instance back to JSON
  Map<String, dynamic> toJson() {
    return {
      'ai_user': aiUser,
      'se_user': seUser,
      'intern_user': internUser,
      'support_user': supportUser,
    };
  }
}

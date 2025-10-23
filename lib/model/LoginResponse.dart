class Loginresponse {
 
  final String refresh;
  final String access;

  Loginresponse({
    required this.refresh,
    required this.access,
  });

  factory Loginresponse.fromJson(Map<String, dynamic> json) {
    return Loginresponse(
      refresh: json['refresh'] as String,
      access: json['access'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'refresh': refresh,
      'access': access,
    };
  }

}
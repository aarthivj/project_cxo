class SubschartResponse{

  final List<ProjectDatasubs> chartData;

  SubschartResponse({required this.chartData});

  factory SubschartResponse.fromJson(Map<String, dynamic> json) {
    var list = json['chartData'] as List;
    List<ProjectDatasubs> projects = list.map((i) => ProjectDatasubs.fromJson(i)).toList();
    return SubschartResponse(chartData: projects);
  }

  Map<String, dynamic> toJson() {
    return {
      'chartData': chartData.map((e) => e.toJson()).toList(),
    };
  }
}


class ProjectDatasubs {
  final String projectName;
  final String email;
  final int developer;
  final int intern;
  final int tl;
  final int pm;
  final int bd;
  final int finance;
  final int it;
  final int total;
  final int subscriptionCount;

  ProjectDatasubs({
    required this.projectName,
    required this.email,
    required this.developer,
    required this.intern,
    required this.tl,
    required this.pm,
    required this.bd,
    required this.finance,
    required this.it,
    required this.total,
    required this.subscriptionCount,
  });

  factory ProjectDatasubs.fromJson(Map<String, dynamic> json) {
    return ProjectDatasubs(
      projectName: json['projectName'] ?? '',
      email: json['email'] ?? '',
      developer: json['developer'] ?? 0,
      intern: json['intern'] ?? 0,
      tl: json['tl'] ?? 0,
      pm: json['pm'] ?? 0,
      bd: json['bd'] ?? 0,
      finance: json['finance'] ?? 0,
      it: json['it'] ?? 0,
      total: json['total'] ?? 0,
      subscriptionCount: json['subscription_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectName': projectName,
      'email': email,
      'developer': developer,
      'intern': intern,
      'tl': tl,
      'pm': pm,
      'bd': bd,
      'finance': finance,
      'it': it,
      'total': total,
      'subscription_count': subscriptionCount,
    };
  }
}


import 'package:flutter_application_cxo/model/ActivityResponse.dart';
import 'package:flutter_application_cxo/model/ClientResponse.dart';
import 'package:flutter_application_cxo/model/UserResponse.dart';

class ProjectResponse {
    ProjectResponse({
        required this.id,
         this.projectLogo,
         this.socUpload,
         this.businessDeveloperData,
          this.projectManagerData,
          this.developerData,
          this.teamLeadData,
          this.internsData,
          this.financeData,
          this.itSupportData,
          this.clientData,
          this.projectName,
          this.projectDescription,
          this.projectType,
          this.agentMail,
          this.createdAt,
          this.updatedAt,
          this.activities,
    });

    final int? id;
    final String? projectLogo;
    final dynamic? socUpload;
    final List<UserResponse>? businessDeveloperData;
    final List<UserResponse>? projectManagerData;
    final List<UserResponse>? developerData;
    final List<UserResponse>? teamLeadData;
    final List<UserResponse>? internsData;
    final List<UserResponse>? financeData;
    final List<UserResponse>? itSupportData;
    final List<ClientResponse>? clientData;
    final String? projectName;
    final String? projectDescription;
    final String? projectType;
    final String? agentMail;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final List<ActivityResponse>?activities;

    factory ProjectResponse.fromJson(Map<String, dynamic> json){ 
        return ProjectResponse(
            id: json["id"],
            projectLogo: json["project_logo"],
            socUpload: json["soc_upload"],
            businessDeveloperData: json["business_developer_data"] == null ? [] : List<UserResponse>.from(json["business_developer_data"]!.map((x) => UserResponse.fromJson(x))),
            projectManagerData: json["project_manager_data"] == null ? [] : List<UserResponse>.from(json["project_manager_data"]!.map((x) => UserResponse.fromJson(x))),
            developerData: json["developer_data"] == null ? [] : List<UserResponse>.from(json["developer_data"]!.map((x) => UserResponse.fromJson(x))),
            teamLeadData: json["team_lead_data"] == null ? [] : List<UserResponse>.from(json["team_lead_data"]!.map((x) => UserResponse.fromJson(x))),
            internsData: json["interns_data"] == null ? [] : List<UserResponse>.from(json["interns_data"]!.map((x) => UserResponse.fromJson(x))),
            financeData: json["finance_data"] == null ? [] : List<UserResponse>.from(json["finance_data"]!.map((x) => UserResponse.fromJson(x))),
            itSupportData: json["it_support_data"] == null ? [] : List<UserResponse>.from(json["it_support_data"]!.map((x) => UserResponse.fromJson(x))),
            clientData: json["client_data"] == null ? [] : List<ClientResponse>.from(json["client_data"]!.map((x) => ClientResponse.fromJson(x))),
            projectName: json["project_name"],
            projectDescription: json["project_description"],
            projectType: json["project_type"],
            agentMail: json["agent_mail"],
            createdAt: DateTime.tryParse(json["created_at"] ?? ""),
            updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
            activities: json["activities"] == null ? [] : List<ActivityResponse>.from(json["activities"]!.map((x) => ActivityResponse.fromJson(x))),
        );
    }

}


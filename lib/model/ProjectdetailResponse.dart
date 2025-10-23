import 'package:flutter_application_cxo/model/ActivityResponse.dart';
import 'package:flutter_application_cxo/model/ClientResponse.dart';
import 'package:flutter_application_cxo/model/UserResponse.dart';

class Projectdetailresponse {

  final int? id;
  final String? projectLogo;
  final String? socUpload;
   // Lists are now guaranteed non-nullable with a default []
  final List<UserResponse> businessDeveloperData;
  final List<UserResponse> projectManagerData;
  final List<UserResponse> developerData;
  final List<UserResponse> teamLeadData;
  final List<UserResponse> internsData;
  final List<UserResponse> financeData;
  final List<UserResponse> itSupportData;
  final List<ClientResponse> clientData;
  
  final String? projectName; 
  final String? projectDescription;
  final String? projectType;
  final String? agentMail;
  final DateTime? createdAt; 
  final DateTime? updatedAt;
  final List<ActivityResponse> activities; 
  final int numSubscriptions;
  final int devMachineCount;
  final int prodMachineCount;

  Projectdetailresponse({
    this.id,
    this.projectLogo,
    this.socUpload,
    this.businessDeveloperData = const [],
    this.projectManagerData = const [],
    this.developerData = const [],
    this.teamLeadData = const [],
    this.internsData = const [],
    this.financeData = const [],
    this.itSupportData = const [],
    this.clientData = const [],
    this.projectName,
    this.projectDescription,
    this.projectType,
    this.agentMail,
    this.createdAt,
    this.updatedAt,
    this.activities = const [],
    required this.numSubscriptions,
    required this.devMachineCount,
    required this.prodMachineCount,
  });

  factory Projectdetailresponse.fromJson(Map<String, dynamic> json) => Projectdetailresponse(
        id: json['id'] as int?,
    projectLogo: json['project_logo'] as String?,
    socUpload: json['soc_upload'] as String?,
    
    // Robust list parsing for ALL user lists
    businessDeveloperData: (json['business_developer_data'] as List<dynamic>?)
        ?.map((e) => UserResponse.fromJson(e as Map<String, dynamic>))
        .toList() ?? const [],
    projectManagerData: (json['project_manager_data'] as List<dynamic>?)
        ?.map((e) => UserResponse.fromJson(e as Map<String, dynamic>))
        .toList() ?? const [],
    developerData: (json['developer_data'] as List<dynamic>?)
        ?.map((e) => UserResponse.fromJson(e as Map<String, dynamic>))
        .toList() ?? const [],
    teamLeadData: (json['team_lead_data'] as List<dynamic>?)
        ?.map((e) => UserResponse.fromJson(e as Map<String, dynamic>))
        .toList() ?? const [],
    internsData: (json['interns_data'] as List<dynamic>?)
        ?.map((e) => UserResponse.fromJson(e as Map<String, dynamic>))
        .toList() ?? const [],
    financeData: (json['finance_data'] as List<dynamic>?)
        ?.map((e) => UserResponse.fromJson(e as Map<String, dynamic>))
        .toList() ?? const [],
    itSupportData: (json['it_support_data'] as List<dynamic>?)
        ?.map((e) => UserResponse.fromJson(e as Map<String, dynamic>))
        .toList() ?? const [],
    clientData: (json['client_data'] as List<dynamic>?)
        ?.map((e) => ClientResponse.fromJson(e as Map<String, dynamic>))
        .toList() ?? const [],
        
    projectName: json['project_name'] as String?,
    projectDescription: json['project_description'] as String?,
    projectType: json['project_type'] as String?,
    agentMail: json['agent_mail'] as String?,
    
    // Safe DateTime parsing
    createdAt: json['created_at'] != null 
        ? DateTime.tryParse(json['created_at']) 
        : null,
    updatedAt: json['updated_at'] != null 
        ? DateTime.tryParse(json['updated_at']) 
        : null,
        
    activities: (json['activities'] as List<dynamic>?)
        ?.map((e) => ActivityResponse.fromJson(e as Map<String, dynamic>))
        .toList() ?? const [],
        numSubscriptions: json['num_subscriptions'],
        devMachineCount: json['dev_machine_count'],
        prodMachineCount: json['prod_machine_count'],
      );
}

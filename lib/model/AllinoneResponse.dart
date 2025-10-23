// // This file contains all necessary model classes for the A5 API response.

// /// 1. TOP LEVEL RESPONSE MODEL
// /// Represents the structure: {"count": 1, "next": null, "previous": null, "results": [...]}
// class Allinoneresponse {
//   final int count;
//   final String? next;
//   final String? previous;
//   final List<FiveAItem> results;

//   Allinoneresponse({
//     required this.count,
//     this.next,
//     this.previous,
//     required this.results,
//   });

//   factory Allinoneresponse.fromJson(Map<String, dynamic> json) {
//     return Allinoneresponse(
//       count: json['count'] as int,
//       next: json['next'] as String?,
//       previous: json['previous'] as String?,
//       // CRITICAL FIX: Use 'as List?' to handle nulls safely and map to FiveAItem
//       results: (json['results'] as List?)
//               ?.map((e) => FiveAItem.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           [],
//     );
//   }
// }

// /// 2. WRAPPER ITEM MODEL
// /// Represents an item in the "results" list: {"id": 4, "project_data": {...}}
// class FiveAItem {
//   final int id;
//   final ProjectResponse projectData;

//   FiveAItem({
//     required this.id,
//     required this.projectData,
//   });

//   factory FiveAItem.fromJson(Map<String, dynamic> json) {
//     return FiveAItem(
//       id: json['id'] as int,
//       projectData: ProjectResponse.fromJson(json['project_data'] as Map<String, dynamic>),
//     );
//   }
// }

// /// 3. CORE PROJECT DATA MODEL
// class ProjectResponse {
//   final int? id;
//   final String? projectLogo;
//   final String? socUpload;

//   final List<UserResponse> businessDeveloperData;
//   final List<UserResponse> projectManagerData;
//   final List<UserResponse> developerData;
//   final List<UserResponse> teamLeadData;
//   final List<UserResponse> internsData;
//   final List<UserResponse> financeData;
//   final List<UserResponse> itSupportData;
//   final List<ClientResponse> clientData;

//   final String? projectName;
//   final String? projectDescription;
//   final String? projectType;
//   final String? agentMail;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final List<ActivityResponse> activities;

//   ProjectResponse({
//     this.id,
//     this.projectLogo,
//     this.socUpload,
//     this.businessDeveloperData = const [],
//     this.projectManagerData = const [],
//     this.developerData = const [],
//     this.teamLeadData = const [],
//     this.internsData = const [],
//     this.financeData = const [],
//     this.itSupportData = const [],
//     this.clientData = const [],
//     this.projectName,
//     this.projectDescription,
//     this.projectType,
//     this.agentMail,
//     this.createdAt,
//     this.updatedAt,
//     this.activities = const [],
//   });

//   factory ProjectResponse.fromJson(Map<String, dynamic> json) {
//     return ProjectResponse(
//       id: json['id'] as int?,
//       projectLogo: json['project_logo'] as String?,
//       socUpload: json['soc_upload'] as String?,
      
//       businessDeveloperData: (json['business_developer_data'] as List<dynamic>?)
//               ?.map((e) => UserResponse.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           const [],
//       projectManagerData: (json['project_manager_data'] as List<dynamic>?)
//               ?.map((e) => UserResponse.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           const [],
//       developerData: (json['developer_data'] as List<dynamic>?)
//               ?.map((e) => UserResponse.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           const [],
//       teamLeadData: (json['team_lead_data'] as List<dynamic>?)
//               ?.map((e) => UserResponse.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           const [],
//       internsData: (json['interns_data'] as List<dynamic>?)
//               ?.map((e) => UserResponse.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           const [],
//       financeData: (json['finance_data'] as List<dynamic>?)
//               ?.map((e) => UserResponse.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           const [],
//       itSupportData: (json['it_support_data'] as List<dynamic>?)
//               ?.map((e) => UserResponse.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           const [],
//       clientData: (json['client_data'] as List<dynamic>?)
//               ?.map((e) => ClientResponse.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           const [],

//       projectName: json['project_name'] as String?,
//       projectDescription: json['project_description'] as String?,
//       projectType: json['project_type'] as String?,
//       agentMail: json['agent_mail'] as String?,
      
//       createdAt: json['created_at'] != null
//           ? DateTime.tryParse(json['created_at'])
//           : null,
//       updatedAt: json['updated_at'] != null
//           ? DateTime.tryParse(json['updated_at'])
//           : null,
//       activities: (json['activities'] as List<dynamic>?)
//               ?.map((e) => ActivityResponse.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           const [],
//     );
//   }
// }

// /// 4. USER DATA MODEL
// class UserResponse {
//   final int? id;
//   final String? userName;
//   final String? userEmail;
//   final String? designation;
//   final RoleDetail? roleDetail;
//   final String? userLocation;
//   final String? workLocation;
//   final String? profilePicture;
//   final bool? isActive;
//   final bool? isStaff;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final bool? isExternalAuth;
//   final bool? productionSupport;

//   UserResponse({
//     this.id,
//     this.userName,
//     this.userEmail,
//     this.designation,
//     this.roleDetail,
//     this.userLocation,
//     this.workLocation,
//     this.profilePicture,
//     this.isActive,
//     this.isStaff,
//     this.createdAt,
//     this.updatedAt,
//     this.isExternalAuth,
//     this.productionSupport,
//   });

//   factory UserResponse.fromJson(Map<String, dynamic> json) {
//     return UserResponse(
//       id: json['id'] as int?,
//       userName: json['user_name'] as String?,
//       userEmail: json['user_email'] as String?,
//       designation: json['designation'] as String?,
//       roleDetail: json['role_detail'] != null
//           ? RoleDetail.fromJson(json['role_detail'] as Map<String, dynamic>)
//           : null,
//       userLocation: json['user_location'] as String?,
//       workLocation: json['work_location'] as String?,
//       profilePicture: json['profile_picture'] as String?,
//       isActive: json['is_active'] as bool?,
//       isStaff: json['is_staff'] as bool?,
//       createdAt: json['created_at'] != null
//           ? DateTime.tryParse(json['created_at'])
//           : null,
//       updatedAt: json['updated_at'] != null
//           ? DateTime.tryParse(json['updated_at'])
//           : null,
//       isExternalAuth: json['is_external_auth'] as bool?,
//       productionSupport: json['production_support'] as bool?,
//     );
//   }
// }

// /// 5. ROLE DETAIL MODEL
// class RoleDetail {
//   final int id;
//   final List<Permission> permissions;
//   final String? name;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;

//   RoleDetail({
//     required this.id,
//     required this.permissions,
//     this.name,
//     this.createdAt,
//     this.updatedAt,
//   });

//   factory RoleDetail.fromJson(Map<String, dynamic> json) {
//     return RoleDetail(
//       id: json['id'] as int,
//       permissions: (json['permissions'] as List<dynamic>?)
//               ?.map((e) => Permission.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           [],
//       name: json['name'] as String?,
//       createdAt: json['created_at'] != null
//           ? DateTime.tryParse(json['created_at'])
//           : null,
//       updatedAt: json['updated_at'] != null
//           ? DateTime.tryParse(json['updated_at'])
//           : null,
//     );
//   }
// }

// /// 6. PERMISSION MODEL
// class Permission {
//   final String access;
//   final String module;

//   Permission({
//     required this.access,
//     required this.module,
//   });

//   factory Permission.fromJson(Map<String, dynamic> json) {
//     return Permission(
//       access: json['access'] as String,
//       module: json['module'] as String,
//     );
//   }
// }

// /// 7. CLIENT DATA MODEL
// class ClientResponse {
//   final int? id;
//   final String? profilePicture;
//   final String? companyName;
//   final String? contactPerson;
//   final String? contactEmail;
//   final String? contactAddress;
//   final String? country;
//   final String? state;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final bool? offboarded;
//   final DateTime? offboardedDate;
//   final DateTime? clientOnboardDate;
//   final List<AdditionalEmail> additionalEmail;

//   ClientResponse({
//     this.id,
//     this.profilePicture,
//     this.companyName,
//     this.contactPerson,
//     this.contactEmail,
//     this.contactAddress,
//     this.country,
//     this.state,
//     this.createdAt,
//     this.updatedAt,
//     this.offboarded,
//     this.offboardedDate,
//     this.clientOnboardDate,
//     this.additionalEmail = const [],
//   });

//   factory ClientResponse.fromJson(Map<String, dynamic> json) {
//     return ClientResponse(
//       id: json['id'] as int?,
//       profilePicture: json['profile_picture'] as String?,
//       companyName: json['company_name'] as String?,
//       contactPerson: json['contact_person'] as String?,
//       contactEmail: json['contact_email'] as String?,
//       contactAddress: json['contact_address'] as String?,
//       country: json['country'] as String?,
//       state: json['state'] as String?,
//       createdAt: json['created_at'] != null
//           ? DateTime.tryParse(json['created_at'])
//           : null,
//       updatedAt: json['updated_at'] != null
//           ? DateTime.tryParse(json['updated_at'])
//           : null,
//       offboarded: json['offboarded'] as bool?,
//       offboardedDate: json['offboarded_date'] != null
//           ? DateTime.tryParse(json['offboarded_date'])
//           : null,
//       clientOnboardDate: json['client_onboard_date'] != null
//           ? DateTime.tryParse(json['client_onboard_date'])
//           : null,
//       additionalEmail: (json['additional_email'] as List<dynamic>?)
//               ?.map((e) => AdditionalEmail.fromJson(e as Map<String, dynamic>))
//               .toList() ??
//           [],
//     );
//   }
// }

// /// 8. ADDITIONAL EMAIL MODEL (Nested in ClientResponse)
// class AdditionalEmail {
//   final int? id;
//   final String? email;

//   AdditionalEmail({
//     this.id,
//     this.email,
//   });

//   factory AdditionalEmail.fromJson(Map<String, dynamic> json) {
//     return AdditionalEmail(
//       id: json['id'] as int?,
//       email: json['email'] as String?,
//     );
//   }
// }

// /// 9. ACTIVITY MODEL
// class ActivityResponse {
//   final int id;
//   final int projectId;
//   final int userId;
//   final String stage;
//   final String remarks;
//   final bool checked;
//   final String createdAt;
//   final String updatedAt;
//   final UserResponse user;

//   ActivityResponse({
//     required this.id,
//     required this.projectId,
//     required this.userId,
//     required this.stage,
//     required this.remarks,
//     required this.checked,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.user,
//   });

//   factory ActivityResponse.fromJson(Map<String, dynamic> json) {
//     return ActivityResponse(
//       id: json['id'] as int,
//       projectId: json['project_id'] as int,
//       userId: json['user_id'] as int,
//       stage: json['stage'] as String,
//       remarks: json['remarks'] as String,
//       checked: json['checked'] as bool,
//       createdAt: json['created_at'] as String,
//       updatedAt: json['updated_at'] as String,
//       user: UserResponse.fromJson(json['user'] as Map<String, dynamic>),
//     );
//   }
// }
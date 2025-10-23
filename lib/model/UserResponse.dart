class UserResponse {
    UserResponse({
        required this.id,
        required this.userName,
        required this.userEmail,
        required this.designation,
        required this.roleDetail,
        required this.userLocation,
        required this.workLocation,
        required this.profilePicture,
        required this.isActive,
        required this.isStaff,
        required this.createdAt,
        required this.updatedAt,
        required this.isExternalAuth,
        required this.productionSupport,
    });

    final int? id;
    final String? userName;
    final String? userEmail;
    final String? designation;
    final RoleDetail? roleDetail;
    final String? userLocation;
    final String? workLocation;
    final String? profilePicture;
    final bool? isActive;
    final bool? isStaff;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final bool? isExternalAuth;
    final bool? productionSupport;

    factory UserResponse.fromJson(Map<String, dynamic> json){ 
        return UserResponse(
            id: json["id"],
            userName: json["user_name"],
            userEmail: json["user_email"],
            designation: json["designation"],
            roleDetail: json["role_detail"] == null ? null : RoleDetail.fromJson(json["role_detail"]),
            userLocation: json["user_location"],
            workLocation: json["work_location"],
            profilePicture: json["profile_picture"],
            isActive: json["is_active"],
            isStaff: json["is_staff"],
            createdAt: DateTime.tryParse(json["created_at"] ?? ""),
            updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
            isExternalAuth: json["is_external_auth"],
            productionSupport: json["production_support"],
        );
    }

}

class RoleDetail {
    RoleDetail({
        required this.id,
        required this.permissions,
        required this.name,
        required this.createdAt,
        required this.updatedAt,
    });

    final int? id;
    final List<Permission> permissions;
    final String? name;
    final DateTime? createdAt;
    final DateTime? updatedAt;

    factory RoleDetail.fromJson(Map<String, dynamic> json){ 
        return RoleDetail(
            id: json["id"],
            permissions: json["permissions"] == null ? [] : List<Permission>.from(json["permissions"]!.map((x) => Permission.fromJson(x))),
            name: json["name"],
            createdAt: DateTime.tryParse(json["created_at"] ?? ""),
            updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
        );
    }

}

class Permission {
    Permission({
        required this.access,
        required this.module,
    });

    final String? access;
    final String? module;

    factory Permission.fromJson(Map<String, dynamic> json){ 
        return Permission(
            access: json["access"],
            module: json["module"],
        );
    }

}

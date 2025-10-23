import 'package:flutter_application_cxo/model/UserResponse.dart';

class ActivityResponse {
    ActivityResponse({
        this.id,
         this.projectId,
         this.userId,
         this.stage,
         this.remarks,
         this.checked,
         this.createdAt,
         this.updatedAt,
         this.user,
    });

    final int? id;
    final int? projectId;
    final int? userId;
    final String? stage;
    final String? remarks;
    bool? checked;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final UserResponse? user;

    factory ActivityResponse.fromJson(Map<String, dynamic> json){ 
        return ActivityResponse(
            id: json["id"],
            projectId: json["project_id"],
            userId: json["user_id"],
            stage: json["stage"],
            remarks: json["remarks"],
            checked: json["checked"],
            createdAt: DateTime.tryParse(json["created_at"] ?? ""),
            updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
            user: json["user"] == null ? null : UserResponse.fromJson(json["user"]),
        );
    }

}

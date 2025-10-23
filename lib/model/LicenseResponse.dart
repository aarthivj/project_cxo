import 'package:flutter_application_cxo/model/MachineResponse.dart';
import 'package:flutter_application_cxo/model/ProjectResponse.dart';

class LicenseResponse {
    LicenseResponse({
         this.id,
         this.machineData,
         this.projectData,
         this.license,
         this.createdAt,
         this.updatedAt,
    });

    final int? id;
    final MachineResult? machineData;
    final ProjectResponse? projectData;
    final String? license;
    final DateTime? createdAt;
    final DateTime? updatedAt;

    factory LicenseResponse.fromJson(Map<String, dynamic> json){ 
        return LicenseResponse(
            id: json["id"],
            machineData: json["machine_data"] == null ? null : MachineResult.fromJson(json["machine_data"]),
            projectData: json["project_data"] == null ? null : ProjectResponse.fromJson(json["project_data"]),
            license: json["license"],
            createdAt: DateTime.tryParse(json["created_at"] ?? ""),
            updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
        );
    }

}

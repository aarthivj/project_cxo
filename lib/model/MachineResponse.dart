import 'package:flutter_application_cxo/model/ProjectResponse.dart';

class MachineResponse {
    MachineResponse({
        required this.count,
        required this.next,
        required this.previous,
        required this.results,
    });

    final int? count;
    final String? next;
    final dynamic previous;
    final List<MachineResult>? results;

    factory MachineResponse.fromJson(Map<String, dynamic> json){ 
        return MachineResponse(
            count: json["count"],
            next: json["next"],
            previous: json["previous"],
            results: json["results"] == null ? [] : List<MachineResult>.from(json["results"]!.map((x) => MachineResult.fromJson(x))),
        );
    }

}

class MachineResult {
    MachineResult({
         this.id,
         this.projectData,
         this.hosted,
          this.ipAddress,
          this.environment,
          this.ram,
          this.createdAt,
          this.updatedAt,
          this.core,
          this.processor,
          this.storage,
          this.storageUnit,
          this.missionName,
          this.provider,
    });

    final int? id;
    final ProjectResponse? projectData;
    final String? hosted;
    final String? ipAddress;
    final String? environment;
    final String? ram;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final String? core;
    final String? processor;
    final String? storage;
    final String? storageUnit;
    final String? missionName;
    final String? provider;

    factory MachineResult.fromJson(Map<String, dynamic> json){ 
        return MachineResult(
            id: json["id"],
            projectData: json["project_data"] == null ? null : ProjectResponse.fromJson(json["project_data"]),
            hosted: json["hosted"],
            ipAddress: json["ip_address"],
            environment: json["environment"],
            ram: json["ram"],
            createdAt: DateTime.tryParse(json["created_at"] ?? ""),
            updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
            core: json["core"],
            processor: json["processor"],
            storage: json["storage"],
            storageUnit: json["storage_unit"],
            missionName: json["mission_name"],
            provider: json["provider"],
        );
    }

}

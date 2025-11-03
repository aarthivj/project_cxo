import 'dart:convert';

import 'package:flutter_application_cxo/model/ClientResponse.dart';

class ClientDebarredResponse {
  int? id;
  String? profilePicture;
  String? companyName;
  String? contactPerson;
  String? contactEmail;
  String? contactAddress;
  String? country;
  String? state;
  String? createdAt;
  String? updatedAt;
  bool? offboarded;
  String? offboardedDate;
  String? clientOnboardDate;
  List<AdditionalEmail>? additionalEmail;
  dynamic externalClientId;

  ClientDebarredResponse({
    this.id,
    this.profilePicture,
    this.companyName,
    this.contactPerson,
    this.contactEmail,
    this.contactAddress,
    this.country,
    this.state,
    this.createdAt,
    this.updatedAt,
    this.offboarded,
    this.offboardedDate,
    this.clientOnboardDate,
    this.additionalEmail,
    this.externalClientId,
  });

  // Getter for compatibility with your ClientScreen
  // This maps 'offboarded' to 'isDebarred'
  bool get isDebarred => offboarded ?? false;

  factory ClientDebarredResponse.fromJson(Map<String, dynamic> json) => ClientDebarredResponse(
        id: json["id"],
        profilePicture: json["profile_picture"],
        companyName: json["company_name"],
        contactPerson: json["contact_person"],
        contactEmail: json["contact_email"],
        contactAddress: json["contact_address"],
        country: json["country"],
        state: json["state"],
        createdAt: json["created_at"], // Kept as String?
        updatedAt: json["updated_at"], // Kept as String?
        offboarded: json["offboarded"],
        offboardedDate: json["offboarded_date"], // Kept as String?
        clientOnboardDate: json["client_onboard_date"], // Kept as String?
        additionalEmail: json["additional_email"] == null
            ? []
            : List<AdditionalEmail>.from(json["additional_email"]!
                .map((x) => AdditionalEmail.fromJson(x))),
        externalClientId: json["external_client_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "profile_picture": profilePicture,
        "company_name": companyName,
        "contact_person": contactPerson,
        "contact_email": contactEmail,
        "contact_address": contactAddress,
        "country": country,
        "state": state,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "offboarded": offboarded,
        "offboarded_date": offboardedDate,
        "client_onboard_date": clientOnboardDate,
        "additional_email": additionalEmail == null
            ? []
            : List<dynamic>.from(additionalEmail!.map((x) => x.toJson())),
        "external_client_id": externalClientId,
      };
}


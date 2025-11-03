class ClientResponse {
    ClientResponse({
        required this.id,
        required this.profilePicture,
        required this.companyName,
        required this.contactPerson,
        required this.contactEmail,
        required this.contactAddress,
        required this.country,
        required this.state,
        required this.createdAt,
        required this.updatedAt,
        required this.offboarded,
        required this.offboardedDate,
        required this.clientOnboardDate,
        required this.additionalEmail,
    });

    final int? id;
    final String? profilePicture;
    final String? companyName;
    final String? contactPerson;
    final String? contactEmail;
    final String? contactAddress;
    final String? country;
    final String? state;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final bool? offboarded;
    final DateTime? offboardedDate;
    final DateTime? clientOnboardDate;
    final List<AdditionalEmail> additionalEmail;

    factory ClientResponse.fromJson(Map<String, dynamic> json){ 
        return ClientResponse(
            id: json["id"],
            profilePicture: json["profile_picture"],
            companyName: json["company_name"],
            contactPerson: json["contact_person"],
            contactEmail: json["contact_email"],
            contactAddress: json["contact_address"],
            country: json["country"],
            state: json["state"],
            createdAt: DateTime.tryParse(json["created_at"] ?? ""),
            updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
            offboarded: json["offboarded"],
            offboardedDate: DateTime.tryParse(json["offboarded_date"] ?? ""),
            clientOnboardDate: DateTime.tryParse(json["client_onboard_date"] ?? ""),
            additionalEmail: json["additional_email"] == null ? [] : List<AdditionalEmail>.from(json["additional_email"]!.map((x) => AdditionalEmail.fromJson(x))),
        );
    }

}

class AdditionalEmail {
    AdditionalEmail({
        this.email,
    });

    final String? email;

    factory AdditionalEmail.fromJson(Map<String, dynamic> json){ 
        return AdditionalEmail(
            email: json["email"],
        );
    }

    Map<String, dynamic> toJson() => {
        "email": email,
      };

}

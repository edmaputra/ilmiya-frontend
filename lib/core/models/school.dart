class SchoolResponse {
  final String id;
  final String tenantId;
  final String name;
  final String institutionCode;
  final String address;
  final String contactEmail;
  final String contactPhone;
  final String? logoUrl;
  final String status;
  final String? governmentRegistrationNumber;
  final String? registrationType;
  final String? accreditationStatus;
  final String? accreditationBody;
  final String? accreditationValidUntil;
  final List<String> workingDays;
  final String gradingPreference;
  final String termLayout;
  final String createdAt;
  final String updatedAt;

  SchoolResponse({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.institutionCode,
    required this.address,
    required this.contactEmail,
    required this.contactPhone,
    this.logoUrl,
    required this.status,
    this.governmentRegistrationNumber,
    this.registrationType,
    this.accreditationStatus,
    this.accreditationBody,
    this.accreditationValidUntil,
    required this.workingDays,
    required this.gradingPreference,
    required this.termLayout,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SchoolResponse.fromJson(Map<String, dynamic> json) {
    return SchoolResponse(
      id: json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      institutionCode: json['institutionCode'] as String? ?? '',
      address: json['address'] as String? ?? '',
      contactEmail: json['contactEmail'] as String? ?? '',
      contactPhone: json['contactPhone'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      governmentRegistrationNumber:
          json['governmentRegistrationNumber'] as String?,
      registrationType: json['registrationType'] as String?,
      accreditationStatus: json['accreditationStatus'] as String?,
      accreditationBody: json['accreditationBody'] as String?,
      accreditationValidUntil: json['accreditationValidUntil'] as String?,
      workingDays: (json['workingDays'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY'],
      gradingPreference: json['gradingPreference'] as String? ??
          'DESCRIPTIVE_KURIKULUM_MERDEKA',
      termLayout: json['termLayout'] as String? ?? 'SEMESTER',
      createdAt:
          json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt:
          json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'name': name,
      'institutionCode': institutionCode,
      'address': address,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      if (logoUrl != null) 'logoUrl': logoUrl,
      'status': status,
      if (governmentRegistrationNumber != null)
        'governmentRegistrationNumber': governmentRegistrationNumber,
      if (registrationType != null) 'registrationType': registrationType,
      if (accreditationStatus != null)
        'accreditationStatus': accreditationStatus,
      if (accreditationBody != null) 'accreditationBody': accreditationBody,
      if (accreditationValidUntil != null)
        'accreditationValidUntil': accreditationValidUntil,
      'workingDays': workingDays,
      'gradingPreference': gradingPreference,
      'termLayout': termLayout,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  SchoolResponse copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? institutionCode,
    String? address,
    String? contactEmail,
    String? contactPhone,
    String? logoUrl,
    String? status,
    String? governmentRegistrationNumber,
    String? registrationType,
    String? accreditationStatus,
    String? accreditationBody,
    String? accreditationValidUntil,
    List<String>? workingDays,
    String? gradingPreference,
    String? termLayout,
    String? createdAt,
    String? updatedAt,
  }) {
    return SchoolResponse(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      institutionCode: institutionCode ?? this.institutionCode,
      address: address ?? this.address,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      logoUrl: logoUrl ?? this.logoUrl,
      status: status ?? this.status,
      governmentRegistrationNumber:
          governmentRegistrationNumber ?? this.governmentRegistrationNumber,
      registrationType: registrationType ?? this.registrationType,
      accreditationStatus: accreditationStatus ?? this.accreditationStatus,
      accreditationBody: accreditationBody ?? this.accreditationBody,
      accreditationValidUntil:
          accreditationValidUntil ?? this.accreditationValidUntil,
      workingDays: workingDays ?? this.workingDays,
      gradingPreference: gradingPreference ?? this.gradingPreference,
      termLayout: termLayout ?? this.termLayout,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RegisterSchoolRequest {
  final String tenantId;
  final String name;
  final String institutionCode;
  final String address;
  final String contactEmail;
  final String contactPhone;

  RegisterSchoolRequest({
    required this.tenantId,
    required this.name,
    required this.institutionCode,
    required this.address,
    required this.contactEmail,
    required this.contactPhone,
  });

  Map<String, dynamic> toJson() => {
        'tenantId': tenantId,
        'name': name,
        'institutionCode': institutionCode,
        'address': address,
        'contactEmail': contactEmail,
        'contactPhone': contactPhone,
      };
}

class UpdateSchoolRequest {
  final String name;
  final String address;
  final String contactEmail;
  final String contactPhone;
  final String? logoUrl;
  final String? governmentRegistrationNumber;
  final String? registrationType;
  final String? accreditationStatus;
  final String? accreditationBody;
  final String? accreditationValidUntil;

  UpdateSchoolRequest({
    required this.name,
    required this.address,
    required this.contactEmail,
    required this.contactPhone,
    this.logoUrl,
    this.governmentRegistrationNumber,
    this.registrationType,
    this.accreditationStatus,
    this.accreditationBody,
    this.accreditationValidUntil,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'contactEmail': contactEmail,
        'contactPhone': contactPhone,
        if (logoUrl != null) 'logoUrl': logoUrl,
        if (governmentRegistrationNumber != null)
          'governmentRegistrationNumber': governmentRegistrationNumber,
        if (registrationType != null) 'registrationType': registrationType,
        if (accreditationStatus != null)
          'accreditationStatus': accreditationStatus,
        if (accreditationBody != null) 'accreditationBody': accreditationBody,
        if (accreditationValidUntil != null)
          'accreditationValidUntil': accreditationValidUntil,
      };
}

class ConfigureSchoolSettingsRequest {
  final List<String> workingDays;
  final String gradingPreference;
  final String termLayout;

  ConfigureSchoolSettingsRequest({
    required this.workingDays,
    required this.gradingPreference,
    required this.termLayout,
  });

  Map<String, dynamic> toJson() => {
        'workingDays': workingDays,
        'gradingPreference': gradingPreference,
        'termLayout': termLayout,
      };
}

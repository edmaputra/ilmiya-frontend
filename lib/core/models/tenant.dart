class TenantResponse {
  final String id;
  final String tenantId;
  final String name;
  final String? legalEntityNumber;
  final String? registrationType;
  final String address;
  final String contactEmail;
  final String contactPhone;
  final String? logoUrl;
  final String status;
  final String createdAt;
  final String updatedAt;

  TenantResponse({
    required this.id,
    String? tenantId,
    required this.name,
    this.legalEntityNumber,
    this.registrationType,
    required this.address,
    required this.contactEmail,
    required this.contactPhone,
    this.logoUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  }) : tenantId = tenantId ?? id;

  factory TenantResponse.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? json['tenantId'] as String? ?? '';
    return TenantResponse(
      id: id,
      tenantId: json['tenantId'] as String? ?? id,
      name: json['name'] as String? ?? '',
      legalEntityNumber: json['legalEntityNumber'] as String?,
      registrationType: json['registrationType'] as String?,
      address: json['address'] as String? ?? '',
      contactEmail: json['contactEmail'] as String? ?? '',
      contactPhone: json['contactPhone'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
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
      if (legalEntityNumber != null) 'legalEntityNumber': legalEntityNumber,
      if (registrationType != null) 'registrationType': registrationType,
      'address': address,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      if (logoUrl != null) 'logoUrl': logoUrl,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  TenantResponse copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? legalEntityNumber,
    String? registrationType,
    String? address,
    String? contactEmail,
    String? contactPhone,
    String? logoUrl,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return TenantResponse(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      legalEntityNumber: legalEntityNumber ?? this.legalEntityNumber,
      registrationType: registrationType ?? this.registrationType,
      address: address ?? this.address,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      logoUrl: logoUrl ?? this.logoUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CreateTenantRequest {
  final String tenantId;
  final String name;
  final String? legalEntityNumber;
  final String? registrationType;
  final String address;
  final String contactEmail;
  final String contactPhone;
  final String? logoUrl;

  CreateTenantRequest({
    required this.tenantId,
    required this.name,
    this.legalEntityNumber,
    this.registrationType,
    required this.address,
    required this.contactEmail,
    required this.contactPhone,
    this.logoUrl,
  });

  Map<String, dynamic> toJson() => {
        'tenantId': tenantId,
        'name': name,
        if (legalEntityNumber != null) 'legalEntityNumber': legalEntityNumber,
        if (registrationType != null) 'registrationType': registrationType,
        'address': address,
        'contactEmail': contactEmail,
        'contactPhone': contactPhone,
        if (logoUrl != null) 'logoUrl': logoUrl,
      };
}

class UpdateTenantRequest {
  final String name;
  final String address;
  final String contactEmail;
  final String contactPhone;
  final String? logoUrl;
  final String? legalEntityNumber;
  final String? registrationType;
  final String status;

  UpdateTenantRequest({
    required this.name,
    required this.address,
    required this.contactEmail,
    required this.contactPhone,
    this.logoUrl,
    this.legalEntityNumber,
    this.registrationType,
    this.status = 'ACTIVE',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'contactEmail': contactEmail,
        'contactPhone': contactPhone,
        if (logoUrl != null) 'logoUrl': logoUrl,
        if (legalEntityNumber != null) 'legalEntityNumber': legalEntityNumber,
        if (registrationType != null) 'registrationType': registrationType,
        'status': status,
      };
}

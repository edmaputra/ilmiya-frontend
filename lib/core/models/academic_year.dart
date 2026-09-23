class AcademicTermResponse {
  final String id;
  final String academicYearId;
  final String name;
  final String displayName;
  final String type;
  final String startDate;
  final String endDate;
  final String status;
  final String createdAt;
  final String updatedAt;

  AcademicTermResponse({
    required this.id,
    required this.academicYearId,
    required this.name,
    required this.displayName,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AcademicTermResponse.fromJson(Map<String, dynamic> json) {
    return AcademicTermResponse(
      id: json['id'] as String? ?? '',
      academicYearId: json['academicYearId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      type: json['type'] as String? ?? 'SEMESTER_1',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      status: json['status'] as String? ?? 'PLANNED',
      createdAt:
          json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt:
          json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'academicYearId': academicYearId,
        'name': name,
        'displayName': displayName,
        'type': type,
        'startDate': startDate,
        'endDate': endDate,
        'status': status,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  AcademicTermResponse copyWith({
    String? id,
    String? academicYearId,
    String? name,
    String? displayName,
    String? type,
    String? startDate,
    String? endDate,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return AcademicTermResponse(
      id: id ?? this.id,
      academicYearId: academicYearId ?? this.academicYearId,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AcademicYearResponse {
  final String id;
  final String tenantId;
  final String name;
  final String startDate;
  final String endDate;
  final String status;
  final List<AcademicTermResponse> terms;
  final String createdAt;
  final String updatedAt;

  AcademicYearResponse({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.terms,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AcademicYearResponse.fromJson(Map<String, dynamic> json) {
    return AcademicYearResponse(
      id: json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      status: json['status'] as String? ?? 'PLANNED',
      terms: (json['terms'] as List<dynamic>?)
              ?.map((t) =>
                  AcademicTermResponse.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt:
          json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt:
          json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenantId': tenantId,
        'name': name,
        'startDate': startDate,
        'endDate': endDate,
        'status': status,
        'terms': terms.map((t) => t.toJson()).toList(),
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  AcademicYearResponse copyWith({
    String? id,
    String? tenantId,
    String? name,
    String? startDate,
    String? endDate,
    String? status,
    List<AcademicTermResponse>? terms,
    String? createdAt,
    String? updatedAt,
  }) {
    return AcademicYearResponse(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      terms: terms ?? this.terms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CreateAcademicYearRequest {
  final String name;
  final String startDate;
  final String endDate;

  CreateAcademicYearRequest({
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'startDate': startDate,
        'endDate': endDate,
      };
}

class AddAcademicTermRequest {
  final String name;
  final String displayName;
  final String type;
  final String startDate;
  final String endDate;

  AddAcademicTermRequest({
    required this.name,
    required this.displayName,
    required this.type,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'displayName': displayName,
        'type': type,
        'startDate': startDate,
        'endDate': endDate,
      };
}

/// Report status enum (updated to match new API)
enum ReportStatus {
  pending,
  processing,
  completed,
  rejected;

  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.processing:
        return 'Processing';
      case ReportStatus.completed:
        return 'Completed';
      case ReportStatus.rejected:
        return 'Rejected';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case ReportStatus.pending:
        return 'قيد الانتظار';
      case ReportStatus.processing:
        return 'قيد المعالجة';
      case ReportStatus.completed:
        return 'مكتمل';
      case ReportStatus.rejected:
        return 'مرفوض';
    }
  }

  static ReportStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ReportStatus.pending;
      case 'processing':
        return ReportStatus.processing;
      case 'completed':
        return ReportStatus.completed;
      case 'rejected':
        return ReportStatus.rejected;
      default:
        return ReportStatus.pending;
    }
  }
}

/// Damage level enum (updated to match new API)
enum DamageLevel {
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch (this) {
      case DamageLevel.low:
        return 'Low';
      case DamageLevel.medium:
        return 'Medium';
      case DamageLevel.high:
        return 'High';
      case DamageLevel.critical:
        return 'Critical';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case DamageLevel.low:
        return 'طفيف';
      case DamageLevel.medium:
        return 'متوسط';
      case DamageLevel.high:
        return 'شديد';
      case DamageLevel.critical:
        return 'حرج';
    }
  }

  static DamageLevel fromString(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return DamageLevel.low;
      case 'medium':
        return DamageLevel.medium;
      case 'high':
        return DamageLevel.high;
      case 'critical':
        return DamageLevel.critical;
      default:
        return DamageLevel.low;
    }
  }
}

/// User info in report
class ReportUser {
  final int id;
  final String name;

  ReportUser({
    required this.id,
    required this.name,
  });

  factory ReportUser.fromJson(Map<String, dynamic> json) {
    return ReportUser(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

/// Location information
class ReportLocation {
  final String raw;
  final String? normalized;
  final ReportCoordinates? coordinates;

  ReportLocation({
    required this.raw,
    this.normalized,
    this.coordinates,
  });

  factory ReportLocation.fromJson(Map<String, dynamic> json) {
    return ReportLocation(
      raw: json['raw'] as String,
      normalized: json['normalized'] as String?,
      coordinates: json['coordinates'] != null
          ? ReportCoordinates.fromJson(json['coordinates'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'raw': raw,
      'normalized': normalized,
      'coordinates': coordinates?.toJson(),
    };
  }
}

/// GPS coordinates
class ReportCoordinates {
  final double latitude;
  final double longitude;

  ReportCoordinates({
    required this.latitude,
    required this.longitude,
  });

  factory ReportCoordinates.fromJson(Map<String, dynamic> json) {
    return ReportCoordinates(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

/// Description information
class ReportDescription {
  final String raw;
  final String? aiAnalysis;

  ReportDescription({
    required this.raw,
    this.aiAnalysis,
  });

  factory ReportDescription.fromJson(Map<String, dynamic> json) {
    return ReportDescription(
      raw: json['raw'] as String,
      aiAnalysis: json['ai_analysis'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'raw': raw,
      'ai_analysis': aiAnalysis,
    };
  }
}

/// Damage assessment information
class DamageAssessment {
  final DamageLevel level;
  final ReportStatus status;

  DamageAssessment({
    required this.level,
    required this.status,
  });

  factory DamageAssessment.fromJson(Map<String, dynamic> json) {
    return DamageAssessment(
      level: json['level'] != null
          ? DamageLevel.fromString(json['level'] as String)
          : DamageLevel.low,
      status: ReportStatus.fromString(json['status'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level.name,
      'status': status.name,
    };
  }
}

/// Main Report model (updated to match new API structure)
class Report {
  final int id;
  final ReportUser user;
  final String imageUrl;
  final ReportLocation location;
  final ReportDescription description;
  final DamageAssessment damageAssessment;
  final DateTime createdAt;
  final DateTime updatedAt;

  Report({
    required this.id,
    required this.user,
    required this.imageUrl,
    required this.location,
    required this.description,
    required this.damageAssessment,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create Report from JSON (new API response format)
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as int,
      user: ReportUser.fromJson(json['user'] as Map<String, dynamic>),
      imageUrl: json['image_url'] as String,
      location: ReportLocation.fromJson(json['location'] as Map<String, dynamic>),
      description: ReportDescription.fromJson(json['description'] as Map<String, dynamic>),
      damageAssessment: DamageAssessment.fromJson(json['damage_assessment'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert Report to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'image_url': imageUrl,
      'location': location.toJson(),
      'description': description.toJson(),
      'damage_assessment': damageAssessment.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Get display status
  String get displayStatus => damageAssessment.status.displayName;

  /// Get display status in Arabic
  String get displayStatusArabic => damageAssessment.status.displayNameArabic;

  /// Get display damage level
  String get displayDamageLevel => damageAssessment.level.displayName;

  /// Get display damage level in Arabic
  String get displayDamageLevelArabic => damageAssessment.level.displayNameArabic;

  /// Get formatted creation date
  String get formattedCreatedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// Get formatted creation date with time
  String get formattedCreatedDateTime {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  /// Get formatted location coordinates
  String get formattedCoordinates {
    if (location.coordinates == null) {
      return 'Location not available';
    }
    return '${location.coordinates!.latitude.toStringAsFixed(6)}, ${location.coordinates!.longitude.toStringAsFixed(6)}';
  }

  /// Check if report is completed
  bool get isCompleted => damageAssessment.status == ReportStatus.completed;

  /// Check if report is pending
  bool get isPending => damageAssessment.status == ReportStatus.pending;

  /// Check if report is processing
  bool get isProcessing => damageAssessment.status == ReportStatus.processing;

  /// Check if report is rejected
  bool get isRejected => damageAssessment.status == ReportStatus.rejected;

  @override
  String toString() {
    return 'Report(id: $id, location: ${location.raw}, status: ${damageAssessment.status.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Report && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

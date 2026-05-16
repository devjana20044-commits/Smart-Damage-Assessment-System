import 'dart:convert';

class DraftReport {
  final String id;
  final String location;
  final String description;
  final double? latitude;
  final double? longitude;
  final List<String> imagePaths;
  final String? pdfPath;
  final List<String> videoLinks;
  final DateTime createdAt;
  final DateTime updatedAt;

  DraftReport({
    required this.id,
    required this.location,
    this.description = '',
    this.latitude,
    this.longitude,
    this.imagePaths = const [],
    this.pdfPath,
    this.videoLinks = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'location': location,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'imagePaths': imagePaths,
        'pdfPath': pdfPath,
        'videoLinks': videoLinks,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory DraftReport.fromJson(Map<String, dynamic> json) => DraftReport(
        id: json['id'] as String,
        location: json['location'] as String,
        description: json['description'] as String? ?? '',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        imagePaths: List<String>.from(json['imagePaths'] as List? ?? []),
        pdfPath: json['pdfPath'] as String?,
        videoLinks: List<String>.from(json['videoLinks'] as List? ?? []),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  static String encodeList(List<DraftReport> drafts) => jsonEncode(
        drafts.map((d) => d.toJson()).toList(),
      );

  static List<DraftReport> decodeList(String encoded) {
    final list = jsonDecode(encoded) as List;
    return list.map((e) => DraftReport.fromJson(e as Map<String, dynamic>)).toList();
  }

  DraftReport copyWith({
    String? location,
    String? description,
    double? latitude,
    double? longitude,
    List<String>? imagePaths,
    String? pdfPath,
    List<String>? videoLinks,
  }) =>
      DraftReport(
        id: id,
        location: location ?? this.location,
        description: description ?? this.description,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        imagePaths: imagePaths ?? this.imagePaths,
        pdfPath: pdfPath ?? this.pdfPath,
        videoLinks: videoLinks ?? this.videoLinks,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}

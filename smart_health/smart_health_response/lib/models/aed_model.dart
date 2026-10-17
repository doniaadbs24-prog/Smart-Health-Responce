import 'package:cloud_firestore/cloud_firestore.dart';

class Aed {
  final String aedId;
  final GeoPoint location;
  final String? facilityId;
  final String address;
  final bool isActive;
  final DateTime? lastServiceDate;
  final DateTime? nextServiceDate;
  final String accessInstructions;

  const Aed({
    required this.aedId,
    required this.location,
    this.facilityId,
    this.address = '',
    this.isActive = true,
    this.lastServiceDate,
    this.nextServiceDate,
    this.accessInstructions = '',
  });

  factory Aed.fromJson(Map<String, dynamic> json) => Aed(
    aedId: json['aedId'] as String? ?? '',
    location: json['location'] is GeoPoint
        ? json['location'] as GeoPoint
        : GeoPoint(
            (json['location']['latitude'] as num?)?.toDouble() ?? 0,
            (json['location']['longitude'] as num?)?.toDouble() ?? 0,
          ),
    facilityId: json['facilityId'] as String?,
    address: json['address'] as String? ?? '',
    isActive: json['isActive'] as bool? ?? true,
    lastServiceDate: json['lastServiceDate'] == null
        ? null
        : DateTime.tryParse(json['lastServiceDate'] as String),
    nextServiceDate: json['nextServiceDate'] == null
        ? null
        : DateTime.tryParse(json['nextServiceDate'] as String),
    accessInstructions: json['accessInstructions'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'aedId': aedId,
    'location': location,
    'facilityId': facilityId,
    'address': address,
    'isActive': isActive,
    'lastServiceDate': lastServiceDate?.toIso8601String(),
    'nextServiceDate': nextServiceDate?.toIso8601String(),
    'accessInstructions': accessInstructions,
  };

  Aed copyWith({
    String? aedId,
    GeoPoint? location,
    String? facilityId,
    String? address,
    bool? isActive,
    DateTime? lastServiceDate,
    DateTime? nextServiceDate,
    String? accessInstructions,
  }) => Aed(
    aedId: aedId ?? this.aedId,
    location: location ?? this.location,
    facilityId: facilityId ?? this.facilityId,
    address: address ?? this.address,
    isActive: isActive ?? this.isActive,
    lastServiceDate: lastServiceDate ?? this.lastServiceDate,
    nextServiceDate: nextServiceDate ?? this.nextServiceDate,
    accessInstructions: accessInstructions ?? this.accessInstructions,
  );

  @override
  String toString() => 'Aed($aedId, $address)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Aed && other.aedId == aedId);

  @override
  int get hashCode => aedId.hashCode;
}

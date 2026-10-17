class EmergencyContact {
  final String contactName;
  final String phoneNumber;
  final String relationship;

  const EmergencyContact({
    required this.contactName,
    required this.phoneNumber,
    required this.relationship,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => EmergencyContact(
        contactName: json['contactName'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String? ?? '',
        relationship: json['relationship'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'contactName': contactName,
        'phoneNumber': phoneNumber,
        'relationship': relationship,
      };

  EmergencyContact copyWith({String? contactName, String? phoneNumber, String? relationship}) =>
      EmergencyContact(
        contactName: contactName ?? this.contactName,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        relationship: relationship ?? this.relationship,
      );

  @override
  String toString() => 'EmergencyContact($contactName, $phoneNumber)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmergencyContact &&
          other.contactName == contactName &&
          other.phoneNumber == phoneNumber &&
          other.relationship == relationship);

  @override
  int get hashCode => Object.hash(contactName, phoneNumber, relationship);
}

enum UserRole { patient, doctor, admin }

enum VerificationStatus { pending, approved, rejected, suspended }

UserRole _role(String v) => switch (v) {
      'DOCTOR' => UserRole.doctor,
      'ADMIN' => UserRole.admin,
      _ => UserRole.patient,
    };

VerificationStatus? _verification(Object? v) => switch (v) {
      'PENDING' => VerificationStatus.pending,
      'APPROVED' => VerificationStatus.approved,
      'REJECTED' => VerificationStatus.rejected,
      'SUSPENDED' => VerificationStatus.suspended,
      _ => null,
    };

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.verificationStatus,
    this.bloodGroup,
    this.allergies = const [],
  });

  factory AppUser.fromJson(Map<String, dynamic> j) {
    final patient = j['patientProfile'] as Map<String, dynamic>?;
    return AppUser(
      id: j['id'] as String,
      name: j['name'] as String,
      email: j['email'] as String,
      phone: j['phone'] as String?,
      role: _role(j['role'] as String),
      verificationStatus: _verification(j['verificationStatus']),
      bloodGroup: patient?['bloodGroup'] as String?,
      allergies: ((patient?['allergies'] as List?) ?? const []).cast<String>(),
    );
  }

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;

  /// Only set for doctors. Doctors can sign in while pending but only reach
  /// the doctor workspace once an admin has approved them.
  final VerificationStatus? verificationStatus;

  final String? bloodGroup;
  final List<String> allergies;

  bool get isDoctor => role == UserRole.doctor;
  bool get isVerifiedDoctor =>
      isDoctor && verificationStatus == VerificationStatus.approved;

  String get firstName => name.replaceFirst('Dr. ', '').split(' ').first;

  String get initials {
    final parts = name.replaceFirst('Dr. ', '').split(' ');
    return parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join();
  }
}

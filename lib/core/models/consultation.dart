import 'package:flutter/material.dart';

import 'medical_record.dart';

enum ConsultationType { chat, voice, video, phone }

enum ConsultationStatus { booked, inProgress, completed, cancelled }

extension ConsultationTypeX on ConsultationType {
  String get label => switch (this) {
        ConsultationType.chat => 'Chat',
        ConsultationType.voice => 'Voice call',
        ConsultationType.video => 'Video call',
        ConsultationType.phone => 'Phone call',
      };

  IconData get icon => switch (this) {
        ConsultationType.chat => Icons.chat_bubble_outline_rounded,
        ConsultationType.voice => Icons.call_outlined,
        ConsultationType.video => Icons.videocam_outlined,
        ConsultationType.phone => Icons.phone_in_talk_outlined,
      };

  String get api => name.toUpperCase();

  static ConsultationType parse(String v) =>
      ConsultationType.values.firstWhere((t) => t.api == v);
}

extension ConsultationStatusX on ConsultationStatus {
  String get label => switch (this) {
        ConsultationStatus.booked => 'Booked',
        ConsultationStatus.inProgress => 'In progress',
        ConsultationStatus.completed => 'Completed',
        ConsultationStatus.cancelled => 'Cancelled',
      };

  static ConsultationStatus parse(String v) => switch (v) {
        'IN_PROGRESS' => ConsultationStatus.inProgress,
        'COMPLETED' => ConsultationStatus.completed,
        'CANCELLED' => ConsultationStatus.cancelled,
        _ => ConsultationStatus.booked,
      };
}

class Consultation {
  const Consultation({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.patientId,
    required this.patientName,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.type,
    required this.status,
    required this.feeCents,
    required this.currency,
    this.reason,
    this.paymentStatus,
    this.hasPrescription = false,
    this.reviewRating,
  });

  factory Consultation.fromJson(Map<String, dynamic> j) {
    final doctor = j['doctor'] as Map<String, dynamic>;
    final patient = j['patient'] as Map<String, dynamic>;
    return Consultation(
      id: j['id'] as String,
      doctorId: doctor['id'] as String,
      doctorName: doctor['name'] as String,
      doctorSpecialty:
          (doctor['specialty'] as Map<String, dynamic>)['name'] as String,
      patientId: patient['id'] as String,
      patientName: patient['name'] as String,
      scheduledAt: DateTime.parse(j['scheduledAt'] as String).toLocal(),
      durationMinutes: j['durationMinutes'] as int,
      type: ConsultationTypeX.parse(j['type'] as String),
      status: ConsultationStatusX.parse(j['status'] as String),
      feeCents: j['feeCents'] as int,
      currency: j['currency'] as String,
      reason: j['reason'] as String?,
      paymentStatus: j['paymentStatus'] as String?,
      hasPrescription: j['hasPrescription'] as bool? ?? false,
      reviewRating: j['reviewRating'] as int?,
    );
  }

  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String patientId;
  final String patientName;
  final DateTime scheduledAt;
  final int durationMinutes;
  final ConsultationType type;
  final ConsultationStatus status;
  final int feeCents;
  final String currency;
  final String? reason;
  final String? paymentStatus;
  final bool hasPrescription;
  final int? reviewRating;

  bool get isUpcoming =>
      status == ConsultationStatus.booked ||
      status == ConsultationStatus.inProgress;

  /// Booked, but its time slot ended without the doctor starting it.
  bool isOverdue([DateTime? now]) =>
      status == ConsultationStatus.booked &&
      (now ?? DateTime.now())
          .isAfter(scheduledAt.add(Duration(minutes: durationMinutes)));
}

class LabRequest {
  const LabRequest(this.testName, this.status);

  factory LabRequest.fromJson(Map<String, dynamic> j) =>
      LabRequest(j['testName'] as String, j['status'] as String);

  final String testName;
  final String status;
}

/// GET /consultations/:id: the summary plus prescription and lab requests.
class ConsultationDetail {
  const ConsultationDetail({
    required this.consultation,
    this.prescriptionNotes,
    this.prescriptionItems = const [],
    this.labRequests = const [],
  });

  factory ConsultationDetail.fromJson(Map<String, dynamic> j) {
    final p = j['prescription'] as Map<String, dynamic>?;
    return ConsultationDetail(
      consultation: Consultation.fromJson(j),
      prescriptionNotes: p?['notes'] as String?,
      prescriptionItems: ((p?['items'] as List?) ?? const [])
          .cast<Map<String, dynamic>>()
          .map(PrescriptionItem.fromJson)
          .toList(),
      labRequests: (j['labRequests'] as List)
          .cast<Map<String, dynamic>>()
          .map(LabRequest.fromJson)
          .toList(),
    );
  }

  final Consultation consultation;
  final String? prescriptionNotes;
  final List<PrescriptionItem> prescriptionItems;
  final List<LabRequest> labRequests;

  bool get hasPrescription => prescriptionItems.isNotEmpty;
}

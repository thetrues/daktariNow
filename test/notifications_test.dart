import 'package:flutter_test/flutter_test.dart';
import 'package:medic_app/core/models/consultation.dart';
import 'package:medic_app/core/models/health.dart';
import 'package:medic_app/features/care/care_screens.dart';

Consultation consultation(String id, DateTime at, {String status = 'BOOKED'}) =>
    Consultation.fromJson({
      'id': id,
      'type': 'VIDEO',
      'status': status,
      'scheduledAt': at.toUtc().toIso8601String(),
      'durationMinutes': 30,
      'feeCents': 2500000,
      'currency': 'TZS',
      'patient': {'id': 'p', 'name': 'Alex'},
      'doctor': {
        'id': 'd',
        'name': 'Dr. Sarah',
        'specialty': {'id': 's', 'name': 'Cardiologist'},
      },
    });

void main() {
  final now = DateTime(2026, 10, 12, 9);

  test('reminds about consultations in the next 48 hours only', () {
    final list = buildNotifications([
      consultation('soon', now.add(const Duration(hours: 3))),
      consultation('later', now.add(const Duration(days: 5))),
    ], const [], const [], now: now);
    expect(list.map((n) => n.route), ['/consultation/soon']);
  });

  test('flags a consultation the doctor has started', () {
    final list = buildNotifications(
      [consultation('live', now.subtract(const Duration(minutes: 5)), status: 'IN_PROGRESS')],
      const [],
      const [],
      now: now,
    );
    expect(list.single.title, contains('has started'));
  });

  test('includes recent prescriptions and updated home-service requests', () {
    final rx = PatientPrescription({
      'id': 'rx',
      'consultationId': 'c',
      'notes': null,
      'createdAt': now.subtract(const Duration(days: 2)).toUtc().toIso8601String(),
      'doctor': {'id': 'd', 'name': 'Dr. Sarah', 'specialty': 'Cardiologist'},
      'items': [
        {'medicine': 'Amlodipine 5mg', 'dosage': '1x1', 'duration': '30 days'},
      ],
    });
    ServiceRequest request(String status) => ServiceRequest({
          'id': 'r-$status',
          'service': {'id': 's', 'name': 'Home Visit'},
          'status': status,
          'priceCents': 8000000,
          'currency': 'TZS',
          'address': 'Mikocheni',
          'phone': '+255700000000',
          'preferredAt': now.add(const Duration(days: 1)).toUtc().toIso8601String(),
          'updatedAt': now.subtract(const Duration(hours: 1)).toUtc().toIso8601String(),
          'adminNote': 'Nurse arrives 10:00',
        });
    final list = buildNotifications(
      const [],
      [rx],
      [request('REQUESTED'), request('CONFIRMED')],
      now: now,
    );
    expect(list, hasLength(2)); // a request still awaiting review is not news
    expect(list.first.title, 'Home Visit: confirmed'); // newest first
    expect(list.first.body, 'Nurse arrives 10:00');
    expect(list.last.body, 'Amlodipine 5mg');
  });
}

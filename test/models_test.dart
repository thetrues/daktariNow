import 'package:flutter_test/flutter_test.dart';
import 'package:medic_app/core/models/app_user.dart';
import 'package:medic_app/core/models/consultation.dart';
import 'package:medic_app/core/models/wallet.dart';
import 'package:medic_app/features/doctor/schedule/doctor_schedule_screen.dart';

void main() {
  test('parses an API user with doctor verification', () {
    final u = AppUser.fromJson({
      'id': 'd1',
      'email': 'd@x.com',
      'phone': null,
      'name': 'Dr. Kevin Mwangi',
      'role': 'DOCTOR',
      'verificationStatus': 'PENDING',
      'patientProfile': null,
    });
    expect(u.isDoctor, isTrue);
    expect(u.isVerifiedDoctor, isFalse);
    expect(u.initials, 'KM');
  });

  test('parses a consultation and converts the time to local', () {
    final c = Consultation.fromJson({
      'id': 'c1',
      'type': 'VIDEO',
      'status': 'IN_PROGRESS',
      'scheduledAt': '2026-10-10T07:00:00.000Z',
      'durationMinutes': 30,
      'reason': 'Chest pain',
      'feeCents': 2500,
      'currency': 'USD',
      'paymentStatus': 'PAID',
      'patient': {'id': 'p1', 'name': 'Alex'},
      'doctor': {
        'id': 'd1',
        'name': 'Dr. Sarah',
        'specialty': {'id': 's1', 'name': 'Cardiologist'},
      },
      'hasPrescription': false,
      'reviewRating': null,
    });
    expect(c.type, ConsultationType.video);
    expect(c.status, ConsultationStatus.inProgress);
    expect(c.isUpcoming, isTrue);
    expect(c.scheduledAt.isUtc, isFalse);
    expect(c.scheduledAt.toUtc(), DateTime.utc(2026, 10, 10, 7));
  });

  group('schedule grid <-> availability windows', () {
    test('merges consecutive hours into one window per run', () {
      final windows = hoursToWindows({
        1: {9, 10, 11, 14, 15},
        6: {10},
      });
      expect(
        windows.map((w) => (w.weekday, w.startMinute, w.endMinute)).toList(),
        [(1, 540, 720), (1, 840, 960), (6, 600, 660)],
      );
    });

    test('round-trips through the API shape', () {
      final hours = {
        2: {8, 9, 13},
        5: {17, 18, 19},
      };
      expect(windowsToHours(hoursToWindows(hours)), hours);
    });

    test('marks partially covered hours as available', () {
      final hours = windowsToHours([const AvailabilityWindow(3, 570, 630)]);
      expect(hours, {
        3: {9, 10},
      });
    });
  });

  test('a booked consultation is overdue once its slot has ended unstarted', () {
    Consultation at(String status) => Consultation.fromJson({
          'id': 'c',
          'type': 'CHAT',
          'status': status,
          'scheduledAt': '2026-10-10T07:00:00.000Z',
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
    final during = DateTime.utc(2026, 10, 10, 7, 20);
    final after = DateTime.utc(2026, 10, 10, 7, 31);
    expect(at('BOOKED').isOverdue(during), isFalse);
    expect(at('BOOKED').isOverdue(after), isTrue);
    expect(at('IN_PROGRESS').isOverdue(after), isFalse);
  });
}

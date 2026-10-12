import 'package:flutter_test/flutter_test.dart';
import 'package:medic_app/app/router/app_router.dart';
import 'package:medic_app/core/models/app_user.dart';
import 'package:medic_app/features/auth/auth_controller.dart';

void main() {
  const patient = AppUser(
    id: 'u1',
    name: 'Alex',
    email: 'a@x.com',
    role: UserRole.patient,
  );
  const doctor = AppUser(
    id: 'd1',
    name: 'Dr. Sarah',
    email: 'd@x.com',
    role: UserRole.doctor,
    verificationStatus: VerificationStatus.approved,
  );
  const pendingDoctor = AppUser(
    id: 'd2',
    name: 'Dr. Kevin',
    email: 'k@x.com',
    role: UserRole.doctor,
    verificationStatus: VerificationStatus.pending,
  );

  String? guard(AppUser? user, String url) => routeGuard(
        user == null ? AuthStatus.signedOut : AuthStatus.signedIn,
        user,
        Uri.parse(url),
      );

  test('signed-out users only reach public pages', () {
    expect(guard(null, Routes.login), isNull);
    expect(guard(null, Routes.home), Routes.welcome);
    expect(guard(null, Routes.doctorHome), Routes.welcome);
  });

  test('patients can open find-doctors and booking but not doctor area', () {
    expect(guard(patient, Routes.doctors), isNull);
    expect(guard(patient, Routes.book('d1')), isNull);
    expect(guard(patient, Routes.doctorHome), Routes.home);
    expect(guard(patient, Routes.doctorEarnings), Routes.home);
  });

  test('verified doctors stay in the doctor area', () {
    expect(guard(doctor, Routes.doctorSchedule), isNull);
    expect(guard(doctor, Routes.home), Routes.doctorHome);
    expect(guard(doctor, Routes.doctors), Routes.doctorHome);
  });

  test('both roles can open a consultation room', () {
    expect(guard(patient, Routes.consultation('c1')), isNull);
    expect(guard(doctor, Routes.consultation('c1')), isNull);
  });

  test('unverified doctors are held on the verification page', () {
    expect(guard(pendingDoctor, Routes.doctorHome), Routes.pendingVerification);
    expect(guard(pendingDoctor, Routes.pendingVerification), isNull);
  });

  test('signed-in users are sent home from auth pages', () {
    expect(guard(patient, Routes.login), Routes.home);
    expect(guard(doctor, Routes.welcome), Routes.doctorHome);
  });

  group('session restore', () {
    test('waits on /loading and remembers the target', () {
      expect(
        routeGuard(AuthStatus.restoring, null, Uri.parse('/consultation/c1')),
        '/loading?from=%2Fconsultation%2Fc1',
      );
      expect(
        routeGuard(AuthStatus.restoring, null, Uri.parse('/loading?from=/x')),
        isNull,
      );
    });

    test('continues to the target once restored, applying role rules', () {
      expect(guard(patient, '/loading?from=%2Fconsultation%2Fc1'),
          '/consultation/c1');
      expect(guard(patient, '/loading?from=%2Fdoctor%2Fearnings'), Routes.home);
      expect(guard(null, '/loading?from=%2Fappointments'), Routes.welcome);
    });

    test('ignores external or looping targets', () {
      expect(guard(patient, '/loading?from=https%3A%2F%2Fevil.com'), Routes.home);
      expect(guard(patient, '/loading?from=%2F%2Fevil.com'), Routes.home);
      expect(guard(patient, '/loading?from=%2Floading'), Routes.home);
    });
  });
}

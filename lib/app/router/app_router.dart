import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/app_user.dart';
import '../../features/appointments/appointments_screen.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/booking/book_appointment_screen.dart';
import '../../features/care/care_screens.dart';
import '../../features/consultation/consultation_room_screen.dart';
import '../../features/doctor/dashboard/doctor_home_screen.dart';
import '../../features/doctor/earnings/earnings_screen.dart';
import '../../features/doctor/patients/doctor_patients_screen.dart';
import '../../features/doctor/schedule/doctor_schedule_screen.dart';
import '../../features/doctor/verification/pending_verification_screen.dart';
import '../../features/doctors/find_doctors_screen.dart';
import '../../features/health_status/health_status_screen.dart';
import '../../features/home/patient_home_screen.dart';
import '../../features/medical_records/medical_records_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/profile_forms.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/services/services_screens.dart';
import '../layout/adaptive_shell.dart';

abstract final class Routes {
  static const loading = '/loading';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const pendingVerification = '/verification-pending';

  // Patient
  static const home = '/home';
  static const appointments = '/appointments';
  static const records = '/records';
  static const profile = '/profile';
  static const doctors = '/doctors';
  static const health = '/health';
  static String book(String doctorId) => '/doctors/$doctorId/book';
  static const notifications = '/notifications';
  static const prescriptions = '/prescriptions';
  static const labTests = '/lab-tests';
  static const services = '/services';
  static String requestService(String id) => '/services/$id/request';
  static const serviceRequests = '/service-requests';
  static const healthInfo = '/profile/health';

  // Doctor
  static const doctorHome = '/doctor';
  static const doctorSchedule = '/doctor/schedule';
  static const doctorPatients = '/doctor/patients';
  static const doctorEarnings = '/doctor/earnings';
  static const doctorProfile = '/doctor/profile';
  static const doctorProfessional = '/doctor/profile/professional';
  static const doctorDocuments = '/doctor/profile/documents';

  // Shared
  static String consultation(String id) => '/consultation/$id';
  static const emergency = '/emergency';

  static const _public = {welcome, login, register};
}

final routerProvider = Provider<GoRouter>((ref) {
  // Re-run redirects whenever the session changes.
  final authChanges = ValueNotifier<AuthState>(ref.read(authControllerProvider));
  ref.listen(authControllerProvider, (_, next) => authChanges.value = next);
  ref.onDispose(authChanges.dispose);

  return GoRouter(
    initialLocation: Routes.welcome,
    refreshListenable: authChanges,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      return routeGuard(auth.status, auth.user, state.uri);
    },
    routes: [
      GoRoute(
        path: Routes.loading,
        builder: (_, _) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: Routes.welcome,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: Routes.register,
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: Routes.pendingVerification,
        builder: (_, _) => const PendingVerificationScreen(),
      ),

      // ---- Patient ----
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AdaptiveShell(
          navigationShell: shell,
          centerAction: ShellAction(
            label: 'Find a doctor',
            icon: Icons.add_rounded,
            onPressed: (context) => context.push(Routes.doctors),
          ),
          destinations: const [
            ShellDestination('Home', Icons.home_outlined, Icons.home_rounded),
            ShellDestination(
              'Appointments',
              Icons.calendar_today_outlined,
              Icons.calendar_today_rounded,
            ),
            ShellDestination(
              'Records',
              Icons.description_outlined,
              Icons.description_rounded,
            ),
            ShellDestination(
              'Profile',
              Icons.person_outline_rounded,
              Icons.person_rounded,
            ),
          ],
        ),
        branches: [
          _branch(Routes.home, const PatientHomeScreen()),
          _branch(Routes.appointments, const AppointmentsScreen()),
          _branch(Routes.records, const MedicalRecordsScreen()),
          _branch(Routes.profile, const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: Routes.doctors,
        builder: (_, _) => const FindDoctorsScreen(),
        routes: [
          GoRoute(
            path: ':id/book',
            builder: (_, state) =>
                BookAppointmentScreen(doctorId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: Routes.health,
        builder: (_, _) => const HealthStatusScreen(),
      ),

      // ---- Doctor ----
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AdaptiveShell(
          navigationShell: shell,
          destinations: const [
            ShellDestination(
              'Dashboard',
              Icons.space_dashboard_outlined,
              Icons.space_dashboard_rounded,
            ),
            ShellDestination(
              'Schedule',
              Icons.calendar_month_outlined,
              Icons.calendar_month_rounded,
            ),
            ShellDestination(
              'Patients',
              Icons.groups_outlined,
              Icons.groups_rounded,
            ),
            ShellDestination(
              'Earnings',
              Icons.account_balance_wallet_outlined,
              Icons.account_balance_wallet_rounded,
            ),
            ShellDestination(
              'Profile',
              Icons.person_outline_rounded,
              Icons.person_rounded,
            ),
          ],
        ),
        branches: [
          _branch(Routes.doctorHome, const DoctorHomeScreen()),
          _branch(Routes.doctorSchedule, const DoctorScheduleScreen()),
          _branch(Routes.doctorPatients, const DoctorPatientsScreen()),
          _branch(Routes.doctorEarnings, const EarningsScreen()),
          _branch(Routes.doctorProfile, const ProfileScreen()),
        ],
      ),

      // ---- Shared ----
      GoRoute(path: Routes.notifications, builder: (_, _) => const NotificationsScreen()),
      GoRoute(path: Routes.prescriptions, builder: (_, _) => const PrescriptionsScreen()),
      GoRoute(path: Routes.labTests, builder: (_, _) => const LabTestsScreen()),
      GoRoute(
        path: Routes.services,
        builder: (_, _) => const ServicesScreen(),
        routes: [
          GoRoute(
            path: ':id/request',
            builder: (_, state) =>
                RequestServiceScreen(serviceId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: Routes.serviceRequests,
        builder: (_, _) => const ServiceRequestsScreen(),
      ),
      GoRoute(path: '/profile/personal', builder: (_, _) => const PersonalInfoScreen()),
      GoRoute(path: Routes.healthInfo, builder: (_, _) => const HealthInfoScreen()),
      GoRoute(
        path: '/doctor/profile/personal',
        builder: (_, _) => const PersonalInfoScreen(),
      ),
      GoRoute(
        path: Routes.doctorProfessional,
        builder: (_, _) => const ProfessionalProfileScreen(),
      ),
      GoRoute(
        path: Routes.doctorDocuments,
        builder: (_, _) => const DoctorDocumentsScreen(),
      ),
      GoRoute(path: Routes.emergency, builder: (_, _) => const EmergencyScreen()),
      GoRoute(
        path: '/consultation/:id',
        builder: (_, state) => ConsultationRoomScreen(
          consultationId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});

StatefulShellBranch _branch(String path, Widget screen) => StatefulShellBranch(
      routes: [GoRoute(path: path, builder: (_, _) => screen)],
    );

/// Central access rules. The backend enforces the same rules; this only
/// keeps users out of screens they can't use.
///
/// While a saved session is being restored the requested page waits on
/// /loading?from=..., so deep links survive app start and page reloads.
@visibleForTesting
String? routeGuard(AuthStatus status, AppUser? user, Uri uri) {
  final location = uri.path;

  if (status == AuthStatus.restoring) {
    if (location == Routes.loading) return null;
    return Uri(path: Routes.loading, queryParameters: {'from': uri.toString()})
        .toString();
  }

  if (location == Routes.loading) {
    final from = uri.queryParameters['from'];
    final safe = from != null &&
        from.startsWith('/') &&
        !from.startsWith('//') &&
        !from.startsWith(Routes.loading);
    final target = safe ? from : Routes.welcome;
    return routeGuard(status, user, Uri.parse(target)) ?? target;
  }

  final isPublic = Routes._public.contains(location);

  if (user == null) return isPublic ? null : Routes.welcome;

  if (user.isDoctor && !user.isVerifiedDoctor) {
    return location == Routes.pendingVerification
        ? null
        : Routes.pendingVerification;
  }

  final home = user.isDoctor ? Routes.doctorHome : Routes.home;
  if (isPublic || location == Routes.pendingVerification || location == '/') {
    return home;
  }

  if (location.startsWith('/consultation/') || location == Routes.emergency) {
    return null;
  }

  final isDoctorArea = location == Routes.doctorHome ||
      location.startsWith('${Routes.doctorHome}/');
  if (user.isDoctor && !isDoctorArea) return home;
  if (!user.isDoctor && isDoctorArea) return home;
  return null;
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:typed_data';

import '../api/api_client.dart';
import '../api/api_errors.dart';
import '../api/config.dart';
import '../models/consultation.dart';
import '../models/doctor.dart';
import '../models/health.dart';
import '../models/medical_record.dart';
import '../models/wallet.dart';

typedef Json = Map<String, dynamic>;

/// Base for API-backed repositories: every error surfaces as [ApiException].
abstract class _Api {
  _Api(this.dio);

  final Dio dio;

  Future<T> call<T>(Future<Response<dynamic>> request, T Function(dynamic) parse) async {
    try {
      return parse((await request).data);
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  List<T> items<T>(dynamic page, T Function(Json) parse) =>
      ((page as Json)['items'] as List).cast<Json>().map(parse).toList();
}

class CatalogRepository extends _Api {
  CatalogRepository(super.dio);

  Future<List<Specialty>> specialties() => call(
        dio.get('/specialties'),
        (d) => (d as List).cast<Json>().map(Specialty.fromJson).toList(),
      );

  Future<List<Service>> services() => call(
        dio.get('/services'),
        (d) => (d as List).cast<Json>().map(Service.fromJson).toList(),
      );

  /// (id, "Name · City") pairs for pickers.
  Future<List<(String, String)>> hospitals() => call(
        dio.get('/hospitals'),
        (d) => [
          for (final h in (d as List).cast<Json>())
            (h['id'] as String, '${h['name']} · ${h['city']}'),
        ],
      );
}

class DoctorRepository extends _Api {
  DoctorRepository(super.dio);

  Future<List<Doctor>> search({String query = '', String? specialtyId}) => call(
        dio.get('/doctors', queryParameters: {
          if (query.trim().isNotEmpty) 'q': query.trim(),
          'specialtyId': ?specialtyId,
          'limit': 50,
        }),
        (d) => items(d, Doctor.fromJson),
      );

  Future<Doctor> byId(String id) =>
      call(dio.get('/doctors/$id'), (d) => Doctor.fromJson(d as Json));

  /// Free start times for a doctor-local date (`YYYY-MM-DD`), in local time.
  Future<List<DateTime>> slots(String doctorId, String date) => call(
        dio.get('/doctors/$doctorId/slots', queryParameters: {'date': date}),
        (d) => ((d as Json)['slots'] as List)
            .cast<String>()
            .map((s) => DateTime.parse(s).toLocal())
            .toList(),
      );
}

enum ConsultationScope { upcoming, past, all }

class ConsultationRepository extends _Api {
  ConsultationRepository(super.dio);

  Future<List<Consultation>> list(ConsultationScope scope) => call(
        dio.get('/consultations',
            queryParameters: {'scope': scope.name, 'limit': 100}),
        (d) => items(d, Consultation.fromJson),
      );

  Future<ConsultationDetail> byId(String id) => call(
      dio.get('/consultations/$id'), (d) => ConsultationDetail.fromJson(d as Json));

  Future<Consultation> book({
    required String doctorId,
    required DateTime at,
    required ConsultationType type,
    String? reason,
  }) =>
      call(
        dio.post('/consultations', data: {
          'doctorId': doctorId,
          'scheduledAt': at.toUtc().toIso8601String(),
          'type': type.api,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        }),
        (d) => Consultation.fromJson(d as Json),
      );

  Future<void> start(String id) => call(dio.post('/consultations/$id/start'), (_) {});

  /// LiveKit room credentials for a voice/video consultation in progress.
  Future<CallCredentials> callToken(String id) => call(
      dio.post('/consultations/$id/call'), (d) => CallCredentials.fromJson(d as Json));

  Future<void> complete(String id, {String? notes}) => call(
        dio.post('/consultations/$id/complete',
            data: {if (notes != null && notes.isNotEmpty) 'doctorNotes': notes}),
        (_) {},
      );

  Future<void> cancel(String id, {String? reason}) => call(
        dio.post('/consultations/$id/cancel',
            data: {'reason': ?reason}),
        (_) {},
      );

  Future<List<ChatMessage>> messages(String id, {DateTime? after}) => call(
        dio.get('/consultations/$id/messages', queryParameters: {
          if (after != null) 'after': after.toUtc().toIso8601String(),
        }),
        (d) => (d as List).cast<Json>().map(ChatMessage.fromJson).toList(),
      );

  Future<ChatMessage> send(String id, String body) => call(
        dio.post('/consultations/$id/messages', data: {'body': body}),
        (d) => ChatMessage.fromJson(d as Json),
      );

  Future<void> prescribe(String id, List<PrescriptionItem> items, {String? notes}) =>
      call(
        dio.post('/consultations/$id/prescription', data: {
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          'items': [for (final i in items) i.toJson()],
        }),
        (_) {},
      );

  Future<void> requestLabs(String id, List<String> tests) => call(
      dio.post('/consultations/$id/lab-requests', data: {'tests': tests}), (_) {});

  Future<void> review(String id, int rating, {String? comment}) => call(
        dio.post('/consultations/$id/review', data: {
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        }),
        (_) {},
      );
}

class RecordRepository extends _Api {
  RecordRepository(super.dio);

  Future<List<MedicalRecord>> mine() => call(
      dio.get('/records', queryParameters: {'limit': 100}),
      (d) => items(d, MedicalRecord.fromJson));

  Future<MedicalRecord> create({
    required RecordCategory category,
    required String title,
    String? notes,
    String? fileId,
  }) =>
      call(
        dio.post('/records', data: {
          'category': category.api,
          'title': title,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          'fileId': ?fileId,
        }),
        (d) => MedicalRecord.fromJson(d as Json),
      );

  Future<void> delete(String id) => call(dio.delete('/records/$id'), (_) {});

  Future<List<PatientPrescription>> prescriptions() => call(
      dio.get('/prescriptions', queryParameters: {'limit': 100}),
      (d) => items(d, PatientPrescription.new));

  Future<List<PatientLabRequest>> labRequests() => call(
      dio.get('/lab-requests', queryParameters: {'limit': 100}),
      (d) => items(d, PatientLabRequest.new));

  /// Doctor view; allowed only during an active consultation (audited).
  Future<List<MedicalRecord>> forPatient(String patientId) => call(
      dio.get('/patients/$patientId/records', queryParameters: {'limit': 100}),
      (d) => items(d, MedicalRecord.fromJson));
}

class DoctorSelfRepository extends _Api {
  DoctorSelfRepository(super.dio);

  Future<Json> profile() => call(dio.get('/doctor/me'), (d) => d as Json);

  Future<List<AvailabilityWindow>> availability() => call(
        dio.get('/doctor/me/availability'),
        (d) => (d as List).cast<Json>().map(AvailabilityWindow.fromJson).toList(),
      );

  Future<void> setAvailability(List<AvailabilityWindow> windows) => call(
        dio.put('/doctor/me/availability',
            data: {'windows': [for (final w in windows) w.toJson()]}),
        (_) {},
      );

  Future<void> setPresence(bool online) =>
      call(dio.patch('/doctor/me/presence', data: {'isOnline': online}), (_) {});

  Future<Json> updateProfile(Json changes) =>
      call(dio.patch('/doctor/me', data: changes), (d) => d as Json);

  Future<void> addDocument(String type, String fileId) => call(
      dio.post('/doctor/me/documents', data: {'type': type, 'fileId': fileId}),
      (_) {});
}

class WalletRepository extends _Api {
  WalletRepository(super.dio);

  Future<WalletSummary> summary() =>
      call(dio.get('/wallet'), (d) => WalletSummary(d as Json));

  Future<List<WalletTransaction>> transactions() => call(
      dio.get('/wallet/transactions', queryParameters: {'limit': 50}),
      (d) => items(d, WalletTransaction.new));

  Future<void> requestPayout(int amountCents, String destination) => call(
        dio.post('/wallet/payouts',
            data: {'amountCents': amountCents, 'destination': destination}),
        (_) {},
      );
}

final catalogRepositoryProvider =
    Provider((ref) => CatalogRepository(ref.watch(dioProvider)));
final doctorRepositoryProvider =
    Provider((ref) => DoctorRepository(ref.watch(dioProvider)));
final consultationRepositoryProvider =
    Provider((ref) => ConsultationRepository(ref.watch(dioProvider)));
final recordRepositoryProvider =
    Provider((ref) => RecordRepository(ref.watch(dioProvider)));
final doctorSelfRepositoryProvider =
    Provider((ref) => DoctorSelfRepository(ref.watch(dioProvider)));
final walletRepositoryProvider =
    Provider((ref) => WalletRepository(ref.watch(dioProvider)));

final specialtiesProvider = FutureProvider<List<Specialty>>(
  (ref) => ref.watch(catalogRepositoryProvider).specialties(),
);

enum FilePurpose { medicalRecord, verificationDocument }

class FilesRepository extends _Api {
  FilesRepository(super.dio);

  static const allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png', 'webp'];

  Future<StoredFileInfo> upload(
    Uint8List bytes,
    String filename,
    FilePurpose purpose,
  ) =>
      call(
        dio.post(
          '/files',
          queryParameters: {
            'purpose': purpose == FilePurpose.medicalRecord
                ? 'MEDICAL_RECORD'
                : 'VERIFICATION_DOCUMENT',
          },
          data: FormData.fromMap({
            'file': MultipartFile.fromBytes(bytes, filename: filename),
          }),
        ),
        (d) => StoredFileInfo.fromJson(d as Json),
      );

  /// A short-lived link (about 5 minutes) that opens the file without login.
  Future<Uri> openUrl(String fileId) => call(dio.get('/files/$fileId/link'), (d) {
        final origin = Uri.parse(apiBaseUrl);
        return origin.replace(
          path: '',
          query: null,
        ).resolve((d as Json)['path'] as String);
      });
}

class VitalsRepository extends _Api {
  VitalsRepository(super.dio);

  Future<List<VitalReading>> latest() => call(
        dio.get('/vitals/latest'),
        (d) => (d as List).cast<Json>().map(VitalReading.fromJson).toList(),
      );

  Future<List<VitalReading>> history(VitalType type, {int days = 30}) => call(
        dio.get('/vitals', queryParameters: {'type': type.api, 'days': days}),
        (d) => (d as List).cast<Json>().map(VitalReading.fromJson).toList(),
      );

  Future<VitalReading> add(VitalType type, double value, {double? value2, DateTime? at}) =>
      call(
        dio.post('/vitals', data: {
          'type': type.api,
          'value': value,
          'value2': ?value2,
          if (at != null) 'recordedAt': at.toUtc().toIso8601String(),
        }),
        (d) => VitalReading.fromJson(d as Json),
      );

  Future<void> delete(String id) => call(dio.delete('/vitals/$id'), (_) {});

  /// Doctor view during an active consultation.
  Future<List<VitalReading>> forPatient(String patientId) => call(
        dio.get('/patients/$patientId/vitals'),
        (d) => (d as List).cast<Json>().map(VitalReading.fromJson).toList(),
      );
}

class ServiceRequestRepository extends _Api {
  ServiceRequestRepository(super.dio);

  Future<ServiceRequest> create({
    required String serviceId,
    required String address,
    required String phone,
    required DateTime preferredAt,
    String? notes,
  }) =>
      call(
        dio.post('/service-requests', data: {
          'serviceId': serviceId,
          'address': address,
          'phone': phone,
          'preferredAt': preferredAt.toUtc().toIso8601String(),
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        }),
        (d) => ServiceRequest(d as Json),
      );

  Future<List<ServiceRequest>> mine() => call(
      dio.get('/service-requests', queryParameters: {'limit': 100}),
      (d) => items(d, ServiceRequest.new));

  Future<void> cancel(String id) =>
      call(dio.post('/service-requests/$id/cancel'), (_) {});
}

class AccountRepository extends _Api {
  AccountRepository(super.dio);

  Future<Json> updateMe({String? name, String? phone}) => call(
        dio.patch('/me', data: {'name': ?name, 'phone': ?phone}),
        (d) => d as Json,
      );

  Future<Json> updatePatientProfile({
    DateTime? dateOfBirth,
    String? gender,
    String? bloodGroup,
    List<String>? allergies,
  }) =>
      call(
        dio.patch('/me/patient-profile', data: {
          if (dateOfBirth != null)
            'dateOfBirth': DateTime.utc(dateOfBirth.year, dateOfBirth.month, dateOfBirth.day)
                .toIso8601String(),
          'gender': ?gender,
          'bloodGroup': ?bloodGroup,
          'allergies': ?allergies,
        }),
        (d) => d as Json,
      );
}

final filesRepositoryProvider =
    Provider((ref) => FilesRepository(ref.watch(dioProvider)));
final vitalsRepositoryProvider =
    Provider((ref) => VitalsRepository(ref.watch(dioProvider)));
final serviceRequestRepositoryProvider =
    Provider((ref) => ServiceRequestRepository(ref.watch(dioProvider)));
final accountRepositoryProvider =
    Provider((ref) => AccountRepository(ref.watch(dioProvider)));

final servicesProvider = FutureProvider<List<Service>>(
  (ref) => ref.watch(catalogRepositoryProvider).services(),
);

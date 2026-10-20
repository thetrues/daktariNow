import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'medical_record.dart';

/// Types match the API's VitalType.
enum VitalType {
  heartRate('HEART_RATE', 'bpm', Icons.favorite_rounded, AppColors.accent),
  bloodPressure('BLOOD_PRESSURE', 'mmHg', Icons.bloodtype_outlined, AppColors.primary),
  bloodSugar('BLOOD_SUGAR', 'mmol/L', Icons.water_drop_outlined, AppColors.purple),
  weight('WEIGHT', 'kg', Icons.monitor_weight_outlined, AppColors.amber),
  temperature('TEMPERATURE', '°C', Icons.thermostat_rounded, AppColors.danger);

  const VitalType(this.api, this.unit, this.icon, this.color);

  final String api;
  final String unit;
  final IconData icon;
  final Color color;

  String label(AppLocalizations l) => switch (this) {
        heartRate => l.vitalHeartRate,
        bloodPressure => l.vitalBloodPressure,
        bloodSugar => l.vitalBloodSugar,
        weight => l.vitalWeight,
        temperature => l.vitalTemperature,
      };

  bool get hasTwoValues => this == VitalType.bloodPressure;

  static VitalType parse(String v) => values.firstWhere((t) => t.api == v);
}

class VitalReading {
  const VitalReading({
    required this.id,
    required this.type,
    required this.value,
    required this.recordedAt,
    this.value2,
  });

  factory VitalReading.fromJson(Map<String, dynamic> j) => VitalReading(
        id: j['id'] as String,
        type: VitalType.parse(j['type'] as String),
        value: (j['value'] as num).toDouble(),
        value2: (j['value2'] as num?)?.toDouble(),
        recordedAt: DateTime.parse(j['recordedAt'] as String).toLocal(),
      );

  final String id;
  final VitalType type;
  final double value;
  final double? value2;
  final DateTime recordedAt;

  String get display {
    String n(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
    return value2 == null ? n(value) : '${n(value)}/${n(value2!)}';
  }
}

class Service {
  const Service(this.id, this.name, this.description, this.priceCents, this.currency);

  factory Service.fromJson(Map<String, dynamic> j) => Service(
        j['id'] as String,
        j['name'] as String,
        j['description'] as String? ?? '',
        j['priceCents'] as int,
        j['currency'] as String,
      );

  final String id;
  final String name;
  final String description;
  final int priceCents;
  final String currency;
}

enum ServiceRequestStatus {
  requested('REQUESTED'),
  confirmed('CONFIRMED'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  const ServiceRequestStatus(this.api);

  final String api;

  String label(AppLocalizations l) => switch (this) {
        requested => l.statusRequested,
        confirmed => l.statusConfirmed,
        completed => l.statusCompleted,
        cancelled => l.statusCancelled,
      };

  static ServiceRequestStatus parse(String v) => values.firstWhere((s) => s.api == v);
}

class ServiceRequest {
  const ServiceRequest(this.json);

  final Map<String, dynamic> json;

  String get id => json['id'] as String;
  String get serviceName => (json['service'] as Map<String, dynamic>)['name'] as String;
  ServiceRequestStatus get status => ServiceRequestStatus.parse(json['status'] as String);
  int get priceCents => json['priceCents'] as int;
  String get currency => json['currency'] as String;
  String get address => json['address'] as String;
  String get phone => json['phone'] as String;
  DateTime get preferredAt => DateTime.parse(json['preferredAt'] as String).toLocal();
  DateTime get updatedAt => DateTime.parse(json['updatedAt'] as String).toLocal();
  String? get notes => json['notes'] as String?;
  String? get adminNote => json['adminNote'] as String?;
}

class PatientPrescription {
  const PatientPrescription(this.json);

  final Map<String, dynamic> json;

  String get id => json['id'] as String;
  String get consultationId => json['consultationId'] as String;
  String? get notes => json['notes'] as String?;
  DateTime get createdAt => DateTime.parse(json['createdAt'] as String).toLocal();
  String get doctorName => (json['doctor'] as Map<String, dynamic>)['name'] as String;
  String get specialty => (json['doctor'] as Map<String, dynamic>)['specialty'] as String;
  List<PrescriptionItem> get items => (json['items'] as List)
      .cast<Map<String, dynamic>>()
      .map(PrescriptionItem.fromJson)
      .toList();
}

class PatientLabRequest {
  const PatientLabRequest(this.json);

  final Map<String, dynamic> json;

  String get testName => json['testName'] as String;
  String get status => json['status'] as String;
  String? get notes => json['notes'] as String?;
  String get consultationId => json['consultationId'] as String;
  DateTime get createdAt => DateTime.parse(json['createdAt'] as String).toLocal();
  String get doctorName => (json['doctor'] as Map<String, dynamic>)['name'] as String;
}

/// What POST /consultations/:id/call returns.
class CallCredentials {
  const CallCredentials(this.url, this.token, this.video);

  factory CallCredentials.fromJson(Map<String, dynamic> j) =>
      CallCredentials(j['url'] as String, j['token'] as String, j['video'] as bool);

  final String url;
  final String token;
  final bool video;
}

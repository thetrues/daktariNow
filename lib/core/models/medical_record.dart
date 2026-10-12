enum RecordCategory { prescription, labReport, xRay, vaccination, summary, other }

RecordCategory _category(String v) => switch (v) {
      'PRESCRIPTION' => RecordCategory.prescription,
      'LAB_REPORT' => RecordCategory.labReport,
      'XRAY' => RecordCategory.xRay,
      'VACCINATION' => RecordCategory.vaccination,
      'SUMMARY' => RecordCategory.summary,
      _ => RecordCategory.other,
    };

extension RecordCategoryApi on RecordCategory {
  String get api => switch (this) {
        RecordCategory.prescription => 'PRESCRIPTION',
        RecordCategory.labReport => 'LAB_REPORT',
        RecordCategory.xRay => 'XRAY',
        RecordCategory.vaccination => 'VACCINATION',
        RecordCategory.summary => 'SUMMARY',
        RecordCategory.other => 'OTHER',
      };

  String get label => switch (this) {
        RecordCategory.prescription => 'Prescription',
        RecordCategory.labReport => 'Lab report',
        RecordCategory.xRay => 'X-ray / scan',
        RecordCategory.vaccination => 'Vaccination',
        RecordCategory.summary => 'Health summary',
        RecordCategory.other => 'Other',
      };
}

/// An uploaded file's metadata. Open it via FilesRepository.openUrl.
class StoredFileInfo {
  const StoredFileInfo(this.id, this.filename, this.mimeType, this.sizeBytes);

  factory StoredFileInfo.fromJson(Map<String, dynamic> j) => StoredFileInfo(
        j['id'] as String,
        j['filename'] as String,
        j['mimeType'] as String,
        j['sizeBytes'] as int,
      );

  final String id;
  final String filename;
  final String mimeType;
  final int sizeBytes;

  bool get isImage => mimeType.startsWith('image/');
}

class MedicalRecord {
  const MedicalRecord({
    required this.id,
    required this.category,
    required this.title,
    required this.updatedAt,
    this.notes,
    this.createdById,
    this.createdByName,
    this.file,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> j) {
    final by = j['createdBy'] as Map<String, dynamic>?;
    final file = j['file'] as Map<String, dynamic>?;
    return MedicalRecord(
      id: j['id'] as String,
      category: _category(j['category'] as String),
      title: j['title'] as String,
      notes: j['notes'] as String?,
      updatedAt: DateTime.parse(j['updatedAt'] as String).toLocal(),
      createdById: by?['id'] as String?,
      createdByName: by?['name'] as String?,
      file: file == null ? null : StoredFileInfo.fromJson(file),
    );
  }

  final String id;
  final RecordCategory category;
  final String title;
  final DateTime updatedAt;
  final String? notes;
  final String? createdById;
  final String? createdByName;
  final StoredFileInfo? file;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'] as String,
        senderId: j['senderId'] as String,
        text: j['body'] as String,
        sentAt: DateTime.parse(j['createdAt'] as String),
      );

  final String id;
  final String senderId;
  final String text;

  /// UTC instant, used as the polling cursor.
  final DateTime sentAt;
}

class PrescriptionItem {
  const PrescriptionItem({
    required this.medicine,
    required this.dosage,
    required this.duration,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> j) => PrescriptionItem(
        medicine: j['medicine'] as String,
        dosage: j['dosage'] as String,
        duration: j['duration'] as String,
      );

  final String medicine;
  final String dosage;
  final String duration;

  Map<String, dynamic> toJson() =>
      {'medicine': medicine, 'dosage': dosage, 'duration': duration};
}

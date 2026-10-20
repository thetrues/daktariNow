import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/locale_controller.dart';
import '../core/data/repositories.dart';
import '../core/models/medical_record.dart';
import 'widgets/common.dart';

/// Must match the API's MAX_UPLOAD_MB.
const maxUploadBytes = 10 * 1024 * 1024;

/// Lets the user pick a PDF or image and uploads it. Returns null if they
/// cancel; shows a message and returns null on errors.
Future<StoredFileInfo?> pickAndUpload(
  BuildContext context,
  WidgetRef ref,
  FilePurpose purpose,
) async {
  final picked = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: FilesRepository.allowedExtensions,
  );
  if (picked == null) return null;
  try {
    final size = await picked.length();
    if (size != null && size > maxUploadBytes) {
      if (context.mounted) showInfo(context, context.l10n.fileTooLarge);
      return null;
    }
    final bytes = await picked.readAsBytes();
    return await ref
        .read(filesRepositoryProvider)
        .upload(bytes, picked.name, purpose);
  } catch (e) {
    if (context.mounted) showError(context, e);
    return null;
  }
}

/// Opens a stored file in the browser or the system viewer via a signed,
/// short-lived link.
Future<void> openStoredFile(
  BuildContext context,
  WidgetRef ref,
  StoredFileInfo file,
) async {
  try {
    final url = await ref.read(filesRepositoryProvider).openUrl(file.id);
    final ok = await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
    if (!ok && context.mounted) showInfo(context, context.l10n.couldNotOpenFile);
  } catch (e) {
    if (context.mounted) showError(context, e);
  }
}

String fileSizeLabel(int bytes) => bytes < 1024 * 1024
    ? '${(bytes / 1024).ceil()} KB'
    : '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';

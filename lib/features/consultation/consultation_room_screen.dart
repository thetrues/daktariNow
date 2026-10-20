import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/layout/breakpoints.dart';
import '../../app/locale_controller.dart';
import '../../app/router/app_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/data/repositories.dart';
import '../../core/models/app_user.dart';
import '../../core/models/consultation.dart';
import '../../core/models/health.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/common.dart';
import '../appointments/appointment_providers.dart';
import '../auth/auth_controller.dart';
import '../medical_records/medical_records_screen.dart';
import 'call_panel.dart';
import 'chat_panel.dart';
import 'prescribe_panel.dart';

/// Shared room for both parties.
///
/// Doctor on desktop/web: call+chat | patient records | prescribe & labs.
/// Doctor on phone: the same three as tabs. Patient: call+chat, plus the
/// prescription once the doctor sends it.
class ConsultationRoomScreen extends ConsumerWidget {
  const ConsultationRoomScreen({super.key, required this.consultationId});

  final String consultationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(consultationDetailProvider(consultationId));
    final user = ref.watch(currentUserProvider);

    return detail.when(
      skipLoadingOnRefresh: true,
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: AsyncView<void>(
          value: AsyncError(e, StackTrace.current),
          builder: (_) => const SizedBox(),
          onRetry: () =>
              ref.invalidate(consultationDetailProvider(consultationId)),
        ),
      ),
      data: (d) => _Room(detail: d, user: user),
    );
  }
}

class _Room extends ConsumerStatefulWidget {
  const _Room({required this.detail, required this.user});

  final ConsultationDetail detail;
  final AppUser user;

  @override
  ConsumerState<_Room> createState() => _RoomState();
}

class _RoomState extends ConsumerState<_Room> {
  bool _busy = false;

  Consultation get c => widget.detail.consultation;
  bool get isDoctor => widget.user.isDoctor;

  Future<void> _run(Future<void> Function(ConsultationRepository r) action,
      String done) async {
    setState(() => _busy = true);
    try {
      await action(ref.read(consultationRepositoryProvider));
      ref.invalidate(consultationDetailProvider(c.id));
      refreshConsultations(ref);
      if (mounted) showInfo(context, done);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _complete() async {
    final l = context.l10n;
    final ok = await _confirm(
      l.completeConsultationQ,
      l.completeConsultationBody,
      l.complete,
    );
    if (ok) await _run((r) => r.complete(c.id), l.consultationCompleted);
  }

  Future<void> _cancel() async {
    final l = context.l10n;
    final ok = await _confirm(
      l.cancelAppointmentQ,
      l.refundedInFull,
      l.cancelAppointment,
      destructive: true,
    );
    if (ok) {
      // The reason is stored for the team, so it stays in English.
      await _run((r) => r.cancel(c.id, reason: 'Cancelled by patient'),
          l.appointmentCancelledRefunded);
    }
  }

  Future<void> _review() async {
    final rating = await showDialog<int>(
      context: context,
      builder: (_) => const _RatingDialog(),
    );
    if (rating != null && mounted) {
      await _run((r) => r.review(c.id, rating), context.l10n.thanksFeedback);
    }
  }

  Future<bool> _confirm(String title, String message, String action,
      {bool destructive = false}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.back),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(backgroundColor: AppColors.danger)
                : null,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  List<Widget> _actions() {
    final l = context.l10n;
    Widget button(String label, VoidCallback onPressed, {Color? color}) =>
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              backgroundColor: color,
            ),
            onPressed: _busy ? null : onPressed,
            child: Text(label),
          ),
        );

    return switch ((isDoctor, c.status)) {
      (true, ConsultationStatus.booked) => [
          button(l.start, () => _run((r) => r.start(c.id), l.consultationStarted))
        ],
      (true, ConsultationStatus.inProgress) => [
          button(l.endAndComplete, _complete, color: AppColors.danger)
        ],
      (false, ConsultationStatus.booked) => [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _busy ? null : _cancel,
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: Text(l.cancel),
            ),
          ),
        ],
      (false, ConsultationStatus.completed) when c.reviewRating == null => [
          button(l.rateDoctor, _review)
        ],
      _ => const [],
    };
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.detail;
    final l = context.l10n;
    final otherName = isDoctor ? c.patientName : c.doctorName;
    final otherSubtitle = isDoctor ? (c.reason ?? l.consultation) : c.doctorSpecialty;
    final open = c.isUpcoming;

    final communication = Column(
      children: [
        _StatusBanner(consultation: c, isDoctor: isDoctor),
        if (c.type != ConsultationType.chat && open)
          CallPanel(
            // A fresh panel (and call) once the consultation starts.
            key: ValueKey('call-${c.id}-${c.status.name}'),
            consultationId: c.id,
            type: c.type,
            remoteName: otherName,
            localName: widget.user.name,
            inProgress: c.status == ConsultationStatus.inProgress,
          ),
        if (!isDoctor && (d.hasPrescription || d.labRequests.isNotEmpty))
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ExpansionTile(
              initiallyExpanded: !open,
              shape: const Border(),
              leading: const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
              title: Text(l.prescriptionAndLabs),
              children: [PrescriptionSummary(detail: d)],
            ),
          ),
        Expanded(
          child: ChatPanel(
            // Rebuild the panel (and stop polling) when the room closes.
            key: ValueKey('${c.id}-$open'),
            consultationId: c.id,
            myId: widget.user.id,
            otherName: otherName,
            open: open,
          ),
        ),
      ],
    );

    final title = Row(
      children: [
        Avatar.fromName(otherName, size: 38),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(otherName,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall),
              Text(
                '${c.type.label(l)} · $otherSubtitle',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
    final back = IconButton(
      tooltip: l.back,
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => context.canPop()
          ? context.pop()
          : context.go(isDoctor ? Routes.doctorHome : Routes.home),
    );

    if (!isDoctor) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: back,
          centerTitle: false,
          titleSpacing: 0,
          title: title,
          actions: _actions(),
        ),
        body: ContentConstraint(maxWidth: 900, child: communication),
      );
    }

    final records = _RecordsPane(patientId: c.patientId, reason: c.reason, open: open);
    final prescribe = PrescribePanel(detail: d);

    if (Breakpoints.isDesktop(context)) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: back,
          centerTitle: false,
          titleSpacing: 0,
          title: title,
          actions: _actions(),
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 5, child: communication),
            const VerticalDivider(width: 1),
            Expanded(flex: 3, child: records),
            const VerticalDivider(width: 1),
            Expanded(flex: 3, child: prescribe),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: back,
          title: title,
          titleSpacing: 0,
          centerTitle: false,
          actions: _actions(),
          bottom: TabBar(
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: l.tabConsult),
              Tab(text: l.tabRecords),
              Tab(text: l.tabPrescribe),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [communication, records, prescribe],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.consultation, required this.isDoctor});

  final Consultation consultation;
  final bool isDoctor;

  @override
  Widget build(BuildContext context) {
    final c = consultation;
    final l = context.l10n;
    final when = DateFormat('EEE d MMM, h:mm a').format(c.scheduledAt);
    final (message, color) = switch (c.status) {
      ConsultationStatus.booked => (
          isDoctor ? l.scheduledDoctor(when) : l.scheduledPatient(when),
          AppColors.primarySoft
        ),
      ConsultationStatus.inProgress => ('', AppColors.primarySoft),
      ConsultationStatus.completed => (l.statusCompleted, AppColors.primarySoft),
      ConsultationStatus.cancelled => (
          c.paymentStatus == 'REFUNDED' ? l.cancelledRefunded : l.statusCancelled,
          AppColors.accentSoft
        ),
    };
    if (message.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _RecordsPane extends ConsumerWidget {
  const _RecordsPane({required this.patientId, required this.open, this.reason});

  final String patientId;
  final bool open;
  final String? reason;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final l = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l.patientFile,
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        if (reason != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              color: AppColors.amberSoft,
              child: Row(
                children: [
                  const Icon(Icons.report_outlined, color: AppColors.amber),
                  const SizedBox(width: 10),
                  Expanded(child: Text(l.reasonValue(reason!))),
                ],
              ),
            ),
          ),
        if (open) ...[
          AsyncView(
            value: ref.watch(_patientVitalsProvider(patientId)),
            onRetry: () => ref.invalidate(_patientVitalsProvider(patientId)),
            builder: (vitals) => vitals.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.latestReadingsPatient,
                              style: text.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          for (final v in vitals)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: Row(
                                children: [
                                  Icon(v.type.icon, size: 16, color: v.type.color),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(v.type.label(l))),
                                  Text('${v.display} ${v.type.unit}',
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
          AsyncView(
            value: ref.watch(patientRecordsProvider(patientId)),
            onRetry: () => ref.invalidate(patientRecordsProvider(patientId)),
            builder: (items) => items.isEmpty
                ? AppCard(child: Text(l.noRecordsOnFile))
                : RecordList(records: items, dense: true),
          ),
        ] else
          AppCard(child: Text(l.recordsOnlyActive)),
        const SizedBox(height: 8),
        Text(
          l.accessLogged,
          style: text.labelSmall?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _RatingDialog extends StatefulWidget {
  const _RatingDialog();

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.howWasConsultation),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 1; i <= 5; i++)
            IconButton(
              tooltip: l.starsOutOf5(i),
              iconSize: 36,
              onPressed: () => setState(() => _rating = i),
              icon: Icon(
                i <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                color: AppColors.star,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.notNow),
        ),
        FilledButton(
          onPressed: _rating == 0 ? null : () => Navigator.pop(context, _rating),
          child: Text(l.submit),
        ),
      ],
    );
  }
}

final _patientVitalsProvider =
    FutureProvider.autoDispose.family<List<VitalReading>, String>(
  (ref, patientId) => ref.watch(vitalsRepositoryProvider).forPatient(patientId),
);

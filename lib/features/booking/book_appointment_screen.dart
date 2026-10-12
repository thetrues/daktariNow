import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/layout/breakpoints.dart';
import '../../app/router/app_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/api/api_errors.dart';
import '../../core/data/repositories.dart';
import '../../core/format.dart';
import '../../core/models/consultation.dart';
import '../../core/models/doctor.dart';
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/common.dart';
import '../appointments/appointment_providers.dart';

final doctorProvider = FutureProvider.autoDispose.family<Doctor, String>(
  (ref, id) => ref.watch(doctorRepositoryProvider).byId(id),
);

/// Free slots for (doctorId, doctor-local date `YYYY-MM-DD`).
final slotsProvider =
    FutureProvider.autoDispose.family<List<DateTime>, (String, String)>(
  (ref, key) => ref.watch(doctorRepositoryProvider).slots(key.$1, key.$2),
);

class BookAppointmentScreen extends ConsumerStatefulWidget {
  const BookAppointmentScreen({super.key, required this.doctorId});

  final String doctorId;

  @override
  ConsumerState<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  late final List<DateTime> _days = List.generate(14, (i) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + i);
  });

  late DateTime _day = _days.first;
  DateTime? _slot;
  ConsultationType _type = ConsultationType.video;
  final _reason = TextEditingController();
  bool _booking = false;

  (String, String) get _slotKey => (widget.doctorId, isoDate(_day));

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _confirm(Doctor doctor) async {
    final when = _slot;
    if (when == null) return;
    setState(() => _booking = true);
    try {
      await ref.read(consultationRepositoryProvider).book(
            doctorId: doctor.id,
            at: when,
            type: _type,
            reason: _reason.text.trim(),
          );
      refreshConsultations(ref);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 48),
          title: const Text('Booking confirmed'),
          content: Text(
            '${_type.label} with ${doctor.name}\n'
            '${DateFormat('EEE d MMM, h:mm a').format(when)}\n'
            'Paid ${money(doctor.feeCents, doctor.currency)}',
            textAlign: TextAlign.center,
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      );
      if (mounted) context.go(Routes.appointments);
    } catch (e) {
      if (!mounted) return;
      final error = ApiException.from(e);
      if (error.isConflict) {
        // Someone else took it; show fresh availability.
        setState(() => _slot = null);
        ref.invalidate(slotsProvider(_slotKey));
      }
      showError(context, error);
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = ref.watch(doctorProvider(widget.doctorId));
    return doctor.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: AsyncView<void>(
          value: AsyncError(e, StackTrace.current),
          builder: (_) => const SizedBox(),
          onRetry: () => ref.invalidate(doctorProvider(widget.doctorId)),
        ),
      ),
      data: _buildForm,
    );
  }

  Widget _buildForm(Doctor doctor) {
    final text = Theme.of(context).textTheme;
    final wide = !Breakpoints.isMobile(context);
    final slots = ref.watch(slotsProvider(_slotKey));

    final picker = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DoctorHeader(doctor: doctor),
        const SectionHeader('Consultation Type'),
        SegmentedButton<ConsultationType>(
          segments: [
            for (final t in const [
              ConsultationType.chat,
              ConsultationType.voice,
              ConsultationType.video,
            ])
              ButtonSegment(value: t, icon: Icon(t.icon), label: Text(t.label)),
          ],
          selected: {_type},
          onSelectionChanged: (s) => setState(() => _type = s.first),
        ),
        const SectionHeader('Select Date'),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _days.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final d = _days[i];
              final selected = d == _day;
              return _SelectBox(
                selected: selected,
                width: 60,
                onTap: () => setState(() {
                  _day = d;
                  _slot = null;
                }),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(DateFormat('EEE').format(d),
                        style: text.labelSmall?.copyWith(
                            color: selected
                                ? Colors.white
                                : AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text('${d.day}',
                        style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : null)),
                  ],
                ),
              );
            },
          ),
        ),
        const SectionHeader('Select Time'),
        AsyncView(
          value: slots,
          onRetry: () => ref.invalidate(slotsProvider(_slotKey)),
          builder: (times) => times.isEmpty
              ? AppCard(
                  child: Text(
                    'No free times on this day. Try another date.',
                    style: text.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, c) {
                    final columns = c.maxWidth > 500 ? 4 : 3;
                    final width = (c.maxWidth - 10 * (columns - 1)) / columns;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final s in times)
                          _SelectBox(
                            width: width,
                            height: 44,
                            selected: _slot == s,
                            onTap: () => setState(() => _slot = s),
                            child: Text(
                              DateFormat('hh:mm a').format(s),
                              style: text.labelLarge?.copyWith(
                                color: _slot == s
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
        ),
        const SectionHeader('Reason for visit'),
        TextField(
          controller: _reason,
          maxLines: 2,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Briefly describe your symptoms (optional)',
          ),
        ),
      ],
    );

    final summary = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('Appointment Summary'),
        AppCard(
          child: Column(
            children: [
              _summaryRow('Doctor', doctor.name),
              _summaryRow('Specialization', doctor.specialty),
              _summaryRow('Type', _type.label),
              _summaryRow(
                'Date & Time',
                _slot == null
                    ? 'Choose a time'
                    : DateFormat('d MMM yyyy, h:mm a').format(_slot!),
              ),
              _summaryRow('Duration', '${doctor.slotMinutes} min'),
              const Divider(height: 24),
              _summaryRow(
                'Consultation fee',
                money(doctor.feeCents, doctor.currency),
                bold: true,
              ),
            ],
          ),
        ),
        if (wide) ...[
          const SizedBox(height: 20),
          _confirmButton(doctor),
        ],
      ],
    );

    return PageScaffold(
      title: 'Book Appointment',
      showBack: true,
      bottom: wide ? null : _confirmButton(doctor),
      children: [
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: picker),
              const SizedBox(width: 32),
              Expanded(flex: 2, child: summary),
            ],
          )
        else ...[
          picker,
          summary,
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _confirmButton(Doctor doctor) => FilledButton(
        onPressed: _booking || _slot == null ? null : () => _confirm(doctor),
        child: _booking
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(_slot == null
                ? 'Choose a time'
                : 'Confirm & pay ${money(doctor.feeCents, doctor.currency)}'),
      );

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style:
                    text.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(
              value,
              style: (bold ? text.titleSmall : text.bodyMedium)?.copyWith(
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorHeader extends StatelessWidget {
  const _DoctorHeader({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = text.bodySmall?.copyWith(color: AppColors.textSecondary);
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Avatar.fromName(doctor.name, size: 72, online: doctor.isOnline),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name,
                    style:
                        text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                Text(doctor.specialty, style: muted),
                const SizedBox(height: 4),
                RatingRow(rating: doctor.rating, reviews: doctor.reviews),
                const SizedBox(height: 6),
                Text(
                  [
                    if (doctor.hospital != null) doctor.hospital!,
                    if (doctor.about.isNotEmpty) doctor.about,
                  ].join(' · '),
                  style: muted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectBox extends StatelessWidget {
  const _SelectBox({
    required this.selected,
    required this.onTap,
    required this.child,
    this.width,
    this.height,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

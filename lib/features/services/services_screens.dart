import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/locale_controller.dart';
import '../../app/router/app_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/data/repositories.dart';
import '../../core/format.dart';
import '../../core/models/health.dart';
import '../../shared/widgets/common.dart';
import '../auth/auth_controller.dart';
import '../care/care_screens.dart';

IconData serviceIcon(String name) {
  final n = name.toLowerCase();
  if (n.contains('sample') || n.contains('lab')) return Icons.biotech_outlined;
  if (n.contains('nurse')) return Icons.vaccines_outlined;
  return Icons.home_outlined;
}

/// Home visits and other at-home services.
class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final l = context.l10n;
    return PageScaffold(
      title: l.homeServices,
      showBack: true,
      actions: [
        TextButton(
          onPressed: () => context.push(Routes.serviceRequests),
          child: Text(l.myRequests),
        ),
      ],
      children: [
        Text(
          l.homeServicesIntro,
          style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        AsyncView(
          value: ref.watch(servicesProvider),
          onRetry: () => ref.invalidate(servicesProvider),
          builder: (services) => services.isEmpty
              ? AppCard(child: Text(l.noHomeServices))
              : ResponsiveGrid(
                  minItemWidth: 320,
                  children: [
                    for (final s in services) ServiceCard(service: s),
                  ],
                ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.service, this.compact = false});

  final Service service;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      onTap: () => context.push(Routes.requestService(service.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: serviceIcon(service.name)),
              const Spacer(),
              Text(
                money(service.priceCents, service.currency),
                style: text.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(service.name, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          if (!compact && service.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(service.description,
                style: text.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ],
          if (!compact) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: () => context.push(Routes.requestService(service.id)),
                child: Text(context.l10n.request),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class RequestServiceScreen extends ConsumerStatefulWidget {
  const RequestServiceScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  ConsumerState<RequestServiceScreen> createState() => _RequestServiceScreenState();
}

class _RequestServiceScreenState extends ConsumerState<RequestServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _address = TextEditingController();
  late final _phone = TextEditingController(text: ref.read(currentUserProvider).phone ?? '');
  final _notes = TextEditingController();
  DateTime? _when;
  bool _sending = false;

  @override
  void dispose() {
    _address.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickWhen() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (time == null) return;
    setState(() => _when = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _submit(Service service) async {
    if (!_formKey.currentState!.validate()) return;
    if (_when == null) {
      showInfo(context, context.l10n.choosePreferredTime);
      return;
    }
    setState(() => _sending = true);
    try {
      await ref.read(serviceRequestRepositoryProvider).create(
            serviceId: service.id,
            address: _address.text.trim(),
            phone: _phone.text.trim(),
            preferredAt: _when!,
            notes: _notes.text.trim(),
          );
      ref.invalidate(serviceRequestsProvider);
      if (!mounted) return;
      showInfo(context, context.l10n.requestSent);
      // Replace the form so Back goes to the services list, not the form.
      context.pushReplacement(Routes.serviceRequests);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(servicesProvider);
    final service = services.value?.where((s) => s.id == widget.serviceId).firstOrNull;
    final text = Theme.of(context).textTheme;
    final l = context.l10n;

    if (service == null) {
      return PageScaffold(
        title: l.requestService,
        showBack: true,
        children: [
          AsyncView(
            value: services,
            onRetry: () => ref.invalidate(servicesProvider),
            builder: (_) => AppCard(child: Text(l.serviceUnavailable)),
          ),
        ],
      );
    }

    return PageScaffold(
      title: service.name,
      showBack: true,
      bottom: FilledButton(
        onPressed: _sending ? null : () => _submit(service),
        child: Text(l.requestWithPrice(money(service.priceCents, service.currency))),
      ),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (service.description.isNotEmpty)
                  Text(service.description,
                      style: text.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                SectionHeader(l.whereShouldWeCome),
                TextFormField(
                  controller: _address,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(hintText: l.addressHint),
                  validator: (v) =>
                      (v?.trim().length ?? 0) < 5 ? l.enterFullAddress : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: l.phoneHint,
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  validator: (v) => RegExp(r'^\+?[0-9 ]{9,16}$').hasMatch(v?.trim() ?? '')
                      ? null
                      : l.enterValidPhone,
                ),
                SectionHeader(l.when),
                AppCard(
                  onTap: _pickWhen,
                  child: Row(
                    children: [
                      const IconBadge(icon: Icons.event_rounded, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _when == null
                              ? l.choosePreferredTimeNoDot
                              : DateFormat('EEEE d MMMM, h:mm a').format(_when!),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
                SectionHeader(l.notesForTeam),
                TextFormField(
                  controller: _notes,
                  maxLines: 3,
                  maxLength: 1000,
                  decoration: InputDecoration(hintText: l.notesForTeamHint),
                ),
                Text(
                  l.payWhenConfirmed,
                  style: text.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class ServiceRequestsScreen extends ConsumerWidget {
  const ServiceRequestsScreen({super.key});

  Future<void> _cancel(BuildContext context, WidgetRef ref, ServiceRequest r) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.cancelRequestQ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.keep)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.cancelRequest),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(serviceRequestRepositoryProvider).cancel(r.id);
      ref.invalidate(serviceRequestsProvider);
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final muted = text.bodySmall?.copyWith(color: AppColors.textSecondary);
    final l = context.l10n;
    return PageScaffold(
      title: l.myHomeServiceRequests,
      showBack: true,
      children: [
        AsyncView(
          value: ref.watch(serviceRequestsProvider),
          onRetry: () => ref.invalidate(serviceRequestsProvider),
          builder: (list) => list.isEmpty
              ? AppCard(
                  onTap: () => context.push(Routes.services),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const IconBadge(icon: Icons.home_outlined),
                    title: Text(l.noRequestsYet),
                    subtitle: Text(l.browseHomeServices),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                )
              : Column(
                  children: [
                    for (final r in list)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  IconBadge(icon: serviceIcon(r.serviceName), size: 40),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(r.serviceName,
                                            style: text.titleSmall
                                                ?.copyWith(fontWeight: FontWeight.w600)),
                                        Text(DateFormat('EEE d MMM, h:mm a').format(r.preferredAt),
                                            style: muted),
                                      ],
                                    ),
                                  ),
                                  _RequestStatus(r.status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(r.address, style: muted),
                              if (r.adminNote?.isNotEmpty ?? false) ...[
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySoft,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(l.fromDaktariNow(r.adminNote!)),
                                ),
                              ],
                              Row(
                                children: [
                                  Text(money(r.priceCents, r.currency), style: muted),
                                  const Spacer(),
                                  if (r.status == ServiceRequestStatus.requested)
                                    TextButton(
                                      style: TextButton.styleFrom(
                                          foregroundColor: AppColors.danger),
                                      onPressed: () => _cancel(context, ref, r),
                                      child: Text(l.cancel),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _RequestStatus extends StatelessWidget {
  const _RequestStatus(this.status);

  final ServiceRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      ServiceRequestStatus.requested => (AppColors.amberSoft, const Color(0xFF9A6200)),
      ServiceRequestStatus.confirmed => (AppColors.primarySoft, AppColors.primaryDark),
      ServiceRequestStatus.completed => (const Color(0xFFE5F8F0), AppColors.success),
      ServiceRequestStatus.cancelled => (AppColors.accentSoft, AppColors.danger),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(status.label(context.l10n),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              )),
    );
  }
}

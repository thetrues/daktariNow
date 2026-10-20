import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/layout/breakpoints.dart';
import '../../../app/locale_controller.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/data/repositories.dart';
import '../../../core/format.dart';
import '../../../core/models/wallet.dart';
import '../../../shared/widgets/common.dart';
import '../doctor_providers.dart';

/// Doctor wallet. Balances come from the backend's double-entry ledger:
/// consultation fee minus platform commission, credited on completion.
class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  Future<void> _requestPayout(
      BuildContext context, WidgetRef ref, WalletSummary w) async {
    final result = await showDialog<(int, String)>(
      context: context,
      builder: (_) => _PayoutDialog(summary: w),
    );
    if (result == null || !context.mounted) return;
    try {
      await ref
          .read(walletRepositoryProvider)
          .requestPayout(result.$1, result.$2);
      ref.invalidate(walletSummaryProvider);
      if (context.mounted) {
        showInfo(context, context.l10n.payoutRequested);
      }
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final wide = !Breakpoints.isMobile(context);
    final summary = ref.watch(walletSummaryProvider);
    final transactions = ref.watch(walletTransactionsProvider);
    final l = context.l10n;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(walletSummaryProvider);
        ref.invalidate(walletTransactionsProvider);
      },
      child: PageScaffold(
        title: l.navEarnings,
        children: [
          AsyncView(
            value: summary,
            onRetry: () => ref.invalidate(walletSummaryProvider),
            builder: (w) {
              final balance = Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.availableBalance,
                        style: text.bodyMedium?.copyWith(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(money(w.availableCents, w.currency),
                        style: text.displaySmall?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      [
                        l.inEscrow(money(w.inEscrowCents, w.currency)),
                        if (w.pendingPayoutCents > 0)
                          l.payoutPending(money(w.pendingPayoutCents, w.currency)),
                      ].join(' · '),
                      style: text.bodySmall?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: w.availableCents >= w.minPayoutCents
                          ? () => _requestPayout(context, ref, w)
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryDark,
                        minimumSize: const Size(180, 46),
                      ),
                      icon: const Icon(Icons.account_balance_rounded),
                      label: Text(l.requestPayout),
                    ),
                  ],
                ),
              );
              final tiles = Column(
                children: [
                  _summaryTile(context, l.thisMonth,
                      money(w.thisMonthCents, w.currency), Icons.trending_up),
                  const SizedBox(height: 12),
                  _summaryTile(context, l.completedConsultations,
                      '${w.completedConsultations}', Icons.event_available),
                  const SizedBox(height: 12),
                  _summaryTile(context, l.platformCommission,
                      '${w.commissionBps / 100}%', Icons.percent),
                ],
              );
              return wide
                  ? IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 3, child: balance),
                          const SizedBox(width: 16),
                          Expanded(flex: 2, child: tiles),
                        ],
                      ),
                    )
                  : Column(children: [balance, const SizedBox(height: 12), tiles]);
            },
          ),
          SectionHeader(l.recentTransactions),
          AsyncView(
            value: transactions,
            onRetry: () => ref.invalidate(walletTransactionsProvider),
            builder: (items) => items.isEmpty
                ? AppCard(child: Text(l.earningsAppearHere))
                : AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (final t in items)
                          _TransactionTile(
                            transaction: t,
                            currency: summary.value?.currency ?? 'TZS',
                          ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _summaryTile(
      BuildContext context, String label, String value, IconData icon) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      child: Row(
        children: [
          IconBadge(icon: icon, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style:
                    text.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          ),
          Text(value,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, required this.currency});

  final WalletTransaction transaction;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final t = transaction;
    final credit = t.amountCents > 0;
    return ListTile(
      leading: IconBadge(
        icon: credit ? Icons.south_west_rounded : Icons.north_east_rounded,
        color: credit ? AppColors.success : AppColors.accent,
        background: credit ? const Color(0xFFE5F8F0) : AppColors.accentSoft,
        size: 38,
      ),
      title: Text(t.description, style: text.bodyMedium),
      subtitle: Text(DateFormat('d MMM yyyy, h:mm a').format(t.createdAt),
          style: text.bodySmall),
      trailing: Text(
        '${credit ? '+' : '−'}${money(t.amountCents.abs(), currency)}',
        style: text.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: credit ? AppColors.success : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _PayoutDialog extends StatefulWidget {
  const _PayoutDialog({required this.summary});

  final WalletSummary summary;

  @override
  State<_PayoutDialog> createState() => _PayoutDialogState();
}

class _PayoutDialogState extends State<_PayoutDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _amount = TextEditingController(
      text: moneyInput(widget.summary.availableCents, widget.summary.currency));
  final _destination = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    _destination.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final minor = parseMoney(_amount.text, widget.summary.currency)!;
    Navigator.pop(context, (minor, _destination.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.summary;
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.requestPayout),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _amount,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: displayDecimals(w.currency) > 0,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(moneyInputPattern(w.currency)),
                ],
                decoration: InputDecoration(
                  labelText: l.amount,
                  prefixText: '${currencySymbol(w.currency)} ',
                  helperText: l.payoutHelper(money(w.availableCents, w.currency),
                      money(w.minPayoutCents, w.currency)),
                ),
                validator: (v) {
                  final minor = parseMoney(v ?? '', w.currency);
                  if (minor == null) return l.enterAmount;
                  if (minor < w.minPayoutCents) {
                    return l.minimumIs(money(w.minPayoutCents, w.currency));
                  }
                  if (minor > w.availableCents) return l.moreThanAvailable;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _destination,
                decoration: InputDecoration(
                  labelText: l.sendTo,
                  hintText: l.sendToHint,
                ),
                validator: (v) =>
                    (v?.trim().length ?? 0) < 4 ? l.whereSendMoney : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l.request)),
      ],
    );
  }
}

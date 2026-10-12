class WalletSummary {
  const WalletSummary(this.json);

  final Map<String, dynamic> json;

  String get currency => json['currency'] as String;
  int get balanceCents => json['balanceCents'] as int;
  int get availableCents => json['availableCents'] as int;
  int get pendingPayoutCents => json['pendingPayoutCents'] as int;
  int get inEscrowCents => json['inEscrowCents'] as int;
  int get thisMonthCents => json['thisMonthCents'] as int;
  int get completedConsultations => json['completedConsultations'] as int;
  int get commissionBps => json['commissionBps'] as int;
  int get minPayoutCents => json['minPayoutCents'] as int? ?? 0;
}

class WalletTransaction {
  const WalletTransaction(this.json);

  final Map<String, dynamic> json;

  String get id => json['id'] as String;
  String get kind => json['kind'] as String;
  String get description => json['description'] as String;
  int get amountCents => json['amountCents'] as int;
  DateTime get createdAt => DateTime.parse(json['createdAt'] as String).toLocal();
}

/// Weekly availability window in the doctor's timezone.
class AvailabilityWindow {
  const AvailabilityWindow(this.weekday, this.startMinute, this.endMinute);

  factory AvailabilityWindow.fromJson(Map<String, dynamic> j) =>
      AvailabilityWindow(
        j['weekday'] as int,
        j['startMinute'] as int,
        j['endMinute'] as int,
      );

  /// ISO weekday: 1 = Monday … 7 = Sunday.
  final int weekday;
  final int startMinute;
  final int endMinute;

  Map<String, dynamic> toJson() =>
      {'weekday': weekday, 'startMinute': startMinute, 'endMinute': endMinute};
}

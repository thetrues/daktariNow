class Specialty {
  const Specialty(this.id, this.name);

  factory Specialty.fromJson(Map<String, dynamic> j) =>
      Specialty(j['id'] as String, j['name'] as String);

  final String id;
  final String name;
}

class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.yearsExperience,
    required this.feeCents,
    required this.currency,
    required this.hospital,
    required this.about,
    this.isOnline = false,
    this.slotMinutes = 30,
    this.timezone = 'UTC',
  });

  factory Doctor.fromJson(Map<String, dynamic> j) => Doctor(
        id: j['id'] as String,
        name: j['name'] as String,
        specialty: (j['specialty'] as Map<String, dynamic>)['name'] as String,
        rating: (j['rating'] as num).toDouble(),
        reviews: j['reviewCount'] as int,
        yearsExperience: j['yearsExperience'] as int,
        feeCents: j['feeCents'] as int,
        currency: j['currency'] as String,
        hospital: (j['hospital'] as Map<String, dynamic>?)?['name'] as String?,
        about: j['bio'] as String? ?? '',
        isOnline: j['isOnline'] as bool? ?? false,
        slotMinutes: j['slotMinutes'] as int? ?? 30,
        timezone: j['timezone'] as String? ?? 'UTC',
      );

  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviews;
  final int yearsExperience;
  final int feeCents;
  final String currency;
  final String? hospital;
  final String about;
  final bool isOnline;
  final int slotMinutes;
  final String timezone;
}

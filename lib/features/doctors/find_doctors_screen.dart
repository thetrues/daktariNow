import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/data/repositories.dart';
import '../../core/models/doctor.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/doctor_tile.dart';

typedef DoctorQuery = ({String query, String? specialtyId});

final doctorSearchProvider =
    FutureProvider.autoDispose.family<List<Doctor>, DoctorQuery>(
  (ref, q) => ref
      .watch(doctorRepositoryProvider)
      .search(query: q.query, specialtyId: q.specialtyId),
);

class FindDoctorsScreen extends ConsumerStatefulWidget {
  const FindDoctorsScreen({super.key});

  @override
  ConsumerState<FindDoctorsScreen> createState() => _FindDoctorsScreenState();
}

class _FindDoctorsScreenState extends ConsumerState<FindDoctorsScreen> {
  String _query = '';
  String? _specialtyId;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _query = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = (query: _query, specialtyId: _specialtyId);
    final results = ref.watch(doctorSearchProvider(q));
    final specialties = ref.watch(specialtiesProvider).value ?? const [];

    return PageScaffold(
      title: 'Find Doctors',
      showBack: true,
      children: [
        TextField(
          onChanged: _onSearch,
          decoration: const InputDecoration(
            hintText: 'Search doctors, specialists...',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _chip('All', _specialtyId == null, () => _specialtyId = null),
              for (final s in specialties)
                _chip(s.name, _specialtyId == s.id, () => _specialtyId = s.id),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AsyncView(
          value: results,
          onRetry: () => ref.invalidate(doctorSearchProvider(q)),
          builder: (doctors) => doctors.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('No doctors match your search.')),
                )
              : ResponsiveGrid(
                  minItemWidth: 360,
                  children: [
                    for (final d in doctors)
                      DoctorTile(
                        doctor: d,
                        onTap: () => context.push(Routes.book(d.id)),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _chip(String label, bool selected, VoidCallback select) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.textPrimary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
        onSelected: (_) => setState(select),
      ),
    );
  }
}

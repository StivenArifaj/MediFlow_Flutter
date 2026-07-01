import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/supabase_data_service.dart';
import '../../core/hooks/managed_user_id.dart';

final latestMeasurementsProvider =
    FutureProvider<Map<String, Map<String, dynamic>>>((ref) async {
  final userId = await ref.watch(managedUserIdProvider.future);
  if (userId == null) return {};
  return ref.read(supabaseDataServiceProvider).getLatestMeasurements(userId);
});

final measurementsForTypeProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, type) async {
  final userId = await ref.watch(managedUserIdProvider.future);
  if (userId == null) return [];
  return ref.read(supabaseDataServiceProvider).getMeasurements(userId, type: type);
});

class MeasurementNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addMeasurement({
    required String type,
    required double value,
    double? valueSecondary,
    required String unit,
    String? notes,
  }) async {
    final userId = await ref.read(managedUserIdProvider.future);
    if (userId == null) throw Exception('Not logged in');
    await ref.read(supabaseDataServiceProvider).createMeasurement(
      userId: userId,
      type: type,
      value: value,
      valueSecondary: valueSecondary,
      unit: unit,
      notes: notes,
    );
    ref.invalidate(latestMeasurementsProvider);
    ref.invalidate(measurementsForTypeProvider(type));
  }

  Future<void> deleteMeasurement(String id, String type) async {
    await ref.read(supabaseDataServiceProvider).deleteMeasurement(id);
    ref.invalidate(latestMeasurementsProvider);
    ref.invalidate(measurementsForTypeProvider(type));
  }
}

final measurementNotifierProvider =
    AsyncNotifierProvider<MeasurementNotifier, void>(MeasurementNotifier.new);

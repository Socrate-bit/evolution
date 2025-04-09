import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/statistics/data/statistics_model.dart';
import 'package:tracker_v1/statistics/data/statistics_provider.dart';

class StatisticsState {
  final int selectedPeriod;
  final int offset;
  final int selectedStat;
  final int? selectedStat2;
  final DateTime? pickedStartDate;
  final DateTime? pickedEndDate;
  final List<Stat> allStats;

  StatisticsState({
    this.selectedPeriod = 1,
    this.offset = 0,
    this.selectedStat = 0,
    this.selectedStat2,
    this.pickedStartDate,
    this.pickedEndDate,
    this.allStats = const [],
  });

  StatisticsState copyWithNulldate() {
    return StatisticsState(
      selectedPeriod: selectedPeriod,
      offset: 0,
      selectedStat: selectedStat,
      selectedStat2: selectedStat2,
      pickedStartDate: null,
      pickedEndDate: null,
      allStats: allStats,
    );
  }

  StatisticsState copyWith({
    int? selectedPeriod,
    int? offset,
    int? selectedStat,
    int? selectedStat2 = -1,
    DateTime? pickedStartDate,
    DateTime? pickedEndDate,
    List<Stat>? allStats,
  }) {
    return StatisticsState(
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      offset: offset ?? this.offset,
      selectedStat: selectedStat ?? this.selectedStat,
      selectedStat2: selectedStat2 == -1 ? this.selectedStat2 : selectedStat2,
      pickedStartDate: pickedStartDate ?? this.pickedStartDate,
      pickedEndDate: pickedEndDate ?? this.pickedEndDate,
      allStats: allStats ?? this.allStats,
    );
  }
}

class StatisticsNotifier extends StateNotifier<StatisticsState> {
  StatisticsNotifier(this.ref)
      : super(StatisticsState(
            allStats: ref.read(statNotiferProvider)
              ..sort((a, b) => a.index.compareTo(b.index)))) {
    // Listen to statNotifierProvider changes
    ref.listen<List<Stat>>(statNotiferProvider, (previous, next) {
      state = state.copyWith(allStats: next);
    });
  }

  Ref ref;

  void updateSelectedPeriod(int index) => state =
      state.copyWith(selectedPeriod: index, offset: 0);

  void updateOffset(int value) =>
      state = state.copyWith(offset: state.offset + value);
  void updateSelectedStat(int index) =>
      state = state.copyWith(selectedStat: index);
  void updateSelectedStat2(int? index) =>
      state = state.copyWith(selectedStat2: index);
  void updatePickedStartDate(DateTime? date) =>
      state = state.copyWith(pickedStartDate: date);
  void updatePickedEndDate(DateTime? date) =>
      state = state.copyWith(pickedEndDate: date);
  void resetDate() => state = state.copyWithNulldate();
  void resetState() => state = StatisticsState(
      allStats: ref.read(statNotiferProvider)
        ..sort((a, b) => a.index.compareTo(b.index)));
}

final statisticsStateProvider =
    StateNotifierProvider.autoDispose<StatisticsNotifier, StatisticsState>(
  (ref) => StatisticsNotifier(ref),
);

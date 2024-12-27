import 'package:flutter_riverpod/flutter_riverpod.dart';

final additionalMetricsProvider = StateNotifierProvider<AdditionalMetricsNotifier, List<String>>((ref) {
  return AdditionalMetricsNotifier();
});

class AdditionalMetricsNotifier extends StateNotifier<List<String>> {
  AdditionalMetricsNotifier() : super([]);

  void addMetric(String metric) {
    if (state.length < 5) {
      state = [...state, metric];
    }
  }

  void removeMetric(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
  }
}
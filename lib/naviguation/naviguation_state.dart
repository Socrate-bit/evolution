import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationState {
  final int currentIndex;

  NavigationState(this.currentIndex);
}

class NavigationStateNotifier extends StateNotifier<NavigationState> {
  NavigationStateNotifier() : super(NavigationState(0));

  void setIndex(int index) {
    state = NavigationState(index);
  }

  void cleanState() {
    state = NavigationState(0);
  }
}

final navigationStateProvider = StateNotifierProvider<NavigationStateNotifier, NavigationState>((ref) {
  return NavigationStateNotifier();
});
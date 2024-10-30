extension DoubleExtension on double {
  dynamic customRound(int num) {
    return double.parse(
      this
          .toStringAsFixed(num)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), ''),
    );
  }
}

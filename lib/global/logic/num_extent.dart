extension numExtent on num {
  String roundNum({int decimal = 1}) {
    if (this == this.toInt()) {
      return this.toInt().toString();
    } else {
      return this
          .toStringAsFixed(decimal)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
  }
}

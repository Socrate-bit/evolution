/// String capitalize extension
extension StringExtension on String {
  /// Capitalize string
  String capitalizeString() {
    if (this.isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

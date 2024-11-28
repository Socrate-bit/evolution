double? computeMaxList(List<double?> list) {
  List<double> filteredList = list.whereType<double>().toList();
  if (filteredList.isEmpty) return null;
  return filteredList.reduce((a, b) => a > b ? a : b);
}

double? computeMinList(List<double?> list) {
  List<double> filteredList = list.whereType<double>().toList();
  if (filteredList.isEmpty) return null;
  return filteredList.reduce((a, b) => a < b ? a : b);
}

double? computeMeanList(List<double?> list) {
  List<double> filteredList = list.whereType<double>().toList();
  if (filteredList.isEmpty) return null;
  return filteredList.reduce((a, b) => a + b) / filteredList.length;
}


import 'dart:math';

double? computeCorrelation(List<double?> data1, List<double?> data2) {
  (List<double>, List<double>) filteredData = _deleteMissingData(data1, data2);

  double? correlation =
      _computePearsonCorrelation(filteredData.$1, filteredData.$2);
  return correlation;
}

(List<double>, List<double>) _deleteMissingData(
    List<double?> list1, List<double?> list2) {
  List<double> filteredList1 = [];
  List<double> filteredList2 = [];

  for (int i = 0; i < list1.length; i++) {
    if (list1[i] != null && list2[i] != null) {
      filteredList1.add(list1[i]!);
      filteredList2.add(list2[i]!);
    }
  }

  return (filteredList1, filteredList2);
}

double? _computePearsonCorrelation(List<double> x, List<double> y) {
  if (x.length != y.length || x.isEmpty) {
    return null;
  }
  int n = x.length;
  double meanX = x.reduce((a, b) => a + b) / n;
  double meanY = y.reduce((a, b) => a + b) / n;

  double numerator = 0, sumSquaredX = 0, sumSquaredY = 0;

  for (int i = 0; i < n; i++) {
    double deltaX = x[i] - meanX;
    double deltaY = y[i] - meanY;

    numerator += deltaX * deltaY;
    sumSquaredX += deltaX * deltaX;
    sumSquaredY += deltaY * deltaY;
  }

  double denominator = sqrt(sumSquaredX * sumSquaredY);

  if (denominator == 0) {
    return null;
  }

  double correlation = numerator / denominator;
  return correlation;
}


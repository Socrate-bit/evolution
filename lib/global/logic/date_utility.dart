import 'package:intl/intl.dart';

DateTime now = DateTime.now();
DateTime today = DateTime(now.year, now.month, now.day);
final formater1 = DateFormat('d MMM');
final formater3 = DateFormat('d MMM yyyy');
final formater2 = DateFormat('d');

String getOrdinalSuffix(int day) {
  if (day >= 11 && day <= 13) {
    return 'th';
  }
  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

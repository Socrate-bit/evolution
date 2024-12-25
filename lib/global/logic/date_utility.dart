import 'package:intl/intl.dart';

DateTime now = DateTime.now();
DateTime today = DateTime(now.year, now.month, now.day);

final formater1 = DateFormat('d MMM');
final formater2 = DateFormat('d');
final formater3 = DateFormat('d MMM yyyy');
final formater4 = DateFormat('dd/MM/yy');

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

String displayedDate(date) {
  if (today == date) {
    return 'Today';
  } else if (today.add(Duration(days: 1)) == date) {
    return 'Tomorrow';
  } else if (today.subtract(Duration(days: 1)) == date) {
    return 'Yesterday';
  } else {
    return formater1.format(date);
  }
}

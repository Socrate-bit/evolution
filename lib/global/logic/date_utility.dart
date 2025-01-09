import 'package:intl/intl.dart';

DateTime get now {
  return DateTime.now();
}

DateTime get today {
  DateTime currentNow = now;
  return DateTime(currentNow.year, currentNow.month, currentNow.day);
}

DateTime get yesterday {
  DateTime currentNow = now;
  return DateTime(currentNow.year, currentNow.month, currentNow.day - 1);
}

DateTime get tomorrow {
  DateTime currentNow = now;
  return DateTime(currentNow.year, currentNow.month, currentNow.day + 1);
}

DateTime get inTwoDays {
  DateTime currentNow = now;
  return DateTime(currentNow.year, currentNow.month, currentNow.day + 2);
}

DateTime get inThreeDays {
  DateTime currentNow = now;
  return DateTime(currentNow.year, currentNow.month, currentNow.day + 3);
}

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

String displayedDate(date, {DateFormat? formater}) {
  if (today == date) {
    return 'Today';
  } else if (today.add(Duration(days: 1)) == date) {
    return 'Tomorrow';
  } else if (today.subtract(Duration(days: 1)) == date) {
    return 'Yesterday';
  } else {
    return formater?.format(date) ?? formater1.format(date);
  }
}

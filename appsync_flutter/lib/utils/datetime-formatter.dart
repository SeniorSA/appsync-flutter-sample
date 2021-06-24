import 'package:intl/intl.dart';

DateTime iso8601ToDateTime(String dateTime, {String pattern = 'yyyy-MM-ddTHH:mm:ssZ'}) {
  final DateFormat formatter = DateFormat(pattern);
  return formatter.parseUTC(dateTime).toLocal();
}
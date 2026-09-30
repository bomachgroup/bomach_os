import 'package:intl/intl.dart';

const appDatePattern = 'dd-MM-yyyy';
const apiDatePattern = 'yyyy-MM-dd';

String formatAppDate(DateTime date) => DateFormat(appDatePattern).format(date);

DateTime? parseAppDate(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  try {
    return DateFormat(appDatePattern).parseStrict(text);
  } catch (_) {
    return DateTime.tryParse(text);
  }
}

String? appDateToApiDate(String? value) {
  final date = parseAppDate(value);
  return date == null ? null : DateFormat(apiDatePattern).format(date);
}

String formatAppDateValue(String? value, {String fallback = ''}) {
  final date = parseAppDate(value);
  return date == null ? fallback : formatAppDate(date.toLocal());
}

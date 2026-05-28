import '../models/reminder_model.dart';

/// Small date/time formatter for compact app labels.
///
/// The app does not need localization-heavy formatting yet, so this keeps the
/// current hand-written labels centralized and easy to replace later.
class DateFormatService {
  const DateFormatService();

  static const List<String> _shortMonths = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String shortMonthDate(DateTime date) {
    return '${_shortMonths[date.month]} ${date.day}, ${date.year}';
  }

  String compactMonthDay(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day';
  }

  String clockTime(DateTime date) {
    return _clockTime(hour: date.hour, minute: date.minute);
  }

  String reminderTime(ReminderModel reminder) {
    return _clockTime(hour: reminder.hour, minute: reminder.minute);
  }

  String compactDateTime(DateTime date) {
    final displayHour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final displayMinute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${compactMonthDay(date)} - $displayHour-$displayMinute $period';
  }

  String _clockTime({required int hour, required int minute}) {
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final displayMinute = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';

    return '$displayHour:$displayMinute $period';
  }
}

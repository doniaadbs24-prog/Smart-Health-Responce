import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, HH:mm');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _shortDateFormat = DateFormat('dd/MM/yyyy');

  static String date(DateTime? value) =>
      value == null ? '-' : _dateFormat.format(value);

  static String dateTime(DateTime? value) =>
      value == null ? '-' : _dateTimeFormat.format(value);

  static String time(DateTime? value) =>
      value == null ? '-' : _timeFormat.format(value);

  static String shortDate(DateTime? value) =>
      value == null ? '-' : _shortDateFormat.format(value);

  static String relative(DateTime value) {
    final diff = DateTime.now().difference(value);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _dateFormat.format(value);
  }

  static String distanceKm(double meters) {
    if (meters < 1000) return '${meters.toStringAsFixed(0)} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  static String duration(Duration value) {
    if (value.inMinutes < 1) return '${value.inSeconds}s';
    if (value.inHours < 1) return '${value.inMinutes} min';
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  static String etaFromMinutes(int minutes) {
    if (minutes < 1) return 'Less than a minute';
    if (minutes < 60) return 'After $minutes minutes';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? 'After ${h}h' : 'After ${h}h ${m}m';
  }

  static String phone(String value) {
    final clean = value.replaceAll(RegExp(r'\s+'), '');
    if (clean.startsWith('+966') && clean.length == 13) {
      return '+966 ${clean.substring(4, 6)} ${clean.substring(6, 9)} ${clean.substring(9)}';
    }
    return value;
  }

  static String currency(double value, {String symbol = 'SAR'}) =>
      '$symbol ${value.toStringAsFixed(2)}';

  static String capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
}

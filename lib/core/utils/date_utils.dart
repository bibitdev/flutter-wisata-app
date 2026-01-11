import 'package:intl/intl.dart';

class AppDateUtils {
  /// Get current DateTime in WIB timezone (UTC+7)
  /// Gunakan ini untuk semua transaksi agar konsisten dengan server Laravel
  static DateTime nowWIB() {
    // Get UTC time and add 7 hours for WIB
    final utcNow = DateTime.now().toUtc();
    return utcNow.add(const Duration(hours: 7));
  }

  /// Convert DateTime to ISO 8601 string in WIB timezone
  /// Format: 2026-01-09T14:30:00.000Z
  static String toIso8601StringWIB(DateTime dateTime) {
    // Ensure we're working with WIB time
    return dateTime.toIso8601String();
  }

  /// Get current transaction time in ISO 8601 format (WIB)
  /// Shortcut untuk transaksi
  static String transactionTimeNow() {
    return nowWIB().toIso8601String();
  }

  /// Format DateTime to readable Indonesian format
  /// Format: 09 Januari 2026, 14:30 WIB
  static String toReadableIndonesian(DateTime dateTime) {
    final formatter = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');
    return '${formatter.format(dateTime)} WIB';
  }

  /// Format to date only (Indonesian)
  /// Format: 09 Januari 2026
  static String toDateOnly(DateTime dateTime) {
    final formatter = DateFormat('dd MMMM yyyy', 'id_ID');
    return formatter.format(dateTime);
  }

  /// Check if current day is weekend (Saturday or Sunday)
  /// Returns true if weekend, false if weekday
  static bool isWeekend() {
    final now = nowWIB();
    // DateTime.weekday: 1 (Monday) to 7 (Sunday)
    // Saturday = 6, Sunday = 7
    return now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
  }

  /// Check if current day is weekday (Monday to Friday)
  /// Returns true if weekday, false if weekend
  static bool isWeekday() {
    return !isWeekend();
  }

  /// Get current day type as string
  /// Returns 'weekend' or 'weekday'
  static String getDayType() {
    return isWeekend() ? 'weekend' : 'weekday';
  }
}

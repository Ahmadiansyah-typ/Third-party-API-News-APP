import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(String value) {
    if (value.trim().isEmpty) {
      return 'Tanggal tidak tersedia';
    }

    try {
      final date = DateTime.parse(value).toLocal();

      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
    } catch (_) {
      return 'Tanggal tidak valid';
    }
  }
}

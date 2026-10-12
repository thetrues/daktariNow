import 'package:intl/intl.dart';

export 'money.dart';

/// `2026-03-02` style date for API query parameters.
String isoDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

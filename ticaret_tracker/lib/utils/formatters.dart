import 'package:intl/intl.dart';

final _currencyFormat = NumberFormat('#,##0.##');
final _dateFormat = DateFormat('dd.MM.yyyy');
final _dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');

String formatMoney(double value) => '${_currencyFormat.format(value)} ₼';
String formatDate(DateTime date) => _dateFormat.format(date);
String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

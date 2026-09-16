import 'package:intl/intl.dart';

final NumberFormat _intFormatter = NumberFormat('#,##0');
final NumberFormat _currencyFormatter = NumberFormat('#,##0.00');

/// Formats any number or numeric string with standard commas.
/// E.g. 1000000 -> "1,000,000", 1234.56 -> "1,234.56"
String formatNumber(dynamic value, {int? decimals}) {
  if (value == null) return '0';
  num? parsed;
  if (value is num) {
    parsed = value;
  } else if (value is String) {
    if (value.trim().isEmpty) return '0';
    parsed = num.tryParse(value.replaceAll(',', '').trim());
  }
  if (parsed == null) return value.toString();

  if (decimals != null) {
    if (decimals == 0) return _intFormatter.format(parsed.round());
    final fmt = NumberFormat('#,##0.${'0' * decimals}');
    return fmt.format(parsed);
  }

  // Auto-detect: integer vs floating point
  if (parsed is int || parsed == parsed.roundToDouble()) {
    return _intFormatter.format(parsed);
  }
  return _currencyFormatter.format(parsed);
}

/// Formats an integer count with commas (e.g. 1500 -> "1,500").
String formatCount(dynamic value) {
  return formatNumber(value, decimals: 0);
}

/// Formats a value as Nigerian Naira with commas (e.g. "₦1,250,000.00").
String formatCurrency(
  dynamic value, {
  String symbol = '₦',
  int decimals = 2,
  bool compact = false,
}) {
  if (value == null) return '${symbol}0.00';
  num? parsed;
  if (value is num) {
    parsed = value;
  } else if (value is String) {
    if (value.trim().isEmpty) return '${symbol}0.00';
    parsed = num.tryParse(value.replaceAll(symbol, '').replaceAll(',', '').trim());
  }
  if (parsed == null) return '$symbol$value';

  if (compact) {
    if (parsed >= 1000000000) {
      return '$symbol${(parsed / 1000000000).toStringAsFixed(1)}B';
    }
    if (parsed >= 1000000) {
      return '$symbol${(parsed / 1000000).toStringAsFixed(1)}M';
    }
    if (parsed >= 1000) {
      return '$symbol${_intFormatter.format(parsed / 1000)}K';
    }
  }

  final fmt = decimals > 0
      ? NumberFormat('#,##0.${'0' * decimals}')
      : _intFormatter;
  return '$symbol${fmt.format(parsed)}';
}

/// Extension on nullable num for easy inline formatting.
extension NumberFormattingNumExt on num? {
  String toCommas({int? decimals}) => formatNumber(this, decimals: decimals);
  String toCount() => formatCount(this);
  String toNaira({int decimals = 2, bool compact = false}) =>
      formatCurrency(this, symbol: '₦', decimals: decimals, compact: compact);
}

/// Extension on nullable String for easy inline formatting.
extension NumberFormattingStringExt on String? {
  String toCommas({int? decimals}) => formatNumber(this, decimals: decimals);
  String toCount() => formatCount(this);
  String toNaira({int decimals = 2, bool compact = false}) =>
      formatCurrency(this, symbol: '₦', decimals: decimals, compact: compact);
}

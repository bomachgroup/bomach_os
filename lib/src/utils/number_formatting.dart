import 'package:flutter/services.dart';
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

/// Formats a displayed value with its unit, using the compact percent symbol.
String formatValueWithUnit(String value, String? unit) {
  final normalizedUnit = unit?.trim() ?? '';
  if (normalizedUnit.isEmpty) return value;
  if (normalizedUnit == '%' || normalizedUnit.toLowerCase() == 'percentage') {
    return '$value%';
  }
  return '$value $normalizedUnit';
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
    parsed =
        num.tryParse(value.replaceAll(symbol, '').replaceAll(',', '').trim());
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

  final fmt =
      decimals > 0 ? NumberFormat('#,##0.${'0' * decimals}') : _intFormatter;
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

/// Parses a formatted string with commas (e.g. "1,250,000.50") into a raw [num].
num? parseFormattedNumber(String? text) {
  if (text == null || text.trim().isEmpty) return null;
  return num.tryParse(text.replaceAll(',', '').replaceAll('₦', '').trim());
}

/// A [TextInputFormatter] that formats numeric inputs with thousand-separator commas
/// in real time while typing, preserving cursor position.
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final bool allowDecimals;
  final int decimalRange;

  ThousandsSeparatorInputFormatter({
    this.allowDecimals = true,
    this.decimalRange = 2,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Strip non-digits and non-decimal characters
    String cleanText = newValue.text.replaceAll(',', '');
    if (allowDecimals) {
      cleanText = cleanText.replaceAll(RegExp(r'[^0-9.]'), '');
    } else {
      cleanText = cleanText.replaceAll(RegExp(r'[^0-9]'), '');
    }

    if (cleanText.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Limit to single decimal point
    List<String> parts = cleanText.split('.');
    if (parts.length > 2) {
      cleanText = '${parts[0]}.${parts.sublist(1).join('')}';
      parts = cleanText.split('.');
    }

    String wholeStr = parts[0];
    String? fractionStr = parts.length > 1 ? parts[1] : null;

    if (fractionStr != null && fractionStr.length > decimalRange) {
      fractionStr = fractionStr.substring(0, decimalRange);
    }

    String formattedWhole = '';
    if (wholeStr.isNotEmpty) {
      final wholeNum = int.tryParse(wholeStr);
      if (wholeNum != null) {
        formattedWhole = _intFormatter.format(wholeNum);
      } else {
        formattedWhole = wholeStr;
      }
    }

    String formatted = formattedWhole;
    if (fractionStr != null) {
      formatted = '$formatted.$fractionStr';
    } else if (cleanText.endsWith('.')) {
      formatted = '$formatted.';
    }

    // Calculate cursor position: count non-comma characters before cursor in newValue
    int nonCommasBeforeCursor = 0;
    for (int i = 0;
        i < newValue.selection.end && i < newValue.text.length;
        i++) {
      if (newValue.text[i] != ',') {
        nonCommasBeforeCursor++;
      }
    }

    // Find equivalent cursor position in formatted text
    int newCursorOffset = 0;
    int countedNonCommas = 0;
    while (newCursorOffset < formatted.length &&
        countedNonCommas < nonCommasBeforeCursor) {
      if (formatted[newCursorOffset] != ',') {
        countedNonCommas++;
      }
      newCursorOffset++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: newCursorOffset.clamp(0, formatted.length),
      ),
    );
  }
}

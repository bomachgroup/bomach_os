import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../src/services/finance/expense_service.dart';
import '../../../src/services/finance/budget_service.dart';
import '../../../src/services/finance/service_invoice_service.dart';

/// Compact naira amount formatter (audit B3 fix). Tiers:
///   >= 1,000,000 → M with one decimal   (was missing: ₦2.5M showed as
///                                        "2500K")
///   >= 100,000   → K with zero decimals
///   otherwise    → plain integer
String formatCompactAmount(double amount) {
  if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
  if (amount >= 100000) return '${(amount / 1000).toStringAsFixed(0)}K';
  // Truncate (not round): ₦99,999.99 must not display as ₦100000.
  return amount.truncate().toString();
}

class FinanceDashboardController extends GetxController {
  final ExpenseService _expenseService = ExpenseService();
  final BudgetService _budgetService = BudgetService();
  final ServiceInvoiceService _invoiceService = ServiceInvoiceService();
  final _storage = const FlutterSecureStorage();

  var totalExpenses = '0'.obs;
  var totalExpensesAmount = '₦0'.obs;
  var outstandingInvoices = '0'.obs;
  var totalBudgetAmount = '₦0'.obs;
  var isLoading = false.obs;

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith('Bearer ')) token = token.replaceFirst('Bearer ', '');
    return token.replaceAll('"', '').trim();
  }

  Future<void> fetchStats() async {
    try {
      isLoading.value = true;
      final token = await _getToken();
      if (token == null) return;

      final expenseResult = await _expenseService.getExpenses(token, limit: 1000);
      totalExpenses.value = expenseResult.total.toString();

      double total = 0;
      for (final e in expenseResult.items) {
        total += double.tryParse(e.amount.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
      }
      totalExpensesAmount.value = '₦${formatCompactAmount(total)}';

      final budgetResult = await _budgetService.getBudgets(token, limit: 1000);
      double budgetTotal = 0;
      for (final b in budgetResult.items) {
        budgetTotal += double.tryParse(b.amount.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
      }
      totalBudgetAmount.value = '₦${formatCompactAmount(budgetTotal)}';

      // Audit B1 fix: wire the Outstanding Invoices card to real unpaid
      // invoices instead of a permanently-zero dead observable.
      try {
        final invoiceResult =
            await _invoiceService.getInvoices(token, status: 'unpaid');
        outstandingInvoices.value = invoiceResult.total.toString();
      } catch (_) {
        // Keep previous value — showing stale beats faking zero.
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }
}

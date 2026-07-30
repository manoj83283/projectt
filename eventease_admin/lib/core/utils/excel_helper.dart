import 'dart:io';

import 'package:excel/excel.dart';

class ExcelHelper {
  ExcelHelper._();

  // =====================================================
  // CREATE EXCEL
  // =====================================================

  static Excel createWorkbook() {
    return Excel.createExcel();
  }

  // =====================================================
  // CREATE SHEET
  // =====================================================

  static Sheet createSheet({
    required Excel excel,
    required String sheetName,
  }) {
    return excel[sheetName];
  }

  // =====================================================
  // ADD HEADERS
  // =====================================================

  static void addHeaders({
    required Sheet sheet,
    required List<String> headers,
  }) {
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: i,
          rowIndex: 0,
        ),
      );

      cell.value = TextCellValue(
        headers[i],
      );

      cell.cellStyle = CellStyle(
        bold: true,
      );
    }
  }

  // =====================================================
  // ADD ROW
  // =====================================================

  static void addRow({
    required Sheet sheet,
    required int rowIndex,
    required List<dynamic> values,
  }) {
    for (int i = 0; i < values.length; i++) {
      sheet
          .cell(
            CellIndex.indexByColumnRow(
              columnIndex: i,
              rowIndex: rowIndex,
            ),
          )
          .value = TextCellValue(
        values[i]?.toString() ?? '',
      );
    }
  }

  // =====================================================
  // ADD MULTIPLE ROWS
  // =====================================================

  static void addRows({
    required Sheet sheet,
    required List<List<dynamic>> rows,
    int startRow = 1,
  }) {
    for (int i = 0; i < rows.length; i++) {
      addRow(
        sheet: sheet,
        rowIndex: startRow + i,
        values: rows[i],
      );
    }
  }

  // =====================================================
  // EXPORT CUSTOMERS
  // =====================================================

  static Future<File> exportCustomers({
    required String filePath,
    required List<Map<String, dynamic>>
        customers,
  }) async {
    final excel = createWorkbook();

    final sheet = createSheet(
      excel: excel,
      sheetName: 'Customers',
    );

    addHeaders(
      sheet: sheet,
      headers: [
        'ID',
        'Name',
        'Email',
        'Phone',
        'Status',
      ],
    );

    for (int i = 0;
        i < customers.length;
        i++) {
      addRow(
        sheet: sheet,
        rowIndex: i + 1,
        values: [
          customers[i]['id'],
          customers[i]['name'],
          customers[i]['email'],
          customers[i]['phone'],
          customers[i]['status'],
        ],
      );
    }

    return await saveExcel(
      excel: excel,
      filePath: filePath,
    );
  }

  // =====================================================
  // EXPORT PROVIDERS
  // =====================================================

  static Future<File> exportProviders({
    required String filePath,
    required List<Map<String, dynamic>>
        providers,
  }) async {
    final excel = createWorkbook();

    final sheet = createSheet(
      excel: excel,
      sheetName: 'Providers',
    );

    addHeaders(
      sheet: sheet,
      headers: [
        'ID',
        'Provider',
        'Category',
        'Rating',
        'Status',
      ],
    );

    for (int i = 0;
        i < providers.length;
        i++) {
      addRow(
        sheet: sheet,
        rowIndex: i + 1,
        values: [
          providers[i]['id'],
          providers[i]['name'],
          providers[i]['category'],
          providers[i]['rating'],
          providers[i]['status'],
        ],
      );
    }

    return await saveExcel(
      excel: excel,
      filePath: filePath,
    );
  }

  // =====================================================
  // EXPORT BOOKINGS
  // =====================================================

  static Future<File> exportBookings({
    required String filePath,
    required List<Map<String, dynamic>>
        bookings,
  }) async {
    final excel = createWorkbook();

    final sheet = createSheet(
      excel: excel,
      sheetName: 'Bookings',
    );

    addHeaders(
      sheet: sheet,
      headers: [
        'Booking ID',
        'Customer',
        'Provider',
        'Amount',
        'Status',
      ],
    );

    for (int i = 0;
        i < bookings.length;
        i++) {
      addRow(
        sheet: sheet,
        rowIndex: i + 1,
        values: [
          bookings[i]['bookingId'],
          bookings[i]['customer'],
          bookings[i]['provider'],
          bookings[i]['amount'],
          bookings[i]['status'],
        ],
      );
    }

    return await saveExcel(
      excel: excel,
      filePath: filePath,
    );
  }

  // =====================================================
  // EXPORT ORDERS
  // =====================================================

  static Future<File> exportOrders({
    required String filePath,
    required List<Map<String, dynamic>>
        orders,
  }) async {
    final excel = createWorkbook();

    final sheet = createSheet(
      excel: excel,
      sheetName: 'Orders',
    );

    addHeaders(
      sheet: sheet,
      headers: [
        'Order ID',
        'Customer',
        'Amount',
        'Payment',
        'Status',
      ],
    );

    for (int i = 0;
        i < orders.length;
        i++) {
      addRow(
        sheet: sheet,
        rowIndex: i + 1,
        values: [
          orders[i]['orderId'],
          orders[i]['customer'],
          orders[i]['amount'],
          orders[i]['paymentStatus'],
          orders[i]['status'],
        ],
      );
    }

    return await saveExcel(
      excel: excel,
      filePath: filePath,
    );
  }

  // =====================================================
  // EXPORT PAYMENTS
  // =====================================================

  static Future<File> exportPayments({
    required String filePath,
    required List<Map<String, dynamic>>
        payments,
  }) async {
    final excel = createWorkbook();

    final sheet = createSheet(
      excel: excel,
      sheetName: 'Payments',
    );

    addHeaders(
      sheet: sheet,
      headers: [
        'Payment ID',
        'Customer',
        'Amount',
        'Method',
        'Status',
      ],
    );

    for (int i = 0;
        i < payments.length;
        i++) {
      addRow(
        sheet: sheet,
        rowIndex: i + 1,
        values: [
          payments[i]['paymentId'],
          payments[i]['customer'],
          payments[i]['amount'],
          payments[i]['method'],
          payments[i]['status'],
        ],
      );
    }

    return await saveExcel(
      excel: excel,
      filePath: filePath,
    );
  }

  // =====================================================
  // SAVE EXCEL
  // =====================================================

  static Future<File> saveExcel({
    required Excel excel,
    required String filePath,
  }) async {
    final bytes = excel.save();

    final file = File(filePath);

    await file.writeAsBytes(
      bytes!,
      flush: true,
    );

    return file;
  }

  // =====================================================
  // READ EXCEL
  // =====================================================

  static Future<Excel> readExcel(
    String filePath,
  ) async {
    final bytes =
        File(filePath).readAsBytesSync();

    return Excel.decodeBytes(bytes);
  }

  // =====================================================
  // SHEET NAMES
  // =====================================================

  static List<String> getSheetNames(
    Excel excel,
  ) {
    return excel.tables.keys.toList();
  }

  // =====================================================
  // GET SHEET
  // =====================================================

  static Sheet? getSheet(
    Excel excel,
    String sheetName,
  ) {
    return excel.tables[sheetName];
  }
}
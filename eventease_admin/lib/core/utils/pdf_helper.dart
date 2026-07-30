import 'dart:io';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfHelper {
  PdfHelper._();

  // =====================================================
  // CREATE DOCUMENT
  // =====================================================

  static pw.Document createDocument() {
    return pw.Document();
  }

  // =====================================================
  // GENERIC REPORT
  // =====================================================

  static Future<File> generateReport({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> rows,
    required String filePath,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader(title),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: rows,
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
            headerDecoration:
                const pw.BoxDecoration(
              color: PdfColors.grey300,
            ),
          ),
        ],
      ),
    );

    return await savePdf(
      pdf: pdf,
      filePath: filePath,
    );
  }

  // =====================================================
  // CUSTOMER REPORT
  // =====================================================

  static Future<File> exportCustomers({
    required String filePath,
    required List<Map<String, dynamic>>
        customers,
  }) async {
    return generateReport(
      title: 'Customers Report',
      headers: const [
        'ID',
        'Name',
        'Email',
        'Phone',
        'Status',
      ],
      rows: customers
          .map(
            (item) => [
              item['id'],
              item['name'],
              item['email'],
              item['phone'],
              item['status'],
            ],
          )
          .toList(),
      filePath: filePath,
    );
  }

  // =====================================================
  // PROVIDER REPORT
  // =====================================================

  static Future<File> exportProviders({
    required String filePath,
    required List<Map<String, dynamic>>
        providers,
  }) async {
    return generateReport(
      title: 'Providers Report',
      headers: const [
        'ID',
        'Provider',
        'Category',
        'Rating',
        'Status',
      ],
      rows: providers
          .map(
            (item) => [
              item['id'],
              item['name'],
              item['category'],
              item['rating'],
              item['status'],
            ],
          )
          .toList(),
      filePath: filePath,
    );
  }

  // =====================================================
  // BOOKING REPORT
  // =====================================================

  static Future<File> exportBookings({
    required String filePath,
    required List<Map<String, dynamic>>
        bookings,
  }) async {
    return generateReport(
      title: 'Bookings Report',
      headers: const [
        'Booking ID',
        'Customer',
        'Provider',
        'Amount',
        'Status',
      ],
      rows: bookings
          .map(
            (item) => [
              item['bookingId'],
              item['customer'],
              item['provider'],
              item['amount'],
              item['status'],
            ],
          )
          .toList(),
      filePath: filePath,
    );
  }

  // =====================================================
  // ORDER REPORT
  // =====================================================

  static Future<File> exportOrders({
    required String filePath,
    required List<Map<String, dynamic>>
        orders,
  }) async {
    return generateReport(
      title: 'Orders Report',
      headers: const [
        'Order ID',
        'Customer',
        'Amount',
        'Payment',
        'Status',
      ],
      rows: orders
          .map(
            (item) => [
              item['orderId'],
              item['customer'],
              item['amount'],
              item['paymentStatus'],
              item['status'],
            ],
          )
          .toList(),
      filePath: filePath,
    );
  }

  // =====================================================
  // PAYMENT REPORT
  // =====================================================

  static Future<File> exportPayments({
    required String filePath,
    required List<Map<String, dynamic>>
        payments,
  }) async {
    return generateReport(
      title: 'Payments Report',
      headers: const [
        'Payment ID',
        'Customer',
        'Amount',
        'Method',
        'Status',
      ],
      rows: payments
          .map(
            (item) => [
              item['paymentId'],
              item['customer'],
              item['amount'],
              item['method'],
              item['status'],
            ],
          )
          .toList(),
      filePath: filePath,
    );
  }

  // =====================================================
  // ANALYTICS SUMMARY REPORT
  // =====================================================

  static Future<File> exportAnalytics({
    required String filePath,
    required Map<String, dynamic>
        analytics,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          _buildHeader(
            'Analytics Report',
          ),

          pw.SizedBox(height: 20),

          ...analytics.entries.map(
            (entry) => pw.Container(
              margin:
                  const pw.EdgeInsets.only(
                bottom: 10,
              ),
              padding:
                  const pw.EdgeInsets.all(10),
              decoration:
                  pw.BoxDecoration(
                border: pw.Border.all(),
              ),
              child: pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment
                        .spaceBetween,
                children: [
                  pw.Text(entry.key),
                  pw.Text(
                    entry.value.toString(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return savePdf(
      pdf: pdf,
      filePath: filePath,
    );
  }

  // =====================================================
  // HEADER
  // =====================================================

  static pw.Widget _buildHeader(
    String title,
  ) {
    return pw.Column(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'EventEase Admin',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight:
                pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(title),
        pw.SizedBox(height: 5),
        pw.Text(
          'Generated: ${DateFormat('dd MMM yyyy hh:mm a').format(DateTime.now())}',
          style: const pw.TextStyle(
            fontSize: 10,
          ),
        ),
        pw.Divider(),
      ],
    );
  }

  // =====================================================
  // SAVE PDF
  // =====================================================

  static Future<File> savePdf({
    required pw.Document pdf,
    required String filePath,
  }) async {
    final file = File(filePath);

    await file.writeAsBytes(
      await pdf.save(),
      flush: true,
    );

    return file;
  }
}
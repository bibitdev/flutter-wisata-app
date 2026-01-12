import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PrintHelper {
  static const platform = MethodChannel('com.wisata.app/print');

  /// Print receipt menggunakan Thermer Intent
  /// Format struk thermal dengan lebar 32 karakter
  static Future<bool> printReceipt({
    required String cashierName,
    required String transactionTime,
    required List<Map<String, dynamic>> items,
    required int totalPrice,
    required String paymentMethod,
    required int nominalPayment,
    int? transactionId,
    String? ticketId,
    int? cashierId,
  }) async {
    try {
      // Debug: Print ticket ID
      print('=== PRINT DEBUG ===');
      print('Ticket ID: $ticketId');
      print('Cashier ID: $cashierId');
      print('Transaction Time: $transactionTime');
      
      // Generate struk text
      final receiptText = _generateReceiptText(
        cashierName: cashierName,
        transactionTime: transactionTime,
        items: items,
        totalPrice: totalPrice,
        paymentMethod: paymentMethod,
        nominalPayment: nominalPayment,
        transactionId: transactionId,
        ticketId: ticketId,
        cashierId: cashierId,
      );
      
      print('Receipt Text:');
      print(receiptText);
      print('===================');

      // Kirim ke Thermer via Intent
      final bool result = await platform.invokeMethod('printThermal', {
        'text': receiptText,
      });

      return result;
    } on PlatformException catch (e) {
      print("Failed to print: '${e.message}'.");
      return false;
    }
  }

  /// Generate text untuk struk thermal
  static String _generateReceiptText({
    required String cashierName,
    required String transactionTime,
    required List<Map<String, dynamic>> items,
    required int totalPrice,
    required String paymentMethod,
    required int nominalPayment,
    int? transactionId,
    String? ticketId,
    int? cashierId,
  }) {
    final buffer = StringBuffer();
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    // Format waktu jadi readable
    String formattedTime = transactionTime;
    try {
      final dateTime = DateTime.parse(transactionTime);
      final dateFormat = DateFormat('dd MMM yyyy HH:mm', 'id_ID');
      formattedTime = dateFormat.format(dateTime);
    } catch (e) {
      // Jika gagal parse, gunakan string asli
      formattedTime = transactionTime;
    }

    // Header
    buffer.writeln(_center('WISATA POS'));
    buffer.writeln(_center('Aplikasi Kasir'));
    buffer.writeln(_line());
    
    // Kasir
    buffer.writeln(_leftRight('Kasir:', cashierName));
    
    // Waktu dengan format readable
    buffer.writeln(_leftRight('Waktu:', formattedTime));
    
    buffer.writeln(_line());
    
    // ID Tiket - Tampilkan di tengah dengan format besar
    if (ticketId != null && ticketId.isNotEmpty) {
      buffer.writeln(_center('ID TIKET'));
      buffer.writeln(_center(ticketId));
      buffer.writeln(_line());
    }
    
    // Items
    for (var item in items) {
      final name = item['name'] as String;
      final qty = item['quantity'] as int;
      final price = item['price'] as int;
      final subtotal = qty * price;

      buffer.writeln(name);
      buffer.writeln(
        _leftRight(
          '$qty x ${currencyFormat.format(price)}',
          currencyFormat.format(subtotal),
        ),
      );
    }
    
    buffer.writeln(_line());
    
    // Total
    buffer.writeln(_leftRight('TOTAL:', currencyFormat.format(totalPrice)));
    
    // Bayar
    buffer.writeln(_leftRight('Bayar:', currencyFormat.format(nominalPayment)));
    
    // Kembali
    final change = nominalPayment - totalPrice;
    buffer.writeln(_leftRight('Kembali:', currencyFormat.format(change)));
    
    // Metode bayar
    buffer.writeln(_leftRight('Metode:', paymentMethod));

    // Footer
    buffer.writeln(_line());
    buffer.writeln(_center('Terima Kasih'));
    buffer.writeln(_center('Atas Kunjungan Anda'));
    buffer.writeln(_center('Atas Kunjungan Anda'));
    buffer.writeln('\n\n\n');

    return buffer.toString();
  }

  /// Center text (lebar 32 karakter)
  static String _center(String text) {
    const width = 32;
    if (text.length >= width) return text;
    final padding = (width - text.length) ~/ 2;
    return '${' ' * padding}$text';
  }

  /// Left-right alignment (lebar 32 karakter)
  static String _leftRight(String left, String right) {
    const width = 32;
    final spaces = width - left.length - right.length;
    if (spaces <= 0) return '$left$right';
    return '$left${' ' * spaces}$right';
  }

  /// Garis pemisah
  static String _line() {
    return '--------------------------------';
  }

  /// Test print - untuk testing koneksi dengan Thermer
  static Future<bool> testPrint() async {
    try {
      final now = DateTime.now();
      final testTicketId = 'TIK${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}DEMO';
      
      final testText = '''
${_center('TEST PRINT')}
${_line()}
${_center('WISATA POS')}
${_center('Aplikasi Kasir')}
${_line()}
${_center('TIKET')}
${_center(testTicketId)}
${_line()}
${_center('Thermer Connected')}
${_center('Printer Ready')}
${_line()}
${_center('VALIDASI TIKET')}
${_center('Kode: 123#${now.toIso8601String()}')}
${_center('Scan QR di aplikasi')}
${_center('untuk verifikasi')}
${_line()}


''';

      final bool result = await platform.invokeMethod('printThermal', {
        'text': testText,
      });

      return result;
    } on PlatformException catch (e) {
      print("Failed to print test: '${e.message}'.");
      return false;
    }
  }
}

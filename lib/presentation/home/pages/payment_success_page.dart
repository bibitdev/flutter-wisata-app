import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_wisata_app/presentation/home/bloc/checkout/checkout_bloc.dart';
import 'package:flutter_wisata_app/presentation/home/main_page.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_wisata_app/presentation/home/bloc/checkout/models/order_model.dart';
import 'package:flutter_wisata_app/core/constants/variables.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_wisata_app/core/core.dart';
import 'package:open_filex/open_filex.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> setupNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (details) async {
      final String? filePath = details.payload;
      if (filePath != null && filePath.isNotEmpty) {
        await OpenFilex.open(filePath);
      }
    },
  );
}

Future<void> showNotification(String filePath) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'download_channel',
    'Download Notifications',
    channelDescription: 'Notifikasi saat file berhasil diunduh',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
  );
  const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    'Download selesai',
    'Struk transaksi berhasil disimpan. Klik untuk membuka.',
    platformChannelSpecifics,
    payload: filePath,
  );
}

class PaymentSuccessPage extends StatefulWidget {
  final OrderModel order;
  const PaymentSuccessPage({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  String? ticketId; // Variable untuk menyimpan ticket ID

  @override
  void initState() {
    super.initState();
    _generateTicketId();
  }

  void _generateTicketId() {
    // Generate ticket ID berdasarkan format: TIK + tanggal + urutan
    final now = DateTime.now();
    final dateFormat = now.toIso8601String().substring(0, 10).replaceAll('-', '');
    final randomNumber = (widget.order.id ?? 0).toString().padLeft(4, '0');
    ticketId = 'TIK$dateFormat$randomNumber';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Payment Reciept',
          style: TextStyle(color: AppColors.white),
        ),
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Assets.images.back.image(color: AppColors.white),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: context.deviceHeight / 2,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(12.0),
              ),
              color: AppColors.primary,
            ),
          ),
          SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Assets.images.receiptCard.provider(),
                  alignment: Alignment.topCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(60.0),
                child: Column(
                  children: [
                    const Text(
                      'PAYMENT RECIEPT',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SpaceHeight(16.0),
                    QrImageView(
                      data: widget.order.cashierId.toString() + '#' + widget.order.transactionTime,
                      version: QrVersions.auto,
                      size: 180.0,
                    ),
                    const SpaceHeight(8.0),
                    // Menambahkan Ticket ID di bawah QR Code
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Text(
                        'ID Tiket: ${ticketId ?? 'Loading...'}',
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SpaceHeight(12.0),
                    const Text('Scan this QR code to verify tickets'),
                    const SpaceHeight(16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tagihan'),
                        Text(widget.order.totalPrice.currencyFormatRp),
                      ],
                    ),
                    const SpaceHeight(16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Metode Bayar'),
                        Text(widget.order.paymentMethod),
                      ],
                    ),
                    const SpaceHeight(8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Waktu'),
                        Text(DateTime.now().toFormattedDate()),
                      ],
                    ),
                    const SpaceHeight(8.0),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status'),
                        Text('Lunas'),
                      ],
                    ),
                    const SpaceHeight(80.0), // Extra space for the floating action button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(36, 0, 36, 20),
        child: Button.filled(
          onPressed: () async {
            try {
              await setupNotifications();

              if (Platform.isAndroid) {
                final storage = await Permission.manageExternalStorage.request();
                final notif = await Permission.notification.request();

                if (!storage.isGranted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Izin penyimpanan dibutuhkan')),
                  );
                  return;
                }

                if (!notif.isGranted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Izin notifikasi dibutuhkan')),
                  );
                  return;
                }
              }

              print('=== DEBUG: Memulai proses cetak PDF ===');
              print('Base URL: ${Variables.baseUrl}');
              print('Ticket ID: $ticketId');
              
              final response = await http.post(
                Uri.parse('${Variables.baseUrl}/api/transactions/print'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'amount': widget.order.totalPrice,
                  'payment_method': widget.order.paymentMethod,
                  'transaction_time': DateTime.now().toIso8601String(),
                  'email': 'bibitraikhanazzaki@gmail.com',
                  'cashier_id': widget.order.cashierId,
                  'ticket_number': ticketId, // Diganti dari ticket_id menjadi ticket_number
                }),
              );

              print('Response Status Code: ${response.statusCode}');
              print('Response Body: ${response.body}');

              if (response.statusCode == 200) {
                final data = jsonDecode(response.body);
                print('Data parsed: $data');
                
                if (data['pdf_url'] == null) {
                  throw Exception('Server tidak mengembalikan URL PDF');
                }
                
                final pdfUrl = data['pdf_url'];
                print('PDF URL: $pdfUrl');

                Directory? downloadDir;
                if (Platform.isAndroid) {
                  downloadDir = Directory('/storage/emulated/0/Download');
                  if (!await downloadDir.exists()) {
                    await downloadDir.create(recursive: true);
                  }
                } else {
                  downloadDir = await getApplicationDocumentsDirectory();
                }

                final savePath = '${downloadDir.path}/Struk_Wisata_Baturaden.pdf';
                print('Save Path: $savePath');
                
                await Dio().download(pdfUrl, savePath);
                print('PDF berhasil diunduh');

                await showNotification(savePath);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ PDF berhasil disimpan di folder Download'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  context.read<CheckoutBloc>().add(const CheckoutEvent.started());
                  context.pushReplacement(const MainPage());
                }
              } else {
                // Parse error message dari server
                String errorMessage = 'Gagal membuat PDF';
                try {
                  final errorData = jsonDecode(response.body);
                  errorMessage = errorData['message'] ?? errorMessage;
                } catch (e) {
                  errorMessage = 'Server error: ${response.statusCode}';
                }
                
                print('ERROR: $errorMessage');
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✗ $errorMessage\nKode: ${response.statusCode}'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              }
            } catch (e, stackTrace) {
              print('=== ERROR DETAIL ===');
              print('Error: $e');
              print('Stack Trace: $stackTrace');
              
              String userFriendlyMessage = 'Terjadi kesalahan: ';
              
              if (e.toString().contains('SocketException')) {
                userFriendlyMessage += 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
              } else if (e.toString().contains('TimeoutException')) {
                userFriendlyMessage += 'Koneksi timeout. Server tidak merespons.';
              } else if (e.toString().contains('FormatException')) {
                userFriendlyMessage += 'Format data tidak valid dari server.';
              } else {
                userFriendlyMessage += e.toString();
              }
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(userFriendlyMessage),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            }
          },
          label: 'Cetak Transaksi',
          borderRadius: 10.0,
        ),
      ),
    );
  }
}
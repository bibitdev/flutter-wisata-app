import 'package:flutter/material.dart';
import 'package:flutter_wisata_app/core/core.dart';
import 'package:flutter_wisata_app/core/utils/print_helper.dart';

class PrinterSettingPage extends StatefulWidget {
  const PrinterSettingPage({super.key});

  @override
  State<PrinterSettingPage> createState() => _PrinterSettingPageState();
}

class _PrinterSettingPageState extends State<PrinterSettingPage> {
  bool _isPrinting = false;

  Future<void> _testPrint() async {
    setState(() {
      _isPrinting = true;
    });

    try {
      final result = await PrintHelper.testPrint();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result 
                ? 'Print test berhasil dikirim ke Thermer!' 
                : 'Gagal mengirim print. Pastikan Thermer terinstall.'
            ),
            backgroundColor: result ? AppColors.primary : AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPrinting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Printer'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Tentang Thermer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Aplikasi ini menggunakan Thermer untuk mencetak struk. '
                    'Thermer adalah aplikasi yang memungkinkan pencetakan '
                    'ke printer thermal via Bluetooth.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pastikan Thermer sudah terinstall dan printer '
                    'Bluetooth sudah terhubung.',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Test Print Button
          Card(
            child: ListTile(
              leading: Icon(
                Icons.print,
                color: AppColors.primary,
              ),
              title: const Text('Test Print'),
              subtitle: const Text('Coba cetak struk percobaan'),
              trailing: _isPrinting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _isPrinting ? null : _testPrint,
            ),
          ),
          const SizedBox(height: 8),

          // Instructions Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cara Menggunakan:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStep('1', 'Install aplikasi Thermer dari Play Store'),
                  _buildStep('2', 'Hubungkan printer Bluetooth di Thermer'),
                  _buildStep('3', 'Tekan "Test Print" untuk mencoba'),
                  _buildStep('4', 'Jika berhasil, print otomatis dari transaksi'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Download Thermer Button
          Card(
            color: AppColors.primary.withOpacity(0.1),
            child: ListTile(
              leading: Icon(
                Icons.download,
                color: AppColors.primary,
              ),
              title: const Text('Download Thermer'),
              subtitle: const Text('Belum punya Thermer? Download di sini'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () async {
                // Open Play Store - Thermer app
                // Package: ru.a402d.rawbtprinter
                // TODO: Uncomment when url_launcher is needed
                // final url = Uri.parse(
                //   'https://play.google.com/store/apps/details?id=ru.a402d.rawbtprinter'
                // );
                // await launchUrl(url);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Buka Play Store untuk download Thermer'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(text),
            ),
          ),
        ],
      ),
    );
  }
}

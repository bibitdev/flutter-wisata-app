import 'package:flutter/material.dart';
import 'package:flutter_wisata_app/core/assets/assets.dart';
import 'package:flutter_wisata_app/presentation/settings/widgets/setting_button.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(24),
        mainAxisSpacing: 24.0,
        crossAxisSpacing: 15.0,
        children: [
          SettingButton(
            iconPath: Assets.icons.settings.printer.path,
            title: 'Printer',
            subtitle: 'kelola printer',
            onPressed: () {},
          ),
          SettingButton(
            iconPath: Assets.icons.settings.logout.path,
            title: 'Logout',
            subtitle: 'Keluar dari aplikasi',
            onPressed: () {},
          ),
          SettingButton(
            iconPath: Assets.icons.settings.syncData.path,
            title: 'Sync Categories',
            subtitle: 'Sinkronasi Online',
            onPressed: () {},
          ),
          SettingButton(
            iconPath: Assets.icons.settings.syncData.path,
            title: 'Server Key',
            subtitle: 'Input server key',
            onPressed: () {},
          )
        ],
      ),
    );
  }
}

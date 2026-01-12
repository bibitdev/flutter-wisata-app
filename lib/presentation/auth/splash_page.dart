import 'package:flutter/material.dart';
import 'package:flutter_wisata_app/core/core.dart';
import 'package:flutter_wisata_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_wisata_app/data/datasources/auth_helper.dart';
import 'package:flutter_wisata_app/presentation/home/main_page.dart';
import 'package:google_fonts/google_fonts.dart';

// import '../../core/assets/assets.gen.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Future<Widget> _checkAuthAndRole() async {
    // Wait 2 seconds for splash screen
    await Future.delayed(const Duration(seconds: 2));

    // Check if logged in
    final isLoggedIn = await AuthLocalDatasource().isLogin();

    if (!isLoggedIn) {
      return const LoginPage();
    }

    // 🔒 Check user role
    final userRole = await AuthHelper.getUserRole();
    print('=== SPLASH CHECK ===');
    print('User logged in: $isLoggedIn');
    print('User role: $userRole');

    // 🚫 Block admin from accessing app
    if (userRole == 'admin') {
      await AuthHelper.forceLogout();
      return const LoginPage();
    }

    // ✅ Allow staff to access
    if (userRole == 'staff') {
      return const MainPage();
    }

    // Unknown role - force logout
    await AuthHelper.forceLogout();
    return const LoginPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Widget>(
          future: _checkAuthAndRole(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return snapshot.data ?? const LoginPage();
            }
            return Stack(
              children: [
                Column(
                  children: [
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(96.0),
                      child: Center(
                        child: Assets.images.logoBlue.image(),
                      ),
                    ),
                    const Spacer(),
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                    const SpaceHeight(40),
                    SizedBox(
                      height: 100.0,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text('CURUG PINANG',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            )),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
    );
  }
}

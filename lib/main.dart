import 'package:flutter/material.dart';
import 'package:flutter_wisata_app/presentation/auth/splash_page.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        dialogTheme: const DialogTheme(elevation: 0),
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: AppBarTheme(
          color: AppColors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.outfit(
            color: AppColors.primary,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
          iconTheme: const IconThemeData(
            color: AppColors.black,
          ),
          centerTitle: true,
        ),
      ),
      home: const SplashPage(),
    );
  }
}


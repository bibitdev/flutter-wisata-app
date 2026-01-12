import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wisata_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_wisata_app/presentation/auth/bloc/login/login_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/core.dart';
import '../home/main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true; // untuk toggle show/hide password

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Login Gagal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('Tutup'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          SizedBox(
            height: 450.0,
            child: Center(
              child: Assets.images.logoWhite.image(height: 700.0),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20.0)),
                child: ColoredBox(
                  color: AppColors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28.0, vertical: 44.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            controller: emailController,
                            label: 'Email',
                            isOutlineBorder: false,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email tidak boleh kosong';
                              } else if (!value.contains('@')) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SpaceHeight(36.0),
                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password tidak boleh kosong';
                              } else if (value.length < 8) {
                                return 'Password minimal 8 karakter';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: const UnderlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SpaceHeight(86.0),
                          BlocListener<LoginBloc, LoginState>(
                            listener: (context, state) {
                              state.maybeWhen(
                                orElse: () {},
                                success: (data) async {
                                  // 🔒 STEP 1: Simpan auth data dulu
                                  await AuthLocalDatasource()
                                      .saveAuthData(data);

                                  // 🔒 STEP 2: CEK ROLE USER
                                  final userRole = data.user?.role ?? 'user';

                                  // 🚫 STEP 3: BLOKIR ADMIN
                                  if (userRole == 'admin') {
                                    // Clear auth data
                                    await AuthLocalDatasource()
                                        .removeAuthData();

                                    // Tampilkan dialog error
                                    if (context.mounted) {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          title: Row(
                                            children: [
                                              Icon(
                                                Icons.block,
                                                color: Colors.red[700],
                                                size: 28,
                                              ),
                                              const SizedBox(width: 12),
                                              const Text(
                                                'Akses Ditolak',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: const Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Akun Administrator tidak dapat mengakses aplikasi kasir mobile.',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  height: 1.5,
                                                ),
                                              ),
                                              SizedBox(height: 12),
                                              Text(
                                                'Silakan gunakan dashboard web untuk mengelola data dan sistem.',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              style: TextButton.styleFrom(
                                                foregroundColor:
                                                    AppColors.primary,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 24,
                                                  vertical: 12,
                                                ),
                                              ),
                                              child: const Text(
                                                'Mengerti',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return;
                                  }

                                  // ✅ STEP 4: IZINKAN STAFF
                                  if (userRole == 'staff') {
                                    if (context.mounted) {
                                      context.pushReplacement(const MainPage());
                                    }
                                  } else {
                                    // Role tidak dikenal
                                    await AuthLocalDatasource()
                                        .removeAuthData();
                                    if (context.mounted) {
                                      _showErrorDialog(
                                        'Role pengguna tidak valid. Hubungi administrator.',
                                      );
                                    }
                                  }
                                },
                                error: (_) {
                                  _showErrorDialog(
                                    'Email atau password yang Anda masukkan salah',
                                  );
                                },
                              );
                            },
                            child: BlocBuilder<LoginBloc, LoginState>(
                              builder: (context, state) {
                                return state.maybeWhen(
                                  orElse: () {
                                    return Button.filled(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          context.read<LoginBloc>().add(
                                                LoginEvent.login(
                                                  email: emailController.text,
                                                  password:
                                                      passwordController.text,
                                                ),
                                              );
                                        }
                                      },
                                      label: 'Login',
                                    );
                                  },
                                  loading: () {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SpaceHeight(128.0),
                          Center(
                            child: Text(
                              'CURUG PINANG',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

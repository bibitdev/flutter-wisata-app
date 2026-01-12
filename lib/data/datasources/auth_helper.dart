import 'package:flutter_wisata_app/data/datasources/auth_local_datasource.dart';

class AuthHelper {
  /// Cek apakah user adalah staff
  static Future<bool> isStaff() async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();
      return authData.user?.role == 'staff';
    } catch (e) {
      return false;
    }
  }

  /// Cek apakah user adalah admin
  static Future<bool> isAdmin() async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();
      return authData.user?.role == 'admin';
    } catch (e) {
      return false;
    }
  }

  /// Get current user role
  static Future<String?> getUserRole() async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();
      return authData.user?.role;
    } catch (e) {
      return null;
    }
  }

  /// Get current user name
  static Future<String?> getUserName() async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();
      return authData.user?.name;
    } catch (e) {
      return null;
    }
  }

  /// Get current user email
  static Future<String?> getUserEmail() async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();
      return authData.user?.email;
    } catch (e) {
      return null;
    }
  }

  /// Validate if user can access cashier features
  static Future<bool> canAccessCashier() async {
    final role = await getUserRole();
    return role == 'staff'; // Hanya staff yang bisa akses kasir
  }

  /// Force logout and clear all data
  static Future<void> forceLogout() async {
    try {
      await AuthLocalDatasource().removeAuthData();
    } catch (e) {
      // Error during logout, ignore
    }
  }
}

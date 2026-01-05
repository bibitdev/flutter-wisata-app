import 'package:flutter_wisata_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_wisata_app/data/models/response/auth_response_model.dart';

class AuthUtils {
  static Future<User?> getCurrentUser() async {
    try {
      final authData = await AuthLocalDatasource().getAuthData();
      return authData.user;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getCurrentUserRole() async {
    try {
      final user = await getCurrentUser();
      return user?.role;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> isAdmin() async {
    final role = await getCurrentUserRole();
    return role == 'admin';
  }

  static Future<bool> isStaff() async {
    final role = await getCurrentUserRole();
    return role == 'staff';
  }

  static Future<bool> canManageTickets() async {
    // Hanya admin yang bisa manage (CRUD) tickets
    return await isAdmin();
  }

  static Future<bool> canViewTickets() async {
    // Admin dan staff bisa view tickets
    final role = await getCurrentUserRole();
    return role == 'admin' || role == 'staff';
  }
}
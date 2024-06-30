import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wisata_app/core/core.dart';
import 'package:flutter_wisata_app/data/datasources/auth_local_datasource.dart';
import 'package:flutter_wisata_app/data/datasources/product_local_datasource.dart';
import 'package:flutter_wisata_app/presentation/auth/splash_page.dart';
import 'package:flutter_wisata_app/presentation/home/bloc/category/category_bloc.dart';
import 'package:flutter_wisata_app/presentation/home/bloc/product/product_bloc.dart';
import 'package:flutter_wisata_app/presentation/home/bloc/sync_order/sync_order_bloc.dart';
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
            onPressed: () async {
            await AuthLocalDatasource().removeAuthData();
            context.pushReplacement(
              const SplashPage(),
            );
          },
          ),
          BlocConsumer<CategoryBloc, CategoryState>(
            listener: (context, state) {
              state.maybeWhen(
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                },
                success: (categories) {
                  ProductLocalDatasource.instance.removeAllCategory();
                  ProductLocalDatasource.instance.insertAllCategory(categories);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Sync Category Success'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                orElse: () {},
              );
            },
            builder: (context, state) {
              return SettingButton(
                iconPath: Assets.icons.settings.syncData.path,
                title: 'Sync Categories',
                subtitle: 'Sinkronasi Online',
                onPressed: () {
                  context.read<CategoryBloc>().add(
                        const CategoryEvent.fetch(),
                      );
                },
              );
            },
          ),
          BlocConsumer<ProductBloc, ProductState>(
            listener: (context, state) {
              state.maybeWhen(
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                },
                success: (products) {
                  ProductLocalDatasource.instance.removeAllProduct();
                  ProductLocalDatasource.instance.insertAllProduct(products);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Sync Product Success'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                orElse: () {},
              );
            },
            builder: (context, state) {
              return state.maybeWhen(
                loading: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                orElse: () {
                  return SettingButton(
                    iconPath: Assets.icons.settings.syncData.path,
                    title: 'Sync Product',
                    subtitle: 'sinkronasi online',
                    onPressed: () {
                      context
                          .read<ProductBloc>()
                          .add(const ProductEvent.getProducts());
                    },
                  );
                },
              );
            },
          ),
          
          // Sync Orders
          BlocConsumer<SyncOrderBloc, SyncOrderState>(
            listener: (context, state) {
              state.maybeWhen(
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                },
                success: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Sync Order Success'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                orElse: () {},
              );
            },
            builder: (context, state) {
              return state.maybeWhen(
                loading: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                orElse: () {
                  return SettingButton(
                    iconPath: Assets.icons.settings.syncData.path,
                    title: 'Sync Orders',
                    subtitle: 'sinkronasi online',
                    onPressed: () {
                      context
                          .read<SyncOrderBloc>()
                          .add(const SyncOrderEvent.syncOrder());
                    },
                  );
                },
              );
            },
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

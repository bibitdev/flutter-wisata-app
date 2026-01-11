import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wisata_app/core/utils/date_utils.dart';
import 'package:flutter_wisata_app/presentation/home/bloc/checkout/checkout_bloc.dart';
import 'package:flutter_wisata_app/presentation/home/bloc/product/product_bloc.dart';
import 'package:flutter_wisata_app/presentation/home/pages/order_detail_page.dart';
import 'package:flutter_wisata_app/presentation/home/widgets/order_card.dart';

import '../../../core/core.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  void initState() {
    context.read<ProductBloc>().add(ProductEvent.getLocalProducts());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Cek hari saat ini (weekend atau weekday)
    final isWeekend = AppDateUtils.isWeekend();
    final dayType = isWeekend ? 'Tiket Weekend' : 'Tiket Weekday';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Penjualan Tiket'),
            // Text(
            //   dayType,
            //   style: TextStyle(
            //     fontSize: 12.0,
            //     fontWeight: FontWeight.normal,
            //     color: AppColors.grey,
            //   ),
            // ),
          ],
        ),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          final allProducts = state.maybeWhen(
            success: (products) => products,
            orElse: () => [],
          );

          // Filter produk berdasarkan kategori weekend/weekday
          final products = allProducts.where((product) {
            final categoryName = product.category?.name?.toLowerCase() ?? '';

            if (isWeekend) {
              // Jika weekend, hanya tampilkan tiket weekend
              return categoryName.contains('weekend');
            } else {
              // Jika weekday, hanya tampilkan tiket weekday
              return categoryName.contains('weekday');
            }
          }).toList();

          if (products.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada tiket ${isWeekend ? 'weekend' : 'weekday'} tersedia',
                style: TextStyle(color: AppColors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            itemCount: products.length,
            separatorBuilder: (context, index) => const SpaceHeight(20.0),
            itemBuilder: (context, index) => OrderCard(
              item: products[index],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Ringkasan Pesanan'),
                  BlocBuilder<CheckoutBloc, CheckoutState>(
                    builder: (context, state) {
                      return state.maybeWhen(
                        success: (checkout) {
                          final total = checkout.fold<int>(
                            0,
                            (previousValue, element) =>
                                previousValue +
                                element.product.price! * element.quantity,
                          );
                          return Text(
                            total.currencyFormatRp,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          );
                        },
                        orElse: () => Text(
                          '0',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Button.filled(
                height: 48,
                width: 120,
                onPressed: () {
                  context.push(const OrderDetailPage());
                },
                label: 'Proses',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

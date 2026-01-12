import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wisata_app/data/datasources/product_local_datasource.dart';
import 'package:flutter_wisata_app/presentation/home/bloc/checkout/models/order_model.dart';
import 'package:flutter_wisata_app/presentation/home/bloc/order/order_bloc.dart';
import 'package:flutter_wisata_app/presentation/home/bloc/sync_order/sync_order_bloc.dart';
import 'package:flutter_wisata_app/presentation/home/pages/payment_success_page.dart';
import 'package:timer_count_down/timer_count_down.dart';

import '../../../core/core.dart';
import '../../../core/utils/date_utils.dart';


class PaymentQrisDialog extends StatelessWidget {
  final int totalPrice;

  const PaymentQrisDialog({super.key, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Tunjukkan QR Code ini kepada pelanggan'),
          const SpaceHeight(24.0),

          /// Qr & Simulasi klik
          BlocListener<OrderBloc, OrderState>(
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
                success: (orders, totalQuantity, totalPrice, paymentNominal,
                    paymentMethod, cashierId, cashierName) {
                  // ⏰ Gunakan waktu WIB agar konsisten dengan server Laravel
                  final orderModel = OrderModel(
                    paymentMethod: paymentMethod,
                    nominalPayment: paymentNominal,
                    orders: orders,
                    totalQuantity: totalQuantity,
                    totalPrice: totalPrice,
                    cashierId: cashierId,
                    cashierName: cashierName,
                    isSync: false,
                    transactionTime: AppDateUtils.transactionTimeNow(),
                  );
                  ProductLocalDatasource.instance.insertOrder(orderModel);
                  
                  // 🚀 Auto-sync transaksi ke server
                  context.read<SyncOrderBloc>().add(const SyncOrderEvent.syncOrder());
                  
                  context.pushReplacement(PaymentSuccessPage(order: orderModel));
                },
                orElse: () {},
              );
            },
            child: InkWell(
              onTap: () {
                // Simulasi: Pembayaran QR berhasil
                context
                    .read<OrderBloc>()
                    .add(OrderEvent.addNominalPayment(totalPrice));
              },
              child: SizedBox(
                height: 200.0,
                width: 200.0,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Image.asset(Assets.images.qrDana.path),
                ),
              ),
            ),
          ),

          const SpaceHeight(24.0),

          /// Countdown
          Countdown(
            seconds: 60,
            build: (context, time) => Text.rich(
              TextSpan(
                text: 'Update dalam ',
                children: [
                  TextSpan(
                    text: '${time.toInt()} detik',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            onFinished: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
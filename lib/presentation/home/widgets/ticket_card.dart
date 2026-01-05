import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wisata_app/data/models/response/product_response_model.dart';
import 'package:flutter_wisata_app/presentation/home/bloc/product/product_bloc.dart';
import 'package:flutter_wisata_app/presentation/home/dialogs/update_ticket_dialog.dart';

import '../../../core/core.dart';

class TicketCard extends StatelessWidget {
  final Product item;
  final bool canManage; // Parameter untuk menentukan apakah user bisa manage

  const TicketCard({
    super.key,
    required this.item,
    this.canManage = false, // Default false untuk keamanan
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name ?? '',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Hanya tampilkan action buttons jika user bisa manage
              if (canManage) ...[
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => UpdateTicketDialog(item: item),
                    );
                  },
                  child: Assets.icons.edit.svg(),
                ),
                const SpaceWidth(16.0),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Konfirmasi'),
                        content: const Text('Apakah Anda yakin ingin menghapus tiket ini?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<ProductBloc>().add(
                                ProductEvent.deleteTicket(item.id!),
                              );
                              Navigator.pop(context);
                            },
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Assets.icons.delete.svg(),
                ),
              ],
            ],
          ),
          const SpaceHeight(8.0),
          Text(
            item.description ?? '',
            style: const TextStyle(
              fontSize: 14.0,
              color: AppColors.grey,
            ),
          ),
          const SpaceHeight(8.0),
          Row(
            children: [
              Text(
                'Harga: ${item.price?.currencyFormatRp ?? ''}',
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Text(
                'Stok: ${item.stock ?? 0}',
                style: const TextStyle(
                  fontSize: 14.0,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
          const SpaceHeight(8.0),
          Row(
            children: [
              Text(
                'Kategori: ${item.category?.name ?? ''}',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: AppColors.grey,
                ),
              ),
              const Spacer(),
              Text(
                'Kriteria: ${item.criteria ?? ''}',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
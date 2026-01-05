import 'package:bloc/bloc.dart';
import 'package:flutter_wisata_app/data/models/response/product_response_model.dart';
import 'package:flutter_wisata_app/presentation/home/bloc/checkout/models/order_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkout_event.dart';
part 'checkout_state.dart';
part 'checkout_bloc.freezed.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc() : super(_Initial()) {
    on<_AddCheckout>((event, emit) {
      if (state is _Success) {
        final currentState = state as _Success;
        List<OrderItem> products = [...currentState.products];
        final index = products
            .indexWhere((element) => element.product.id == event.product.id);
        
        if (index >= 0) {
          // Cek stok sebelum menambah
          if (products[index].quantity < event.product.stock!) {
            products[index].quantity += 1;
          } else {
            // Tidak menambah jika stok tidak cukup, tapi tidak emit error
            // Bisa tambahkan notifikasi di UI
            return;
          }
        } else {
          // Cek stok untuk produk baru
          if (event.product.stock! > 0) {
            products.add(OrderItem(product: event.product, quantity: 1));
          } else {
            return; // Stok habis
          }
        }
        
        emit(const _Loading());
        emit(_Success(products));
      } else {
        // State awal, cek stok dulu
        if (event.product.stock! > 0) {
          emit(_Success([OrderItem(product: event.product, quantity: 1)]));
        }
      }
    });

    on<_RemoveCheckout>((event, emit) {
      if (state is _Success) {
        final currentState = state as _Success;
        List<OrderItem> products = [...currentState.products];
        final index = products
            .indexWhere((element) => element.product.id == event.product.id);
        if (index >= 0) {
          if (products[index].quantity > 1) {
            products[index].quantity -= 1;
          } else {
            products.removeAt(index);
          }
          emit(const _Loading());
          emit(_Success(products));
        }
      }
    });

    on<_Started>((event, emit) {
      emit(const _Loading());
      emit(const _Success([]));
    });
  }
}
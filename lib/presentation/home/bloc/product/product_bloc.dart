// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_wisata_app/data/models/request/create_ticket_request_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_wisata_app/data/datasources/product_local_datasource.dart';
import 'package:flutter_wisata_app/data/datasources/product_remote_datasource.dart';
import 'package:flutter_wisata_app/data/models/response/product_response_model.dart';

part 'product_bloc.freezed.dart';
part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRemoteDatasource productRemoteDatasource;
  final ProductLocalDatasource productLocalDatasource;
  ProductBloc(
    this.productRemoteDatasource,
    this.productLocalDatasource,
  ) : super(_Initial()) {
    List<Product> products = [];
    on<_GetProducts>((event, emit) async {
      emit(_Loading());
      final response = await productRemoteDatasource.getProducts();

      response.fold(
        (error) => emit(_Error(error)),
        (data) => emit(
          _Success(data.data ?? []),
        ),
      );
    });

    on<_SyncProduct>((event, emit) async {
      final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());
      if (connectivityResult.contains(ConnectivityResult.none)) {
        emit(_Error('No Internet Connection'));
      } else {
        emit(_Loading());
        final response = await productRemoteDatasource.getProducts();
        productLocalDatasource.removeAllProduct();
        productLocalDatasource.insertAllProduct(
            response.getOrElse(() => ProductResponseModel(data: [])).data ??
                []);
        products =
            response.getOrElse(() => ProductResponseModel(data: [])).data ?? [];
        emit(_Success(products));
      }
    });

    on<_GetLocalProducts>((event, emit) async {
      emit(_Loading());
      final localProducts = await productLocalDatasource.getProducts();
      products = localProducts;
      emit(_Success(products));
    });


    // Create Ticket
    on<_CreateTicket>((event, emit) async {
      emit(_Loading());

      final requestData = CreateTicketRequestModel(
        name: event.model.name,
        price: event.model.price,
        stock: event.model.stock,
        categoryId: event.model.categoryId,
        criteria: event.model.criteria,
      );

      final response = await productRemoteDatasource.createTicket(requestData);

      response.fold(
        (error) => emit(_Error(error)),
        (data) {
          products.add(data.data);
          emit(_Success(products));
        },
      );
    });

    // Update Ticket
    on<_UpdateTicket>((event, emit) async {
      emit(const _Loading());

      final requestData = CreateTicketRequestModel(
        name: event.model.name,
        price: event.model.price,
        stock: event.model.stock,
      );

      final response = await productRemoteDatasource.updateTicket(
          requestData, event.model.id!);

      response.fold(
        (l) => emit(_Error(l)),
        (r) {
          final updatedProducts = products.map((product) {
            if (product.id == event.model.id) {
              return r.data;
            }
            return product;
          }).toList();

          products = updatedProducts; // Perbarui daftar lokal

          emit(_Success(
              updatedProducts)); // Kirim status berhasil dengan daftar produk yang diperbarui
        },
      );
    });

    // Delete Ticket
    on<_DeleteTicket>((event, emit) async {
      emit(const _Loading());

      final response = await productRemoteDatasource.deleteTicket(event.id);

      response.fold(
        (l) => emit(_Error(l)),
        (r) {
          products.removeWhere((product) => product.id == event.id);
          emit(_Success(products));
        },
      );
    });
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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

    on<_GetLocalProducts>(((event, emit) async {
      emit(_Loading());
      final localProducts = await productLocalDatasource.getProducts();
      products = localProducts;
      emit(_Success(products));
    }));
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_wisata_app/data/datasources/product_remote_datasource.dart';
import 'package:flutter_wisata_app/data/models/response/product_response_model.dart';

part 'product_bloc.freezed.dart';
part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRemoteDatasource productRemoteDatasource;
  // final ProductLocalDatasource productLocalDatasource;

  ProductBloc(
    this.productRemoteDatasource,
  ) : super(_Initial()) {
    on<ProductEvent>((event, emit) async {
      emit(_Loading());
      final response = await productRemoteDatasource.getProducts();

      response.fold(
        (error) => emit(_Error(error)),
        (data) => emit(
          _Success(data.data ?? []),
        ),
      );
    });
  }
}

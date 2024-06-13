// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_wisata_app/data/datasources/auth_remote_datasource.dart';

part 'logout_bloc.freezed.dart';
part 'logout_event.dart';
part 'logout_state.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final AuthRemoteDatasource authRemoteDatasource;
  LogoutBloc(
    this.authRemoteDatasource,
  ) : super(_Initial()) {
    on<LogoutEvent>((event, emit) async {
      emit(_Loading());
      final response = await authRemoteDatasource.logout();

      response.fold(
        (error) => emit(_Error(error)),
        (data) => emit(_Success()),
      );
    });
  }
}

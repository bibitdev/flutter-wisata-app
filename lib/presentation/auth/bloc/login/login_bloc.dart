import 'package:bloc/bloc.dart';
import 'package:flutter_wisata_app/data/models/request/login_request_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_wisata_app/data/datasources/auth_remote_datasource.dart';
import '../../../../data/models/response/auth_response_model.dart';

part 'login_bloc.freezed.dart';
part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRemoteDatasource authRemoteDatasource;

  LoginBloc(this.authRemoteDatasource) : super(_Initial()) {
    on<_Login>((event, emit) async {
      emit(_Loading());
      final dataRequest = LoginRequestModel(
        email: event.email,
        password: event.password,
      );

      print('Login event received: ${event.email}, ${event.password}');

      final response = await authRemoteDatasource.login(dataRequest);

      response.fold(
        (error) {
          print('Login failed: $error');
          emit(_Error(error));
        },
        (data) {
          print('Login success: $data');
          emit(_Success(data));
        },
      );
    });
  }
}

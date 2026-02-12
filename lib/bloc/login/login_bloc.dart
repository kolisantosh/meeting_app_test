import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_event.dart';
import 'login_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        // Mocking API Call
        await Future.delayed(const Duration(seconds: 2));
        if (event.email == 'almighty@aether.co.in' &&
            event.password == '1234') {
          emit(Authenticated());
        } else {
          emit(AuthError("Invalid Credentials"));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}

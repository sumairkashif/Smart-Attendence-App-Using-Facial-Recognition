import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:facemark/pages/sign_up/notifier/register_state.dart';
part 'register_notifier.g.dart';

@riverpod
class RegisterNotifier extends _$RegisterNotifier{

  @override
  RegisterState build(){
    return RegisterState();
  }

  void onUserNameChange(String name){
    state = state.copyWith(userName: name);
  }

  void onUserEmailChange(String email){
    state = state.copyWith(email: email);
  }
  void onUserPasswordChange(String password){
    state = state.copyWith(password: password);
  }
  void onUserRePasswordChange(String password){
    state = state.copyWith(rePassword: password);
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:facemark/common/entities/entities.dart';
import 'package:facemark/common/global_loader/global_loader.dart';
import 'package:facemark/common/utils/constants.dart';
import 'package:facemark/common/widgets/popup_messages.dart';
import 'package:facemark/global.dart';
import 'package:facemark/pages/sign_in/notifier/sign_in_notifier.dart';

class SignInController{
  WidgetRef ref;
  SignInController(this.ref);

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> handleSignIn() async {
    var state = ref.read(SignInNotifierProvider);
    String email = state.email;
    String password = state.password;

    emailController.text = email;
    passwordController.text = password;

    if (state.email.isEmpty || email.isEmpty) {
      toastInfo("Your email is empty");
      print("Your email is empty");
      return;
    }
    if (state.password.isEmpty || password.isEmpty) {
      toastInfo("Your password is empty");
      print("Your password is empty");
      return;
    }

    ref.read(appLoaderProvider.notifier).setLoaderValue(true);
    try{
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if(credential.user==null){
        toastInfo("user not exists");
        print("user not exists");
      }
      if(!credential.user!.emailVerified){
        toastInfo("you must verify you email first!");
        print("you must verify you email first!");
      }
      var user = credential.user;
      if(user!=null){
        String? displayName = user.displayName;
        String? email = user.email;
        String? id = user.uid;
        String? photoUrl = user.photoURL;

        LoginRequestEntity loginRequestEntity = LoginRequestEntity();
        loginRequestEntity.avatar = photoUrl;
        loginRequestEntity.name = displayName;
        loginRequestEntity.email = email;
        loginRequestEntity.open_id = id;
        loginRequestEntity.type = 1;
        asyncPostAllData(loginRequestEntity);
        if (kDebugMode) {
          print("User logedIn!");
          toastInfo("user logged in");
        }
      }else{
        toastInfo("Login error");
        print("Login error");
      }
    }on FirebaseAuthException catch(e){
      if(e.code=='user-not-found'){
        print("***************************************");
        toastInfo("User not found");
      }else if(e.code=='wrong-password'){
        toastInfo("Your password is wrong");
      }
      print(e.code);
    }catch(e){
      if (kDebugMode) {
        print(e.toString());
      }
    }
    ref.read(appLoaderProvider.notifier).setLoaderValue(false);
  }

  void asyncPostAllData(LoginRequestEntity loginRequestEntity){
    var navigator = Navigator.of(ref.context);
    // navigator.push(
    //     MaterialPageRoute(
    //         builder: (BuildContext context)=>Scaffold(
    //           appBar: AppBar(
    //             title: Text("Sumair kashif"),
    //           ),
    //           body: Center(
    //             child: Container(
    //               child: Text("sumair"),
    //             ),
    //           ),
    //         )
    //     )
    // );
    navigator.pushNamedAndRemoveUntil("/application", (route) => false);
    // navigator.pushNamed("/application");

    try{

      Fluttertoast.showToast(msg: 'App is running');
      print("-------------------");
      Global.storageService.setString(AppConstants.STORAGE_USER_PROFILE_KEY, "123");
      Global.storageService.setString(AppConstants.STORAGE_USER_TOKEN_KEY, "123456");



    }catch(e){
      if (kDebugMode) {
        print(e.toString());
      }
    }

  }
}

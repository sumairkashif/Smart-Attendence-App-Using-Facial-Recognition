import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:facemark/common/global_loader/global_loader.dart';
import 'package:facemark/common/utils/app_colors.dart';
import 'package:facemark/common/widgets/button_widgets.dart';
import 'package:facemark/common/widgets/text_widgets.dart';
import 'package:facemark/pages/sign_in/notifier/sign_in_notifier.dart';
import 'package:facemark/pages/sign_in/widgets/sign_in_controller.dart';
import 'package:facemark/pages/sign_in/widgets/sign_in_widgets.dart';

import '../../common/widgets/app_bar.dart';
import '../../common/widgets/app_textfields.dart';

class SignIn extends ConsumerStatefulWidget {
  const SignIn({Key? key}) : super(key: key);
  @override
  ConsumerState<SignIn> createState() => _SignInState();
}

class _SignInState extends ConsumerState<SignIn>{
  late SignInController _controller;

  @override
  void initState() {
    // TODO: implement initState
    _controller = SignInController(ref);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final signinprovider = ref.watch(SignInNotifierProvider);
    final loader = ref.watch(appLoaderProvider);
    print(signinprovider.email);
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
            appBar: buildAppbar(title: "Login"),
            backgroundColor: Colors.white,
            body: loader==false?SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //top login buttons
                  thirdPartyLogin(),
                  //more login options message
                  Center(
                      child: text14Normal(
                          text: "Or use your email account to login")),
                  SizedBox(
                    height: 50.h,
                  ),
                  //email text box
                  appTextField(
                    text: "Email",
                    iconName: "assets/icons/user.png",
                    hintText: "Enter your email address",
                     func: (value)=>ref.read(SignInNotifierProvider.notifier).onUserEmailChange(value),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  //password text box
                  appTextField(
                    text: "Password",
                    iconName: "assets/icons/lock.png",
                    hintText: "Enter your password",
                    obscureText: true,
                     func: (value)=>ref.read(SignInNotifierProvider.notifier).onUserPasswordChange(value),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  //forgot text
                  Container(
                      margin: EdgeInsets.only(left: 25.w),
                      child: textUnderline(text: "Forgot password?")),
                  SizedBox(
                    height: 100.h,
                  ),
                  //app login button
                  Center(
                      child: appButton(
                        buttonName: "Login",
                        func: ()=>_controller.handleSignIn(),
                      )
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Center(
                      child: appButton(
                          buttonName: "Register",
                          isLogin: false,
                          context: context,
                          func: ()=>Navigator.pushNamed(context, "/register")))
                  //app register button
                ],
              ),
            ):const Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
                color: AppColors.primaryElement,
              ),
            )),
      ),
    );
  }
}

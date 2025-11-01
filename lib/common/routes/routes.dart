import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:facemark/common/routes/app_routes_names.dart';
import 'package:facemark/pages/sign_in/sign_in.dart';
import 'package:facemark/pages/sign_up/sign_up.dart';
import 'package:facemark/pages/welcome/welcome.dart';

import '../../global.dart';
import '../../screens/main_screen.dart';

class AppPages {
  static List<RouteEntity> routes() {
    return [
      RouteEntity(path:AppRoutesNames.WELCOME, page:Welcome()),
      RouteEntity(path: AppRoutesNames.SIGN_IN, page: const SignIn()),
      RouteEntity(path: AppRoutesNames.REGISTER, page: const SignUp()),
      RouteEntity(path: AppRoutesNames.MAINSCREEN, page: MainScreen()),
    ];
  }

  static MaterialPageRoute generateRouteSettings(RouteSettings settings) {
    if (kDebugMode) {
      print("clicked route is ${settings.name}");
    }
    if(settings.name!=null){

      var result = routes().where((element) => element.path==settings.name);

      if(result.isNotEmpty){
        // if we used this is first time  or not
        bool deviceFirstTime= Global.storageService.getDeviceFirstOpen();

        if(result.first.path==AppRoutesNames.WELCOME&&deviceFirstTime){

          bool isLoggedIn = Global.storageService.isLoggedIn();
          if(isLoggedIn){
            return MaterialPageRoute(
                builder: (_) => MainScreen(),
                settings: settings);
          }else{
            return MaterialPageRoute(
                builder: (_) => const SignIn(),
                settings: settings);
          }

        }else{
          if (kDebugMode) {
            print('App ran first time');
          }
          return MaterialPageRoute(
              builder: (_) => result.first.page,
              settings: settings);
        }
      }
    }
    return MaterialPageRoute(
        builder: (_) => SignIn(),
        settings: settings);
  }
}

class RouteEntity{
  String path;
  Widget page;
  RouteEntity({required this.path, required this.page});
}

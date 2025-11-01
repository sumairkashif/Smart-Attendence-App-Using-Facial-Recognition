import 'package:device_preview/device_preview.dart';
import 'package:facemark/pages/sign_in/sign_in.dart';
import 'package:facemark/pages/sign_up/sign_up.dart';
import 'package:facemark/pages/welcome/welcome.dart';
import 'package:facemark/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:facemark/common/routes/routes.dart';
import 'package:facemark/common/utils/app_styles.dart';
import 'package:facemark/pages/sign_in/sign_in.dart';
import 'package:facemark/pages/sign_up/sign_up.dart';
import 'package:facemark/pages/welcome/welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'common/utils/app_styles.dart';
import 'firebase_options.dart';
import 'global.dart';

Future<void> main() async{
  await Global.init();
  runApp(const ProviderScope(child: MyApp()));
}

var routeMaps = {
  "/":(context)=>Welcome(),
  "/signIn":(context)=>const SignIn(),
  "/register":(context)=>const SignUp(),
  "/mainscreen":(context)=>MainScreen(),
};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          title: 'Flutter Demo',
          // theme: AppTheme.appThemeData,
          // routes: routeMaps,
          onGenerateRoute: (settings)=>AppPages.generateRouteSettings(settings),

        ));
  }
}


final appCount = StateProvider<int>((ref) {
  return 3;
});

class MyHomePage extends ConsumerWidget {
  const MyHomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int count = ref.watch(appCount);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Riverpod app"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton:  Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton(
            heroTag: "one",
            onPressed:()=>navRoute(),
            tooltip: 'Increment',
            child: Icon(Icons.arrow_right_rounded),
          ),
          const FloatingActionButton(
            heroTag: "one",
            onPressed:myTap,
            tooltip: 'Increment',
            child: Icon(Icons.arrow_right_rounded),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

void myTap(){
  print("I am tapped");
}

void navRoute(){
  //do what you like here
}

class SecondPage extends ConsumerWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int count = ref.watch(appCount);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(
          "$count",
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}

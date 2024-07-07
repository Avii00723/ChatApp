import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_chatapp/pages/login_page.dart';
import 'package:firebase_chatapp/services/auth_services.dart';
import 'package:firebase_chatapp/services/navigation_service.dart';
import 'package:firebase_chatapp/utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async{
  await setup();
  runApp(
      MyApp()
  );

}
Future<void> setup() async{
  WidgetsFlutterBinding.ensureInitialized();
  await setupFirebase();
  await registerServices();
}
class MyApp extends StatelessWidget {
  final GetIt _getIt =GetIt.instance;
  late NavigationService _navigationService;
  late AuthServices _authService;

   MyApp({super.key}){
     _navigationService=_getIt.get<NavigationService>();
     _authService = _getIt.get<AuthServices>();
   }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigationService.navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      initialRoute:_authService.user!=null ? "/home":"/login",
      routes: _navigationService.routes,
    );
  }
}


import 'package:bms_front_end/src/app_routes/app_router.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  prefs = await SharedPreferences.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Bomach OS',
        theme: ThemeData(
          fontFamily: "Poppins",
          dataTableTheme: const DataTableThemeData(
            decoration: BoxDecoration(color: Colors.transparent),
          ),
          scaffoldBackgroundColor: AppColors.greyBg,
          useMaterial3: true,
          textSelectionTheme: TextSelectionThemeData(
            selectionColor: Colors.blue.withValues(alpha: 0.3),
            cursorColor: Colors.blue,
            selectionHandleColor: Colors.blue,
          ),
        ),
        routerConfig: goRouter,
      ),
    );
  }
}

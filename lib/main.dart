import 'package:assignment2/src/pages/channel_list_view.dart';
import 'package:assignment2/src/pages/create_channel_view.dart';
import 'package:assignment2/src/pages/login_view.dart';
import 'package:assignment2/src/utils/style.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  String appName = "Assessment";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      initialRoute: "/login",
      routes: <String, WidgetBuilder>{
        '/login': (context) => LoginView(),
        '/channel_list': (context) => const ChannelListView(),
        '/create_channel': (context) => const CreateChannelView(),
      },
      darkTheme: ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme(
          color: blackColor,
        ),
        primaryColor: primaryColor,
        textTheme: const TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: primaryColor,
          selectionHandleColor: primaryColor,
          selectionColor: selectionColor,
        ),
      ),
      themeMode: ThemeMode.dark, // Set theme mode to dark by default
    );
  }
}

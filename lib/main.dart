import 'package:flutter/material.dart';

// IMPORTACIONES
import 'package:band_names/pages/home.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'Material App',
      initialRoute: 'home',
      routes: {
        
        'home': ( _ ) => const HomePage(),
      },
    );
  }
}
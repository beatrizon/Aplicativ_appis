import 'package:flutter/material.dart';
import 'package:appis_app/assets/colors/colors.dart';

class Splash extends StatelessWidget {
  const Splash({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paletaDeCores.fundoApp,
      body: Center(
        child: Container(
          height: 200,
          width: 240,
          child: Image.asset('lib/assets/images/logo.png'),
        ),
      ),
    );
  }
}

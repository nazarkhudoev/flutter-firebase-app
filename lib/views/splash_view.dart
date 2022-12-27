import 'package:flutter/material.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 400,
            ),
            const Text(
              'Удобно, быстро, качествено',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ]),
      backgroundColor: Colors.orange,
    );
  }
}

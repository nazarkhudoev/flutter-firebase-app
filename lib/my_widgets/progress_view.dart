import 'package:flutter/material.dart';

class ProgressW extends StatefulWidget {
  const ProgressW({super.key});

  @override
  State<ProgressW> createState() => _ProgressWState();
}

class _ProgressWState extends State<ProgressW> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('In progress')),
        body: Center(
          child: CircularProgressIndicator(color: Colors.green),
        ));
  }
}

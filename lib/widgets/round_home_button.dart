import 'package:flutter/material.dart';
import '../home/home_screen.dart';

class RoundHomeButton extends StatelessWidget {
  const RoundHomeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: FloatingActionButton(
          heroTag: 'home_btn',
          backgroundColor: Colors.white,
          elevation: 6,
          shape: const CircleBorder(),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
          child: const Icon(Icons.home, color: Color(0xFF00ACC1), size: 32),
        ),
      ),
    );
  }
} 
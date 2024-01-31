import 'package:flutter/material.dart';

class BootstrapLoading extends StatelessWidget {
  const BootstrapLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

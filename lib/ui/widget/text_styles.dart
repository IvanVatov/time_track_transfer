import 'package:flutter/material.dart';

class Heading24 extends StatelessWidget {
  const Heading24({Key? key, required this.data}) : super(key: key);

  final String data;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: const TextStyle(
          color: Colors.deepPurple, fontSize: 24, fontWeight: FontWeight.w600),
    );
  }
}

class Heading18 extends StatelessWidget {
  const Heading18({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          color: Colors.deepPurple, fontSize: 18, fontWeight: FontWeight.w600),
    );
  }
}
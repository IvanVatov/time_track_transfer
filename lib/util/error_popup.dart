import 'package:flutter/material.dart';

extension SetMountedState<T extends StatefulWidget> on State<T> {
  void showErrorMessage(String message) {
    if (!mounted) {
      return;
    }

    var snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      padding: const EdgeInsets.all(24),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

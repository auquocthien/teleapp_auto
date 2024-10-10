import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showCustomToast(BuildContext context, String message,
    {ToastificationType? type = ToastificationType.success}) {
  toastification.show(
    context: context,
    title: Text(
      message,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
    ),
    autoCloseDuration: const Duration(seconds: 2),
    primaryColor: const Color.fromARGB(255, 95, 219, 100),
    type: type,
    style: ToastificationStyle.flat,
    boxShadow: const [
      BoxShadow(
        color: Color.fromARGB(6, 82, 82, 82),
        blurRadius: 16,
        offset: Offset(0, 16),
        spreadRadius: 0,
      )
    ],
  );
}

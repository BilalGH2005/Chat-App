import 'package:flutter/material.dart';

class LoadingDialogUtil {
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        alignment: Alignment.center,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}

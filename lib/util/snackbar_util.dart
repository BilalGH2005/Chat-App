import 'package:flutter/material.dart';

class SnackbarUtil {
  static void showErrorSnacbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                message,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../network/error_handler.dart';

class UiHelpers {
  /// Affiche un message d'erreur sécurisé dans un SnackBar
  static void showErrorSnackBar(BuildContext context, dynamic error, {String? errorContext}) {
    final message = ErrorHandler.getUserFriendlyMessage(error, context: errorContext);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Affiche un message de succès dans un SnackBar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Affiche un message d'information dans un SnackBar
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Affiche une dialog d'erreur sécurisée
  static void showErrorDialog(
    BuildContext context,
    dynamic error, {
    String? title,
    String? errorContext,
  }) {
    final message = ErrorHandler.getUserFriendlyMessage(error, context: errorContext);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title ?? 'Erreur'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Vérifie si une erreur est une erreur réseau et affiche un message approprié
  static void showNetworkAwareError(
    BuildContext context,
    dynamic error, {
    String? errorContext,
    bool useDialog = false,
  }) {
    if (useDialog) {
      showErrorDialog(context, error, errorContext: errorContext);
    } else {
      showErrorSnackBar(context, error, errorContext: errorContext);
    }
  }
}

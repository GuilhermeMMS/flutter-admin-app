// Lead Genius Admin - Modal de Confirmação
// Componente de diálogo reutilizável.

import 'package:flutter/material.dart';

/// Mostra modal de confirmação
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Confirmar',
  String cancelText = 'Cancelar',
  bool isDanger = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => ModalConfirm(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      isDanger: isDanger,
    ),
  );
}

/// Widget de modal de confirmação
class ModalConfirm extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDanger;

  const ModalConfirm({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          if (isDanger)
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28)
          else
            Icon(Icons.help_outline, color: theme.colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDanger ? Colors.red : null,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}

/// Modal com loading
class ModalLoading extends StatelessWidget {
  final String message;

  const ModalLoading({super.key, this.message = 'Carregando...'});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 20),
          Text(message),
        ],
      ),
    );
  }
}

/// Mostra snackbar de sucesso
void showSuccessSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Mostra snackbar de erro
void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

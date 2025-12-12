// Lead Genius Admin - Utils de Formatação
// Utilitários para formatação de dados.

import 'package:intl/intl.dart';

/// Formata valor como moeda brasileira
String formatCurrency(double value) {
  return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
}

/// Formata valor compacto (ex: 1.5K, 2.3M)
String formatCompactCurrency(double value) {
  if (value >= 1000000) {
    return 'R\$ ${(value / 1000000).toStringAsFixed(1)}M';
  } else if (value >= 1000) {
    return 'R\$ ${(value / 1000).toStringAsFixed(1)}K';
  }
  return formatCurrency(value);
}

/// Formata data no padrão brasileiro
String formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}

/// Formata data e hora
String formatDateTime(DateTime date) {
  return DateFormat('dd/MM/yyyy HH:mm').format(date);
}

/// Formata data relativa (ex: "há 2 dias")
String formatRelativeDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 365) {
    return 'há ${(difference.inDays / 365).floor()} ano(s)';
  } else if (difference.inDays > 30) {
    return 'há ${(difference.inDays / 30).floor()} mês(es)';
  } else if (difference.inDays > 0) {
    return 'há ${difference.inDays} dia(s)';
  } else if (difference.inHours > 0) {
    return 'há ${difference.inHours} hora(s)';
  } else if (difference.inMinutes > 0) {
    return 'há ${difference.inMinutes} minuto(s)';
  } else {
    return 'agora mesmo';
  }
}

/// Formata número de telefone
String formatPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
  
  if (digits.length == 11) {
    return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7)}';
  } else if (digits.length == 10) {
    return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6)}';
  }
  
  return phone;
}

/// Formata CPF
String formatCPF(String cpf) {
  final digits = cpf.replaceAll(RegExp(r'[^\d]'), '');
  
  if (digits.length == 11) {
    return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6, 9)}-${digits.substring(9)}';
  }
  
  return cpf;
}

/// Formata CNPJ
String formatCNPJ(String cnpj) {
  final digits = cnpj.replaceAll(RegExp(r'[^\d]'), '');
  
  if (digits.length == 14) {
    return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5, 8)}/${digits.substring(8, 12)}-${digits.substring(12)}';
  }
  
  return cnpj;
}

/// Obtém iniciais de um nome
String getInitials(String name) {
  final parts = name.trim().split(' ');
  
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }
  
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
}

/// Trunca texto com ellipsis
String truncateText(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength)}...';
}

/// Capitaliza primeira letra
String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

/// Capitaliza cada palavra
String capitalizeWords(String text) {
  return text.split(' ').map((word) => capitalize(word)).join(' ');
}

// Lead Genius Admin - Utils de Validação
// Utilitários para validação de dados.

/// Valida email
bool isValidEmail(String? email) {
  if (email == null || email.isEmpty) return false;
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

/// Valida senha (mínimo 6 caracteres)
bool isValidPassword(String? password) {
  if (password == null) return false;
  return password.length >= 6;
}

/// Valida senha forte (8+ chars, maiúscula, minúscula, número)
bool isStrongPassword(String? password) {
  if (password == null || password.length < 8) return false;
  
  final hasUppercase = password.contains(RegExp(r'[A-Z]'));
  final hasLowercase = password.contains(RegExp(r'[a-z]'));
  final hasDigit = password.contains(RegExp(r'[0-9]'));
  
  return hasUppercase && hasLowercase && hasDigit;
}

/// Valida telefone brasileiro
bool isValidPhone(String? phone) {
  if (phone == null) return false;
  final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
  return digits.length >= 10 && digits.length <= 11;
}

/// Valida CPF
bool isValidCPF(String? cpf) {
  if (cpf == null) return false;
  
  final digits = cpf.replaceAll(RegExp(r'[^\d]'), '');
  
  if (digits.length != 11) return false;
  
  // Verifica se todos os dígitos são iguais
  if (RegExp(r'^(\d)\1+$').hasMatch(digits)) return false;
  
  // Validação do primeiro dígito verificador
  int sum = 0;
  for (int i = 0; i < 9; i++) {
    sum += int.parse(digits[i]) * (10 - i);
  }
  int firstVerifier = (sum * 10) % 11;
  if (firstVerifier == 10) firstVerifier = 0;
  if (firstVerifier != int.parse(digits[9])) return false;
  
  // Validação do segundo dígito verificador
  sum = 0;
  for (int i = 0; i < 10; i++) {
    sum += int.parse(digits[i]) * (11 - i);
  }
  int secondVerifier = (sum * 10) % 11;
  if (secondVerifier == 10) secondVerifier = 0;
  if (secondVerifier != int.parse(digits[10])) return false;
  
  return true;
}

/// Valida CNPJ
bool isValidCNPJ(String? cnpj) {
  if (cnpj == null) return false;
  
  final digits = cnpj.replaceAll(RegExp(r'[^\d]'), '');
  
  if (digits.length != 14) return false;
  
  // Verifica se todos os dígitos são iguais
  if (RegExp(r'^(\d)\1+$').hasMatch(digits)) return false;
  
  // Validação do primeiro dígito verificador
  final multipliers1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
  int sum = 0;
  for (int i = 0; i < 12; i++) {
    sum += int.parse(digits[i]) * multipliers1[i];
  }
  int firstVerifier = sum % 11;
  firstVerifier = firstVerifier < 2 ? 0 : 11 - firstVerifier;
  if (firstVerifier != int.parse(digits[12])) return false;
  
  // Validação do segundo dígito verificador
  final multipliers2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
  sum = 0;
  for (int i = 0; i < 13; i++) {
    sum += int.parse(digits[i]) * multipliers2[i];
  }
  int secondVerifier = sum % 11;
  secondVerifier = secondVerifier < 2 ? 0 : 11 - secondVerifier;
  if (secondVerifier != int.parse(digits[13])) return false;
  
  return true;
}

/// Valida URL
bool isValidUrl(String? url) {
  if (url == null || url.isEmpty) return false;
  return Uri.tryParse(url)?.hasAbsolutePath ?? false;
}

/// Valida se é número
bool isNumeric(String? value) {
  if (value == null) return false;
  return double.tryParse(value) != null;
}

/// Valida valor monetário
bool isValidCurrency(String? value) {
  if (value == null) return false;
  final cleaned = value.replaceAll(RegExp(r'[R\$\s\.]'), '').replaceAll(',', '.');
  return double.tryParse(cleaned) != null;
}

/// Validador para FormField - Campo obrigatório
String? validateRequired(String? value, [String fieldName = 'Este campo']) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName é obrigatório';
  }
  return null;
}

/// Validador para FormField - Email
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email é obrigatório';
  }
  if (!isValidEmail(value)) {
    return 'Email inválido';
  }
  return null;
}

/// Validador para FormField - Senha
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Senha é obrigatória';
  }
  if (value.length < 6) {
    return 'Senha deve ter pelo menos 6 caracteres';
  }
  return null;
}

/// Validador para FormField - Telefone
String? validatePhone(String? value) {
  if (value == null || value.isEmpty) {
    return null; // Telefone é opcional
  }
  if (!isValidPhone(value)) {
    return 'Telefone inválido';
  }
  return null;
}

/// Validador para FormField - CPF
String? validateCPF(String? value) {
  if (value == null || value.isEmpty) {
    return null; // CPF é opcional
  }
  if (!isValidCPF(value)) {
    return 'CPF inválido';
  }
  return null;
}

/// Validador para FormField - CNPJ
String? validateCNPJ(String? value) {
  if (value == null || value.isEmpty) {
    return null; // CNPJ é opcional
  }
  if (!isValidCNPJ(value)) {
    return 'CNPJ inválido';
  }
  return null;
}

/// Validador para FormField - Número positivo
String? validatePositiveNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'Valor é obrigatório';
  }
  final number = double.tryParse(value);
  if (number == null || number < 0) {
    return 'Valor deve ser um número positivo';
  }
  return null;
}

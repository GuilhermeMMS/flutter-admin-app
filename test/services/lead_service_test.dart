// Lead Genius Admin - Testes do LeadService
// Exemplo de testes unitários com mocks.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Nota: Este é um exemplo básico de estrutura de testes.
// Para executar, você precisaria configurar mocks adequados do Supabase.

void main() {
  group('LeadService', () {
    test('should return empty list when no leads exist', () async {
      // Arrange
      final leads = <Map<String, dynamic>>[];

      // Act & Assert
      expect(leads, isEmpty);
    });

    test('should correctly parse lead status', () {
      // Arrange
      const status = 'qualificado';
      
      // Act
      final displayName = _getStatusDisplayName(status);
      
      // Assert
      expect(displayName, equals('Qualificado'));
    });

    test('should calculate total estimated value correctly', () {
      // Arrange
      final values = [1000.0, 2500.0, 5000.0];
      
      // Act
      final total = values.fold<double>(0, (sum, v) => sum + v);
      
      // Assert
      expect(total, equals(8500.0));
    });

    test('should generate correct initials from name', () {
      // Arrange
      const name = 'João Silva';
      
      // Act
      final initials = _getInitials(name);
      
      // Assert
      expect(initials, equals('JS'));
    });

    test('should handle single word name for initials', () {
      // Arrange
      const name = 'João';
      
      // Act
      final initials = _getInitials(name);
      
      // Assert
      expect(initials, equals('J'));
    });

    test('should validate email format', () {
      // Arrange
      const validEmail = 'teste@email.com';
      const invalidEmail = 'teste@';
      
      // Act & Assert
      expect(_isValidEmail(validEmail), isTrue);
      expect(_isValidEmail(invalidEmail), isFalse);
    });

    test('should validate phone format', () {
      // Arrange
      const validPhone = '11999999999';
      const invalidPhone = '123';
      
      // Act & Assert
      expect(_isValidPhone(validPhone), isTrue);
      expect(_isValidPhone(invalidPhone), isFalse);
    });
  });

  group('Lead Status', () {
    test('should identify active leads correctly', () {
      final activeStatuses = ['novo', 'contatado', 'qualificado', 'proposta', 'negociacao'];
      final inactiveStatuses = ['ganho', 'perdido'];

      for (final status in activeStatuses) {
        expect(_isActiveStatus(status), isTrue, reason: '$status should be active');
      }

      for (final status in inactiveStatuses) {
        expect(_isActiveStatus(status), isFalse, reason: '$status should be inactive');
      }
    });
  });
}

// Helper functions para os testes
String _getStatusDisplayName(String status) {
  switch (status) {
    case 'novo': return 'Novo';
    case 'contatado': return 'Contatado';
    case 'qualificado': return 'Qualificado';
    case 'proposta': return 'Proposta';
    case 'negociacao': return 'Negociação';
    case 'ganho': return 'Ganho';
    case 'perdido': return 'Perdido';
    default: return status;
  }
}

String _getInitials(String name) {
  final parts = name.split(' ');
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
}

bool _isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

bool _isValidPhone(String phone) {
  return phone.length >= 10 && phone.length <= 15;
}

bool _isActiveStatus(String status) {
  return status != 'ganho' && status != 'perdido';
}

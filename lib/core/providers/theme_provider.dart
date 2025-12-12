// Lead Genius Admin - Provider de Tema
// Gerencia o tema (claro/escuro) do aplicativo.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/constants.dart';

/// Provider para o modo de tema atual
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// Notifier para gerenciar o tema
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  /// Carrega o tema salvo nas preferências
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(StorageKeys.themeMode);
    
    if (themeString == null) {
      state = ThemeMode.system;
    } else if (themeString == 'light') {
      state = ThemeMode.light;
    } else if (themeString == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.system;
    }
  }

  /// Altera o tema e salva nas preferências
  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    
    String themeString;
    switch (mode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      default:
        themeString = 'system';
    }
    
    await prefs.setString(StorageKeys.themeMode, themeString);
  }

  /// Alterna entre claro e escuro
  Future<void> toggleTheme() async {
    if (state == ThemeMode.light) {
      await setTheme(ThemeMode.dark);
    } else {
      await setTheme(ThemeMode.light);
    }
  }

  /// Define como tema do sistema
  Future<void> useSystemTheme() async {
    await setTheme(ThemeMode.system);
  }
}

/// Provider para verificar se está no modo escuro
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  // Nota: para verificar o tema real do sistema, precisaria do BuildContext
  // Aqui retornamos baseado no modo selecionado
  return themeMode == ThemeMode.dark;
});

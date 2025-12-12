// Lead Genius Admin - App Widget Principal
// Widget raiz do aplicativo com configuração de tema e router.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'routes.dart';
import 'theme.dart';
import '../core/providers/theme_provider.dart';

/// Widget principal do aplicativo
class LeadGeniusApp extends ConsumerWidget {
  const LeadGeniusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa o tema atual
    final themeMode = ref.watch(themeModeProvider);
    
    // Obtém o router
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      // Configuração de título
      title: 'Lead Genius Admin',
      debugShowCheckedModeBanner: false,

      // Configuração de tema
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Configuração de localização (PT-BR)
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Configuração de navegação
      routerConfig: router,
    );
  }
}

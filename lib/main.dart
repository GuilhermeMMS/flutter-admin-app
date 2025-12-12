// Lead Genius Admin - Entry Point
// Este é o ponto de entrada do aplicativo Flutter multi-tenant.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';

/// Função principal - inicializa o aplicativo
Future<void> main() async {
  // Garante que os bindings do Flutter estão inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega variáveis de ambiente
  await dotenv.load(fileName: '.env');

  // Inicializa o Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
  );

  // Executa o aplicativo com ProviderScope para Riverpod
  runApp(
    const ProviderScope(
      child: LeadGeniusApp(),
    ),
  );
}

/// Getter global para acessar o cliente Supabase
SupabaseClient get supabase => Supabase.instance.client;

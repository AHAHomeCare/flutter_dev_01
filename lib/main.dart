import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'screens/account_screen.dart';
import 'screens/app_shell.dart';
import 'services/account_api.dart';
import 'services/sona_task_api.dart';

void main() => runApp(const SonaTasksApp());

class SonaTasksApp extends StatefulWidget {
  const SonaTasksApp({super.key, this.api, this.accountApi});
  final SonaTaskApi? api;
  final AccountApi? accountApi;

  @override
  State<SonaTasksApp> createState() => _SonaTasksAppState();
}

class _SonaTasksAppState extends State<SonaTasksApp> {
  final _navigator = GlobalKey<NavigatorState>();
  http.Client? _client;
  AccountSession? _session;
  Timer? _expiry;

  AccountApi get _accountApi =>
      widget.accountApi ??
      AccountApi(
        _client ??= http.Client(),
        const String.fromEnvironment(
          'SONATASK_ACCOUNT_API_URL',
          defaultValue: 'https://sona.somee.com/api/v1',
        ),
      );

  void _signIn(AccountSession session) {
    _expiry?.cancel();
    _expiry = Timer(session.expiresAt.difference(DateTime.now()), _signOut);
    setState(() => _session = session);
  }

  void _signOut() {
    _expiry?.cancel();
    _navigator.currentState?.popUntil((route) => route.isFirst);
    setState(() => _session = null);
  }

  @override
  void dispose() {
    _expiry?.cancel();
    _client?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    return MaterialApp(
      navigatorKey: _navigator,
      title: 'SonaTasks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF315ACB)),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Color(0xFFF7F8FC),
        ),
        cardTheme: const CardThemeData(color: Colors.white, elevation: 0),
      ),
      home: session != null
          ? AppShell(api: widget.api, session: session, onSignOut: _signOut)
          : AccountScreen(api: _accountApi, onSignedIn: _signIn),
    );
  }
}

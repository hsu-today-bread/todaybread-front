import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/providers/login/login_provider.dart';
import 'package:todaybread/providers/store/store_provider.dart';
import 'package:todaybread/screens/main/main_shell.dart';

class BossSwitchingScreen extends StatefulWidget {
  const BossSwitchingScreen({super.key});

  @override
  State<BossSwitchingScreen> createState() => _BossSwitchingScreenState();
}

class _BossSwitchingScreenState extends State<BossSwitchingScreen> {
  Timer? _dotsTimer;
  int _dotCount = 1;

  @override
  void initState() {
    super.initState();
    _dotsTimer = Timer.periodic(const Duration(milliseconds: 450), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _dotCount = _dotCount == 3 ? 1 : _dotCount + 1;
      });
    });
    unawaited(_switchToBossShell());
  }

  @override
  void dispose() {
    _dotsTimer?.cancel();
    super.dispose();
  }

  Future<void> _switchToBossShell() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) {
      return;
    }

    await context.read<AuthProvider>().refreshRoleFromStoredToken();
    if (!mounted) {
      return;
    }
    await context.read<StoreProvider>().fetchStatus();
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * _dotCount;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Text(
            '사장님 계정으로 전환 중 $dots',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/app/router/app_router.dart';
import 'package:tmjapp/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:tmjapp/utils/strings.dart';

class ActiveSessionsPage extends StatefulWidget {
  const ActiveSessionsPage({super.key});

  @override
  State<ActiveSessionsPage> createState() => _ActiveSessionsPageState();
}

class _ActiveSessionsPageState extends State<ActiveSessionsPage> {
  String _identifier = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _identifier =
          prefs.getString(Strings.prefEmail) ?? 'Conta conectada');
    }
  }

  Future<void> _signOut() async {
    await ProfileLocalDataSource().clearSession();
    if (!mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.signIn, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessões ativas')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('DISPOSITIVO ATUAL',
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: Color(0xFF667085))),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading:
                  const CircleAvatar(child: Icon(Icons.smartphone_rounded)),
              title: const Text('Este dispositivo'),
              subtitle: Text('$_identifier\nSessão em uso agora'),
              isThreeLine: true,
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'O serviço atual mantém uma sessão por aparelho. Para invalidar esta sessão, saia da conta abaixo.',
            style: TextStyle(color: Color(0xFF667085), height: 1.45),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('SAIR DESTE DISPOSITIVO'),
          ),
        ],
      ),
    );
  }
}

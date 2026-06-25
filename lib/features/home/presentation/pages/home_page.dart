import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_turista_page.dart';
import 'home_local_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _tipoUsuario = 'Turista';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _cargarTipo();
  }

  Future<void> _cargarTipo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tipoUsuario = prefs.getString('tipo_usuario') ?? 'Turista';
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
        ),
      );
    }

    return _tipoUsuario == 'Turista'
        ? const HomeTuristaPage()
        : const HomeLocalPage();
  }
}
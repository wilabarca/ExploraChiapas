import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileInterests extends StatefulWidget {
  const ProfileInterests({super.key});

  @override
  State<ProfileInterests> createState() => _ProfileInterestsState();
}

class _ProfileInterestsState extends State<ProfileInterests> {
  List<String> _intereses = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _intereses = prefs.getStringList('intereses') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_intereses.isEmpty) {
      return const Text(
        'Sin intereses seleccionados',
        style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _intereses.map((interes) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFA5D6A7), width: 1),
          ),
          child: Text(
            interes,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}

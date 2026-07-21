import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileInterests
    extends StatefulWidget {
  const ProfileInterests({
    super.key,
  });

  @override
  State<ProfileInterests>
      createState() =>
          _ProfileInterestsState();
}

class _ProfileInterestsState
    extends State<ProfileInterests> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _load();
    });
  }

  Future<void> _load() async {
    await context
        .read<AuthProvider>()
        .loadUserInterests();

    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final provider =
        context.watch<AuthProvider>();

    if (_loading) {
      return const Padding(
        padding:
            EdgeInsets.symmetric(
          vertical: 8,
        ),
        child: SizedBox(
          width: 20,
          height: 20,
          child:
              CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }

    final intereses =
        provider
                .userInterests
                ?.interests ??
            [];

    if (intereses.isEmpty) {
      return const Text(
        'Sin intereses seleccionados',
        style: TextStyle(
          fontSize: 13,
          color: Color(0xFF999999),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          intereses.map((interes) {
        return Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color:
                const Color(0xFFE8F5E9),
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            border: Border.all(
              color:
                  const Color(
                0xFFA5D6A7,
              ),
              width: 1,
            ),
          ),
          child: Text(
            interes.name,
            style:
                const TextStyle(
              fontSize: 13,
              color:
                  Color(0xFF2E7D32),
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}
import 'package:flutter_test/flutter_test.dart';
import 'package:explorachiapas/features/auth/presentation/utils/validadores_auth.dart';

void main() {
  group('ValidadoresAuth.email', () {
    test('vacío devuelve error', () {
      expect(ValidadoresAuth.email(''), isNotNull);
    });

    test('sin formato válido devuelve error', () {
      expect(ValidadoresAuth.email('no-es-un-correo'), isNotNull);
    });

    test('válido devuelve null', () {
      expect(ValidadoresAuth.email('explorador@selva.com'), isNull);
    });

    test('más de 150 caracteres devuelve error', () {
      final local = 'a' * 145;
      final correoLargo = '$local@x.com'; // > 150 caracteres en total
      expect(correoLargo.length, greaterThan(150));
      expect(ValidadoresAuth.email(correoLargo), isNotNull);
    });
  });

  group('ValidadoresAuth.nombre', () {
    test('vacío devuelve error', () {
      expect(ValidadoresAuth.nombre(''), isNotNull);
    });

    test('demasiado corto devuelve error', () {
      expect(ValidadoresAuth.nombre('A'), isNotNull);
    });

    test('válido devuelve null', () {
      expect(ValidadoresAuth.nombre('José Pérez Ñoño'), isNull);
    });

    test('más de 100 caracteres devuelve error', () {
      final nombreLargo = 'A' * 101;
      expect(ValidadoresAuth.nombre(nombreLargo), isNotNull);
    });
  });

  group('ValidadoresAuth.telefono', () {
    test('letras devuelven error', () {
      expect(ValidadoresAuth.telefono('abcdefghij'), isNotNull);
    });

    test('9 dígitos devuelve error', () {
      expect(ValidadoresAuth.telefono('123456789'), isNotNull);
    });

    test('10 dígitos devuelve null', () {
      expect(ValidadoresAuth.telefono('1234567890'), isNull);
    });

    test('15 dígitos devuelve null', () {
      expect(ValidadoresAuth.telefono('123456789012345'), isNull);
    });

    test('más de 15 dígitos devuelve error', () {
      expect(ValidadoresAuth.telefono('1234567890123456'), isNotNull);
    });
  });

  group('ValidadoresAuth.password', () {
    test('menos de 8 caracteres devuelve error', () {
      expect(ValidadoresAuth.password('abc'), isNotNull);
    });

    test('más de 72 caracteres devuelve error', () {
      final passwordLarga = 'Abc12345${'a' * 70}'; // > 72 caracteres
      expect(passwordLarga.length, greaterThan(72));
      expect(ValidadoresAuth.password(passwordLarga), isNotNull);
    });

    test('sin minúscula devuelve error', () {
      expect(ValidadoresAuth.password('ABCDEFG1'), isNotNull);
    });

    test('sin mayúscula devuelve error', () {
      expect(ValidadoresAuth.password('abcdefg1'), isNotNull);
    });

    test('sin número devuelve error', () {
      expect(ValidadoresAuth.password('Abcdefgh'), isNotNull);
    });

    test('válida devuelve null', () {
      expect(ValidadoresAuth.password('Abcdefg1'), isNull);
    });
  });

  group('ValidadoresAuth.confirmarPassword', () {
    test('vacía devuelve error', () {
      expect(ValidadoresAuth.confirmarPassword('Abcdefg1', ''), isNotNull);
    });

    test('diferente devuelve error', () {
      expect(
        ValidadoresAuth.confirmarPassword('Abcdefg1', 'Abcdefg2'),
        isNotNull,
      );
    });

    test('igual devuelve null', () {
      expect(ValidadoresAuth.confirmarPassword('Abcdefg1', 'Abcdefg1'), isNull);
    });
  });
}

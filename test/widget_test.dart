import 'package:flutter_test/flutter_test.dart';
import 'package:explorachiapas/app.dart';

void main() {
  test('ExploraChiapasApp puede construirse', () {
    const app = ExploraChiapasApp();

    expect(app, isA<ExploraChiapasApp>());
  });
}
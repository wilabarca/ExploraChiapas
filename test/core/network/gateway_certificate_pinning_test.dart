import 'package:flutter_test/flutter_test.dart';
import 'package:explorachiapas/core/network/gateway_certificate_pinning.dart';
import 'package:explorachiapas/core/utils/app_constants.dart';

void main() {
  group('GatewayCertificatePinning & URLs', () {
    test(
      'El host esperado es exactamente api-gateway-explorachiapas.onrender.com',
      () {
        expect(
          AppConstants.gatewayHost,
          'api-gateway-explorachiapas.onrender.com',
        );
      },
    );

    test('Las URL de backend y NLP usan HTTPS', () {
      expect(AppConstants.serverBaseUrl.startsWith('https://'), true);
      expect(AppConstants.baseUrl.startsWith('https://'), true);
      expect(AppConstants.mlServiceBaseUrl.startsWith('https://'), true);
    });

    test('baseUrl contiene /v1/api y mlServiceBaseUrl contiene /ml', () {
      expect(AppConstants.baseUrl.contains('/v1/api'), true);
      expect(AppConstants.mlServiceBaseUrl.contains('/ml'), true);
    });

    test('No contienen hosts antiguos ni HTTP', () {
      expect(
        AppConstants.serverBaseUrl.contains('explora-chiapas.onrender.com'),
        false,
      );
      expect(AppConstants.serverBaseUrl.contains('18.213.180.41'), false);

      expect(AppConstants.mlServiceBaseUrl.contains('18.213.180.41'), false);
      expect(AppConstants.mlServiceBaseUrl.startsWith('http://'), false);
    });

    test(
      'La normalización de huellas elimina diferencias entre mayúsculas y minúsculas y acepta huella válida',
      () {
        const validDigestLowercase =
            '041ec4c69f6677197b4ef1c067421164f4b269da27f2f530292cabbb051fc1b1';
        const validDigestUppercase =
            '041EC4C69F6677197B4EF1C067421164F4B269DA27F2F530292CABBB051FC1B1';

        expect(
          GatewayCertificatePinning.validateDigest(
            digest: validDigestLowercase,
            host: AppConstants.gatewayHost,
            port: 443,
          ),
          true,
        );
        expect(
          GatewayCertificatePinning.validateDigest(
            digest: validDigestUppercase,
            host: AppConstants.gatewayHost,
            port: 443,
          ),
          true,
        );
      },
    );

    test('Una huella diferente es rechazada', () {
      const invalidDigest =
          '1111111111111111111111111111111111111111111111111111111111111111';
      expect(
        GatewayCertificatePinning.validateDigest(
          digest: invalidDigest,
          host: AppConstants.gatewayHost,
          port: 443,
        ),
        false,
      );
    });

    test('Un host diferente es rechazado aunque la huella sea válida', () {
      const validDigest =
          '041ec4c69f6677197b4ef1c067421164f4b269da27f2f530292cabbb051fc1b1';
      expect(
        GatewayCertificatePinning.validateDigest(
          digest: validDigest,
          host: 'otro-dominio.com',
          port: 443,
        ),
        false,
      );
    });

    test('Huella con : es aceptada', () {
      const digestWithColons =
          '04:1E:C4:C6:9F:66:77:19:7B:4E:F1:C0:67:42:11:64:F4:B2:69:DA:27:F2:F5:30:29:2C:AB:BB:05:1F:C1:B1';
      expect(
        GatewayCertificatePinning.validateDigest(
          digest: digestWithColons,
          host: AppConstants.gatewayHost,
          port: 443,
        ),
        true,
      );
    });

    test('Puerto 80 es rechazado', () {
      const validDigest =
          '041ec4c69f6677197b4ef1c067421164f4b269da27f2f530292cabbb051fc1b1';
      expect(
        GatewayCertificatePinning.validateDigest(
          digest: validDigest,
          host: AppConstants.gatewayHost,
          port: 80,
        ),
        false,
      );
    });

    test('Puerto 8443 es rechazado', () {
      const validDigest =
          '041ec4c69f6677197b4ef1c067421164f4b269da27f2f530292cabbb051fc1b1';
      expect(
        GatewayCertificatePinning.validateDigest(
          digest: validDigest,
          host: AppConstants.gatewayHost,
          port: 8443,
        ),
        false,
      );
    });

    test('Host parecido pero no exacto es rechazado', () {
      const validDigest =
          '041ec4c69f6677197b4ef1c067421164f4b269da27f2f530292cabbb051fc1b1';
      expect(
        GatewayCertificatePinning.validateDigest(
          digest: validDigest,
          host: 'evil-api-gateway-explorachiapas.onrender.com',
          port: 443,
        ),
        false,
      );
    });

    test('Subdominio falso es rechazado', () {
      const validDigest =
          '041ec4c69f6677197b4ef1c067421164f4b269da27f2f530292cabbb051fc1b1';
      expect(
        GatewayCertificatePinning.validateDigest(
          digest: validDigest,
          host: 'api-gateway-explorachiapas.onrender.com.evil.com',
          port: 443,
        ),
        false,
      );
    });
  });
}

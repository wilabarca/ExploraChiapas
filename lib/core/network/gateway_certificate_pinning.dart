import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/io.dart';
import '../utils/app_constants.dart';

class GatewayCertificatePinning {
  static const Set<String> allowedCertificateSha256 = {
    '041ec4c69f6677197b4ef1c067421164f4b269da27f2f530292cabbb051fc1b1',
  };

  static IOHttpClientAdapter createAdapter() {
    return IOHttpClientAdapter(
      validateCertificate:
          (X509Certificate? certificate, String host, int port) {
            return validateCertificate(certificate, host, port);
          },
    );
  }

  static bool validateCertificate(
    X509Certificate? certificate,
    String host,
    int port,
  ) {
    if (certificate == null) {
      return false;
    }

    final digest = sha256.convert(certificate.der).toString();

    return validateDigest(digest: digest, host: host, port: port);
  }

  static bool validateDigest({
    required String digest,
    required String host,
    required int port,
  }) {
    final normalizedDigest = digest.replaceAll(':', '').trim().toLowerCase();

    return host == AppConstants.gatewayHost &&
        port == 443 &&
        allowedCertificateSha256.contains(normalizedDigest);
  }
}

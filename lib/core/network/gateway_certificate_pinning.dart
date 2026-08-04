import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/io.dart';
import '../utils/app_constants.dart';

class GatewayCertificatePinning {
  static const Set<String> allowedCertificateSha256 = {
    '041ec4c69f6677197b4ef1c067421164f4b269da27f2f530292cabbb051fc1b1',
  };

  static IOHttpClientAdapter createAdapter() {
    final adapter = IOHttpClientAdapter();
    adapter.createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        return validateCertificate(cert, host, port);
      };
      return client;
    };
    return adapter;
  }

  static bool validateDigest(String digest, String host, int port) {
    final normalizedDigest = digest.toLowerCase();
    return host == AppConstants.gatewayHost &&
           port == 443 &&
           allowedCertificateSha256.contains(normalizedDigest);
  }

  static bool validateCertificate(X509Certificate? cert, String host, int port) {
    if (cert == null) return false;
    
    final digest = sha256.convert(cert.der).toString();
    return validateDigest(digest, host, port);
  }
}

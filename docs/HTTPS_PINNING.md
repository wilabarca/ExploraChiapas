# Certificate Pinning & API Gateway Security

## 1. Dominio protegido
La aplicación móvil se comunica exclusivamente a través del API Gateway configurado en:
`https://api-gateway-explorachiapas.onrender.com`

Todas las solicitudes de backend y NLP pasan por el puerto 443 usando este host exacto.

## 2. Comando utilizado para extraer SHA-256
Se utilizó el siguiente comando OpenSSL para extraer la huella original del certificado en formato DER y derivar su SHA-256:

```bash
echo | openssl s_client -connect api-gateway-explorachiapas.onrender.com:443 -servername api-gateway-explorachiapas.onrender.com 2>/dev/null | openssl x509 -outform DER | sha256sum
```

## 3. Huella obtenida
El valor SHA-256 (en minúsculas) implementado es:
`041ec4c69f6677197b4ef1c067421164f4b269da27f2f530292cabbb051fc1b1`

## 4. Archivos donde se implementó el pinning
- `lib/core/network/gateway_certificate_pinning.dart`: Implementa el `IOHttpClientAdapter` con la lógica central de validación.
- `lib/core/network/api_client.dart`: Usa el adaptador en el cliente principal e intercepta el header `X-Gateway`.
- `lib/core/network/ml_api_client.dart`: Usa el adaptador en el cliente ML e intercepta el header `X-Gateway`.
- `lib/core/utils/app_constants.dart`: Se unificaron las URL hacia el API Gateway.
- `android/app/src/main/AndroidManifest.xml`: Se inhabilitó el tráfico no seguro (`usesCleartextTraffic="false"`).

## 5. Cómo ejecutar las pruebas
Las pruebas unitarias puras (sin necesidad de red real) pueden ejecutarse con:
```bash
flutter test test/core/network/gateway_certificate_pinning_test.dart
```

## 6. Pruebas MitM (Dónde tomar capturas)
Para las pruebas de Man-in-the-Middle con Charles Proxy / OWASP ZAP:
1. **Condiciones Normales:** Captura de la terminal con el comando `flutter run` mostrando los logs exitosos de `X-Gateway: ExploraChiapas` tras abrir la aplicación.
2. **Conexión Interceptada:** Captura del log de Flutter abortando la conexión (`HTTPS_PINNING_BLOCKED host=api-gateway-explorachiapas.onrender.com`) y captura de la pantalla mostrando el mensaje de error "No se pudo verificar la identidad del servidor".

## 7. Rotación del Certificado
La colección `allowedCertificateSha256` acepta varias huellas simultáneamente. Antes de cambiar el certificado en el servidor (API Gateway), se debe publicar una actualización de la aplicación que incluya tanto la huella actual como la huella futura. Una vez que la mayoría de los usuarios haya actualizado, se rota el certificado en el servidor de Render, y posteriormente, en una futura versión de la aplicación, se puede eliminar la huella antigua. Nunca se debe aceptar cualquier certificado como fallback temporal, ya que comprometería la seguridad.

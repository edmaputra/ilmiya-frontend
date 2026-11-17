import 'dart:io';
import 'package:flutter/foundation.dart';

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Accept self-signed / local certificates for localhost development
        final isLocalHost = host == 'localhost' ||
            host == '127.0.0.1' ||
            host == '::1' ||
            host.endsWith('.localhost') ||
            host.endsWith('.local');
        if (isLocalHost) {
          return true;
        }
        // In debug mode, allow self-signed certificates for development BE hosts
        if (kDebugMode) {
          return true;
        }
        return false;
      };
  }
}

void initHttpOverrides() {
  HttpOverrides.global = DevHttpOverrides();
}

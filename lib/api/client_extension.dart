import 'dart:io';

import 'package:system_proxy/system_proxy.dart';

extension HttpClientExtension on HttpClient {
  Future<HttpClient> autoProxy() async {
    Map<String, String>? sysProxy = await SystemProxy.getProxySettings();
    var proxy = "DIRECT";
    if (sysProxy != null) {
      proxy = "PROXY ${sysProxy['host']}:${sysProxy['port']}; DIRECT";
    }
    this.findProxy = (uri) {
      return proxy;
    };
    return this;
  }
}
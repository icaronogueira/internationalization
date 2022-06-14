import 'dart:convert';

import 'package:bytebank/http/webclient.dart';
import 'package:http/http.dart';

final String MESSAGES_URI = "icaronogueira/3cdd9f44ac747a10e7622bb26fc78ead/raw/efe9ec143f23200a556c1f0389a8e09afc377392/";

class I18NWebClient {
  final String _viewKey;

  I18NWebClient(this._viewKey);


  Future<Map<String,dynamic>> findAll() async {
    final Response response =
        await client.get(Uri.https("gist.githubusercontent.com","$MESSAGES_URI$_viewKey.json"));
    final Map<String,dynamic> decodedJson = jsonDecode(response.body);
    return decodedJson;
  }
}

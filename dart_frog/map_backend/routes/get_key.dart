import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:map_backend/helper_funcs/helper.dart';
import 'package:map_backend/helper_funcs/variables.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response.json(body: {'error': 'Method not allowed'}, statusCode: 405);
  }

  final keyPair = generateRSAKeyPair();
  publickey = keyPair.publicKey;
  privatekey = keyPair.privateKey;

  final publicKeyString = jsonEncode({
    'modulus': publickey!.modulus.toString(),
    'exponent': publickey!.exponent.toString(),
  });

  return Response(body:publicKeyString);
}

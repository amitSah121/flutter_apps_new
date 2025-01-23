import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:map_backend/helper_funcs/helper.dart';
import 'package:map_backend/helper_funcs/variables.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response.json(body: {'error': 'Method not allowed'}, statusCode: 405);
  }

  final keyPair = generateRSAKeyPair();
  authPublicKey = keyPair.publicKey;
  authPrivateKey = keyPair.privateKey;

  final publicKeyString = jsonEncode({
    'modulus': authPublicKey!.modulus.toString(),
    'exponent': authPublicKey!.exponent.toString(),
  });


  return Response(body:publicKeyString);
}

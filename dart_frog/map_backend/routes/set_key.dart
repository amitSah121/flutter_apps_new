import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:map_backend/helper_funcs/helper.dart';
import 'package:map_backend/helper_funcs/variables.dart';
import 'package:pointycastle/asymmetric/api.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response.json(body: {'error': 'Method not allowed'}, statusCode: 405);
  }


  final params = context.request.uri.queryParameters;
  if(!(params.containsKey('modulus') && params.containsKey('exponent'))){
    return Response.json(body: {'error': 'Wrong params'}, statusCode: 404);
  }

  final modulus = BigInt.parse(params['modulus'] as String);
  final exponent = BigInt.parse(params['exponent'] as String);
  publickey = RSAPublicKey(modulus, exponent);
  // print({params['modulus'],params['exponent']});

  return Response(body:"success");
}

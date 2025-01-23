import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:map_backend/helper_funcs/helper.dart';
import 'package:map_backend/helper_funcs/variables.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => getAllFiles(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed))
  };
}


Future<Response> getAllFiles(RequestContext context) async {
  final request = context.request;
  final params = request.uri.queryParameters;

  final db = Db(uri);
  await db.open();
  final coll = db.collection('user');

  final username = params['username'] ?? '__hello';
  final password = params['password'] ?? '__fello';
  final pass  = rsaDecrypt(Uri.decodeComponent(password as String), null
       , authPrivateKey!,);
    // print({'hello',pass});

  // List<Map<String,dynamic>> 
  final temp = await coll.find({
      'username':username,
      'password': sha256.convert(utf8.encode(pass,),).toString() ,
    }).toList();

  // return Response(body: 'invalid');
  
  if(temp.isEmpty ){
    return Response(body: 'invalid');
  }

  final userDir = Directory('./assets/$username');

  if (!userDir.existsSync()) {
    return Response(
      body: jsonEncode({'error': 'No files found'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final filePath = File('./assets/$username/allFilesClient');
  if(filePath.existsSync()){
    final files = File('./assets/$username/allFilesClient').readAsLinesSync();
    return Response(
      body: jsonEncode({'files': files}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final files = userDir
    .listSync(recursive: true)
    .whereType<File>()
    .map((file) => extractPathAfterUsername(file.path, username))
    .toList();

  return Response(
    body: jsonEncode({'files': files}),
    headers: {'Content-Type': 'application/json'},
  );
}

String extractPathAfterUsername(String filePath, String username) {
  final pattern = './assets/$username/';
  final index = filePath.indexOf(pattern);

  if (index != -1) {
    return filePath.substring(index + pattern.length);
  }

  // Return the original path if the pattern is not found
  return filePath;
}


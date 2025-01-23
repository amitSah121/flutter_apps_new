import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:map_backend/helper_funcs/file_funcs.dart';
import 'package:map_backend/helper_funcs/helper.dart';
import 'package:map_backend/helper_funcs/variables.dart';
import 'package:mongo_dart/mongo_dart.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => getFileWithoutExtension(context),
    HttpMethod.post => postFileWithoutExtension(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> getFileWithoutExtension(RequestContext context) async {
  final request = context.request;
  final params = request.uri.queryParameters;

  final db = Db(uri);
  await db.open();
  final coll = db.collection('user');

  final username = params['username'] ?? '__hello';
  final password = params['password'] ?? '__fello';
  final filePath = params['path'] ?? '__jello';
  
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

  if (filePath != '__jello') {
    final file = File('./assets/$username/$filePath');
    if (!file.existsSync()) {
      return Response(
          statusCode: HttpStatus.notFound, body: 'File not found');
    }

    final filedata = await file.readAsString();
    // print(filedata);
    File('./assets/temp101').writeAsStringSync(rsaEncrypt(filedata, publickey!, null));

    final fileBytes = File('./assets/temp101').readAsStringSync();

    return Response(
      body: fileBytes,
    );
  }

  return Response(body: 'invalid');
}

Future<Response> postFileWithoutExtension(RequestContext context) async {
  final request = context.request;
  final formData = await request.formData();
  // print("hello");

  final fileData = formData.files['file'];
  // print(fileData);

  final params = request.uri.queryParameters;

  final db = Db(uri);
  await db.open();
  final coll = db.collection('user');
  // print(params['username']);

  final username = params['username'] ?? '__hello';
  final password = params['password'] ?? '__fello';
  final filePath = params['path'] ?? '__jello';
  
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

  // print("wow");

  if (fileData == null) {
    return Response(statusCode: HttpStatus.badRequest, body: 'No file provided');
  }

  final fileBytes = await fileData.readAsBytes();
  await File('./assets/temp101').writeAsBytes(fileBytes);

  final decryptedBytes = rsaDecrypt(File('./assets/temp101').readAsStringSync(),null,privatekey!);
  // print(File('./assets/temp101').readAsStringSync());
  // print(decryptedBytes);

  await getFile('./assets/$username/$filePath');

  final file = File('./assets/$username/$filePath');

  if (!file.existsSync()) {
    await file.create(recursive: true); // Ensure directories are created
    // await file.writeAsBytes(fileBytes);
  }
  await file.writeAsString(decryptedBytes);

  return Response(body: filePath.split('/').last);
}

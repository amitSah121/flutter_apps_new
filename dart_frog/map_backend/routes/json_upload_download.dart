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
    HttpMethod.get => getJsonFile(context),
    HttpMethod.post => postJsonFile(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> getJsonFile(RequestContext context) async {
  final request = context.request;
  final params = request.uri.queryParameters;

  final db = Db(uri);
  await db.open();
  final coll = db.collection('user');

  final username = params['username'] ?? '__hello';
  final password = params['password'] ?? '__fello';
  final jsonPath = params['path'] ?? '__jello';
  
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

  if (jsonPath != '__jello') {
    final file = File('./assets/$username/$jsonPath');
    if (!await file.exists()) {
      return Response(
          statusCode: HttpStatus.notFound, body: 'JSON file not found');
    }

    final filedata = await file.readAsString();
    // print(filedata);
    File('./assets/temp101').writeAsStringSync(rsaEncrypt(filedata, publickey!, null));

    final jsonContent = File('./assets/temp101').readAsStringSync();
    return Response(
      body: jsonContent,
    );
  }

  return Response(body: 'invalid');
}

Future<Response> postJsonFile(RequestContext context) async {
  final request = context.request;
  final formData = await request.formData();
  // print("hello");

  final jsonFile = formData.files['json'];
  // print(jsonFile);

  final params = request.uri.queryParameters;
  // print(params);

  final db = Db(uri);
  await db.open();
  final coll = db.collection('user');

  final username = params['username'] ?? '__hello';
  final password = params['password'] ?? '__fello';
  final jsonPath = params['path'] ?? '__jello';
  
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


  if (jsonFile == null) {
    return Response(statusCode: HttpStatus.badRequest, body: 'Invalid JSON file');
  }

  final jsonBytes = await jsonFile.readAsBytes();

  await File('./assets/temp101').writeAsBytes(jsonBytes);

  final decryptedBytes = rsaDecrypt(File('./assets/temp101').readAsStringSync(),null,privatekey!);
  // final hash = md5.convert(jsonBytes);
  await getFile('./assets/$username/$jsonPath');

  final file = File('./assets/$username/$jsonPath');

  if (!file.existsSync()) {
    await file.create(recursive: true); // Ensure directories are created
    
  }
  await file.writeAsString(decryptedBytes);

  return Response(body: jsonPath.split('/').last);
}

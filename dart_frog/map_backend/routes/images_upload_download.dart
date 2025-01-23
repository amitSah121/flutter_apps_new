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
    HttpMethod.get => getImage(context),
    HttpMethod.post => postImage(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed))
  };
}


Future<Response> getImage(RequestContext context) async{
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

  if(filePath != '__jello'){
    final file = File('./assets/$username/$filePath');
    if (!file.existsSync()) {
      return Response(statusCode: HttpStatus.notFound, body: 'Image not found');
    }

    final imageBytes = await file.readAsBytes();

    return Response.bytes(
    body: imageBytes,
    headers: {'Content-Type': 'image/${filePath.split("/").last.split(".").last}'}, // Adjust content type based on image format
  );

  }


  return Response(body: 'invalid');
}


Future<Response> postImage(RequestContext context) async {
  final request = context.request;
  final formData = await request.formData();

  final photo = formData.files['photo'];

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


  if (photo == null) {
    return Response(statusCode: HttpStatus.badRequest);
  }

  final imageBytes = await photo.readAsBytes();
  // final hash = md5.convert(imageBytes);
  await getFile('./assets/$username/$filePath');

  final file = File('./assets/$username/$filePath');

  // if (!file.existsSync()) {
    await file.writeAsBytes(imageBytes);
  // }  

  return Response(body: filePath.split('/').last);
}
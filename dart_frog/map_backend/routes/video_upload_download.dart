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
    HttpMethod.get => getVideo(context),
    HttpMethod.post => postVideo(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed))
  };
}

Future<Response> getVideo(RequestContext context) async {
  final request = context.request;
  final params = request.uri.queryParameters;

  final db = Db(uri);
  await db.open();
  final coll = db.collection('user');

  final username = params['username'] ?? '__hello';
  final password = params['password'] ?? '__fello';
  final videoPath = params['path'] ?? '__jello';

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

  if (videoPath != '__jello') {
    final file = File('./assets/$username/$videoPath');
    if (!file.existsSync()) {
      return Response(
          statusCode: HttpStatus.notFound, body: 'Video not found');
    }

    final videoBytes = await file.readAsBytes();

    return Response.bytes(
      body: videoBytes,
      headers: {
        'Content-Type':
            'video/${videoPath.split("/").last.split(".").last}' // Adjust content type based on video format
      },
    );
  }

  return Response(body: 'invalid');
}

Future<Response> postVideo(RequestContext context) async {
  final request = context.request;
  final formData = await request.formData();

  final video = formData.files['video'];

  final params = request.uri.queryParameters;

  final db = Db(uri);
  await db.open();
  final coll = db.collection('user');

  final username = params['username'] ?? '__hello';
  final password = params['password'] ?? '__fello';
  final videoPath = params['path'] ?? '__jello';

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

  if (video == null) {
    return Response(statusCode: HttpStatus.badRequest);
  }

  final videoBytes = await video.readAsBytes();
  // final hash = md5.convert(videoBytes);
  await getFile('./assets/$username/$videoPath');

  final file = File('./assets/$username/$videoPath');

  if (!file.existsSync()) {
    await file.create(recursive: true); // Ensure directories are created
    // await file.writeAsBytes(videoBytes);
  }
  await file.writeAsBytes(videoBytes);

  return Response(body: videoPath.split('/').last);
}

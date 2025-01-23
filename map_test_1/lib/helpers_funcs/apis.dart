
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:map_test_1/constants/constants.dart';
import 'package:map_test_1/helpers_funcs/file_funcs.dart';
import 'package:map_test_1/helpers_funcs/helper.dart';
import 'package:pointycastle/asymmetric/api.dart';


Future<String> getDataReg(username, password) async {
  try {
    var url_temp = Uri.parse(getAuthKeyUrl);
    var response1 = await http.get(url_temp);
    var publicKey;
    if (response1.statusCode == 200) {
      final data = jsonDecode(response1.body);
      final modulus = BigInt.parse(data['modulus'] as String);
      final exponent = BigInt.parse(data['exponent'] as String);
      publicKey = RSAPublicKey(modulus, exponent);
    }
    var newpass = rsaEncrypt(password, publicKey, null);

    var topass = {'username':username,'password':Uri.encodeQueryComponent(newpass)};
    var url = Uri.parse(registerUrl);
    // print(url);
    var response = await http.post(
      url,
      headers: <String, String>{
        'content-type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(topass)
    );
    // print("kk");
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    return 'invalid';
  }
}


Future<String> getData(username, password) async {
  try {
    // var newpass = sha256.convert(utf8.encode(password.toString()));
    
    var url_temp = Uri.parse(getAuthKeyUrl);
    var response1 = await http.get(url_temp);
    var publicKey;
    if (response1.statusCode == 200) {
      final data = jsonDecode(response1.body);
      final modulus = BigInt.parse(data['modulus'] as String);
      final exponent = BigInt.parse(data['exponent'] as String);
      publicKey = RSAPublicKey(modulus, exponent);
    }

    var newpass = rsaEncrypt(password, publicKey, null);

    var url = Uri.parse(getAuthConstant(username, Uri.encodeQueryComponent(newpass)));
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // print(newpass);
      // print(response.body);
      return response.body;
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    return 'invalid';
  }
}

Future<String> getMyFiles(username, password) async {
  try {
    
    var url_temp = Uri.parse(getAuthKeyUrl);
    var response1 = await http.get(url_temp);
    var publicKey;
    if (response1.statusCode == 200) {
      final data = jsonDecode(response1.body);
      final modulus = BigInt.parse(data['modulus'] as String);
      final exponent = BigInt.parse(data['exponent'] as String);
      publicKey = RSAPublicKey(modulus, exponent);
    }

    var newpass = rsaEncrypt(password, publicKey, null);
    var url = Uri.parse(getMyFilesConstant(username, Uri.encodeQueryComponent(newpass)));
    var response = await http.get(url);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    return 'invalid';
  }
}

Future<String> getImageFile(username, password, path) async {
  try {
    var url_temp = Uri.parse(getAuthKeyUrl);
    var response1 = await http.get(url_temp);
    var publicKey;
    if (response1.statusCode == 200) {
      final data = jsonDecode(response1.body);
      final modulus = BigInt.parse(data['modulus'] as String);
      final exponent = BigInt.parse(data['exponent'] as String);
      publicKey = RSAPublicKey(modulus, exponent);
    }

    var newpass = rsaEncrypt(password, publicKey, null);
    var url = Uri.parse(getMyImageConstant(username, Uri.encodeQueryComponent(newpass),path));
    var response = await http.get(url);
    if (response.statusCode == 200) {
      File file = await getFile(path);
      // print(file);
      await file.writeAsBytes(response.bodyBytes);
      return "success";
    } else {
      // throw Exception('Failed to load data');
      return "invalid";
    }
  } catch (e) {
    return 'invalid';
  }
}

Future<String> getVideoFile(username, password, path) async {
  try {
    var url_temp = Uri.parse(getAuthKeyUrl);
    var response1 = await http.get(url_temp);
    var publicKey;
    if (response1.statusCode == 200) {
      final data = jsonDecode(response1.body);
      final modulus = BigInt.parse(data['modulus'] as String);
      final exponent = BigInt.parse(data['exponent'] as String);
      publicKey = RSAPublicKey(modulus, exponent);
    }

    var newpass = rsaEncrypt(password, publicKey, null);
    var url = Uri.parse(getMyVideoConstant(username, Uri.encodeQueryComponent(newpass),path));
    var response = await http.get(url);
    if (response.statusCode == 200) {
      File file = await getFile(path);
      // print(file);
      await file.writeAsBytes(response.bodyBytes);
      return "success";
    } else {
      // throw Exception('Failed to load data');
      return "invalid";
    }
  } catch (e) {
    return 'invalid';
  }
}

Future<String> getJsonFile(username, password, path) async {
  try {

    final keyPair = generateRSAKeyPair();
    var publickey = keyPair.publicKey;
    var privatekey = keyPair.privateKey;

    // print({publickey.modulus.toString(),publickey.exponent.toString()});

    var url1 = Uri.parse('$setKeyUrl?modulus=${publickey.modulus.toString()}&exponent=${publickey.exponent.toString()}');
    var response1 = await http.get(url1);
    if (response1.statusCode == 200) {
      // print(response1.body);
      if(!(response1.body == "success")){
        throw "wrong params";
      }
    }

    var url_temp = Uri.parse(getAuthKeyUrl);
    var response2 = await http.get(url_temp);
    var publicKey1;
    if (response2.statusCode == 200) {
      final data = jsonDecode(response2.body);
      final modulus = BigInt.parse(data['modulus'] as String);
      final exponent = BigInt.parse(data['exponent'] as String);
      publicKey1 = RSAPublicKey(modulus, exponent);
    }

    var newpass = rsaEncrypt(password, publicKey1, null);
    var url = Uri.parse(getMyJsonConstant(username, Uri.encodeQueryComponent(newpass),path));
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // print(file);
      var data = rsaDecrypt(response.body, null, privatekey);
      await writeFile(path,data);
      return "success";
    } else {
      // throw Exception('Failed to load data');
      return "invalid";
    }
  } catch (e) {
    return 'invalid';
  }
}

Future<String> getAnyOtherFile(username, password, path) async {
  try {
    final keyPair = generateRSAKeyPair();
    var publickey = keyPair.publicKey;
    var privatekey = keyPair.privateKey;

    // print({publickey.modulus.toString(),publickey.exponent.toString()});

    var url1 = Uri.parse('$setKeyUrl?modulus=${publickey.modulus.toString()}&exponent=${publickey.exponent.toString()}');
    var response1 = await http.get(url1);
    if (response1.statusCode == 200) {
      // print(response1.body);
      if(!(response1.body == "success")){
        throw "wrong params";
      }
    }


    var url_temp = Uri.parse(getAuthKeyUrl);
    var response2 = await http.get(url_temp);
    var publicKey1;
    if (response2.statusCode == 200) {
      final data = jsonDecode(response2.body);
      final modulus = BigInt.parse(data['modulus'] as String);
      final exponent = BigInt.parse(data['exponent'] as String);
      publicKey1 = RSAPublicKey(modulus, exponent);
    }

    var newpass = rsaEncrypt(password, publicKey1, null);
    var url = Uri.parse(getMyAnyOtherFileConstant(username, Uri.encodeQueryComponent(newpass),path));
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // print(file);
      var data = rsaDecrypt(response.body, null, privatekey);
      // print({"hello",data});
      await writeFile(path,data);
      return "success";
    } else {
      // throw Exception('Failed to load data');
      return "invalid";
    }
  } catch (e) {
    return 'invalid';
  }
}


// setting path

Future<String> setImageFile(username, password, path) async {
  try {
    var url_temp = Uri.parse(getAuthKeyUrl);
    var response2 = await http.get(url_temp);
    var publicKey1;
    if (response2.statusCode == 200) {
      final data = jsonDecode(response2.body);
      final modulus = BigInt.parse(data['modulus'] as String);
      final exponent = BigInt.parse(data['exponent'] as String);
      publicKey1 = RSAPublicKey(modulus, exponent);
    }

    var newpass = rsaEncrypt(password, publicKey1, null);
    var url = Uri.parse(getMyImageConstant(username, Uri.encodeQueryComponent(newpass),path));
    
    var request = http.MultipartRequest('POST', url)
      ..files.add(
        await http.MultipartFile.fromPath(
          'photo', // form field name expected by the server
          (await getFile(path)).path.toString(),
        ),
      );

    var response = await request.send();

    if (response.statusCode == 200) {
      return await response.stream.bytesToString();
    } else {
      // print('File upload failed with status: ${response.statusCode}');
      return 'invalid';
    }
  } catch (e) {
    return 'invalid';
  }
}


Future<String> setVideoFile(username, password, path) async {
  try {
    var url_temp = Uri.parse(getAuthKeyUrl);
    var response2 = await http.get(url_temp);
    var publicKey1;
    if (response2.statusCode == 200) {
      final data = jsonDecode(response2.body);
      final modulus = BigInt.parse(data['modulus'] as String);
      final exponent = BigInt.parse(data['exponent'] as String);
      publicKey1 = RSAPublicKey(modulus, exponent);
    }

    var newpass = rsaEncrypt(password, publicKey1, null);
    var url = Uri.parse(getMyVideoConstant(username, Uri.encodeQueryComponent(newpass),path));
    
    var request = http.MultipartRequest('POST', url)
      ..files.add(
        await http.MultipartFile.fromPath(
          'video', // form field name expected by the server
          (await getFile(path)).path.toString(),
        ),
      );

    var response = await request.send();

    if (response.statusCode == 200) {
      return await response.stream.bytesToString();
    } else {
      // print('File upload failed with status: ${response.statusCode}');
      return 'invalid';
    }
  } catch (e) {
    return 'invalid';
  }
}

Future<String> setJsonFile(username, password, path) async {
  try {
    var url_temp = Uri.parse(getKeyUrl);
    var response1 = await http.get(url_temp);
    var publicKey;
    if (response1.statusCode == 200) {
      final data = jsonDecode(response1.body);
      final modulus = BigInt.parse(data['modulus'] as String);
      final exponent = BigInt.parse(data['exponent'] as String);
      publicKey = RSAPublicKey(modulus, exponent);
    }

    var url_temp1 = Uri.parse(getAuthKeyUrl);
    var response2 = await http.get(url_temp1);
    var publicKey1;
    if (response2.statusCode == 200) {
      final data = jsonDecode(response2.body);
      final modulus = BigInt.parse(data['modulus'] as String);
      final exponent = BigInt.parse(data['exponent'] as String);
      publicKey1 = RSAPublicKey(modulus, exponent);
    }

    var newpass = rsaEncrypt(password, publicKey1, null);

    File("${await localPath}/temp101").writeAsStringSync(rsaEncrypt((await readFile(path)), publicKey, null));

    var url = Uri.parse(getMyJsonConstant(username, Uri.encodeQueryComponent(newpass),path));
    var request = http.MultipartRequest('POST', url)
      ..files.add(
        await http.MultipartFile.fromPath(
          'json', // form field name expected by the server
          "${await localPath}/temp101",
        ),
      );

    var response = await request.send();

    if (response.statusCode == 200) {
      await response.stream.bytesToString();
      (await deleteFile("temp101"));
      return "success";
    } else {
      // print('File upload failed with status: ${response.statusCode}');
      return 'invalid';
    }
  } catch (e) {
    return 'invalid';
  }
}

Future<String> setAnyOtherFile(username, password, path) async {
  try {
    var url_temp = Uri.parse(getKeyUrl);
    var response1 = await http.get(url_temp);
    var publicKey;
    if (response1.statusCode == 200) {
      final data = jsonDecode(response1.body);
      final modulus = BigInt.parse(data['modulus'] as String);
      final exponent = BigInt.parse(data['exponent'] as String);
      publicKey = RSAPublicKey(modulus, exponent);
    }


    var url_temp1 = Uri.parse(getAuthKeyUrl);
    var response2 = await http.get(url_temp1);
    var publicKey1;
    if (response2.statusCode == 200) {
      final data = jsonDecode(response2.body);
      final modulus = BigInt.parse(data['modulus'] as String);
      final exponent = BigInt.parse(data['exponent'] as String);
      publicKey1 = RSAPublicKey(modulus, exponent);
    }

    var newpass = rsaEncrypt(password, publicKey1, null);
    
    
    File("${await localPath}/temp101").writeAsStringSync(rsaEncrypt((await readFile(path)), publicKey, null));

    var url = Uri.parse(getMyAnyOtherFileConstant(username, Uri.encodeQueryComponent(newpass),path));
    // print("hello");

    // print(url);
    var request = http.MultipartRequest('POST', url)
      ..files.add(
        await http.MultipartFile.fromPath(
          'file', // form field name expected by the server
          "${await localPath}/temp101",
          //  contentType: MediaType('application', 'octet-stream'),
        ),
      );
      // print("hello");

    var response = await request.send();

    if (response.statusCode == 200) {
      await response.stream.bytesToString();
      (await deleteFile("temp101"));
      return "success";
    } else {
      // print('File upload failed with status: ${response.statusCode}');
      return 'invalid';
    }
  } catch (e) {
    // print(e);
    return 'invalid';
  }
}
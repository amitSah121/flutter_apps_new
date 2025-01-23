import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' show Encrypted, Encrypter, RSA;
import 'package:pointycastle/export.dart';


SecureRandom _secureRandom() {
  final secureRandom = FortunaRandom();

  // Seed the random number generator
  final seedSource = Random.secure();
  final seeds = List<int>.generate(32, (_) => seedSource.nextInt(255));
  secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

  return secureRandom;
}


AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAKeyPair() {
  final keyGen = RSAKeyGenerator();
  final keyParams = RSAKeyGeneratorParameters(
      BigInt.parse('65537'), 2048, 64); // Exponent, bit size, and certainty
  keyGen.init(ParametersWithRandom(keyParams, _secureRandom()));
  
  // Generate the key pair and explicitly cast it to RSAPublicKey and RSAPrivateKey
  final pair = keyGen.generateKeyPair();
  final publicKey = pair.publicKey as RSAPublicKey;
  final privateKey = pair.privateKey as RSAPrivateKey;

  return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(publicKey, privateKey);
}


String rsaEncrypt(String data, RSAPublicKey publicKey, RSAPrivateKey? privateKey) {
  final encrypter = Encrypter(RSA(publicKey: publicKey, privateKey: privateKey));
  final result = <String>[];
  if(data.length > 24){
    final nums = data.length ~/ 24;
    for(var i=0 ; i< nums; i++){
      // print(nums);
      result.add(encrypter.encrypt(data.substring(i*24,(i+1)*24)).base64);
    }  
    if(data.length > nums*24){
      result.add(encrypter.encrypt(data.substring(nums*24, data.length)).base64);
    }
  }else{
    return encrypter.encrypt(data).base64;
  }
  return result.join('--');
}

String rsaDecrypt(String encryptedData, RSAPublicKey? publicKey, RSAPrivateKey privateKey) {
  // final encrypter = Encrypter(RSA(publicKey: publicKey, privateKey: privateKey));
  final message = encryptedData.split('--');
  final temp_1 = <String>[];
  for(var i=0 ; i<message.length ; i++){
    try{
      temp_1.add(_rsaDecrypt(message[i], null, privateKey));
    }catch (e){
    }
  }
  // print(message);

  return temp_1.join();
}



String _rsaDecrypt(String encryptedData, RSAPublicKey? publicKey, RSAPrivateKey privateKey) {
  final encrypter = Encrypter(RSA(publicKey: publicKey, privateKey: privateKey));

  return encrypter.decrypt(Encrypted(base64.decode(encryptedData)));
}


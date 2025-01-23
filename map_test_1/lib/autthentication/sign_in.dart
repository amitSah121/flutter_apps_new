import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:map_test_1/constants/constants.dart';
import 'package:map_test_1/helpers_funcs/apis.dart';
import 'package:map_test_1/helpers_funcs/file_funcs.dart';
import 'package:map_test_1/provider/provider.dart';
import 'package:provider/provider.dart';



class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  
  @override
  void initState() {
    super.initState();

    Future.microtask(()async{
      if(!File("userpref").existsSync()){
        await getFile("userpref");
      }
      var p = await readFile("userpref");
      // print(p);
      if(p.isNotEmpty){
        var temp = p.split("=");
        final val = await getData(temp[0], temp[1]);
        // print(val);
        if(val == "invalid") return;
        final myModel = Provider.of<CustomProvider>(context, listen: false);
        await myModel.set_auth(temp[0], temp[1]);

        var upF = await (File("${await localPath}/updatedFilesInfo")).readAsLines();
        // print(upF);

        // if(myModel.username.isEmpty) return;
        if(upF.isNotEmpty){
          var temp1 = await File('${await localPath}/updatedFilesInfo').readAsString();
          // var isAvail = false;
          var temp2 = temp1.split("\n");
          var p = [];
          for(var t1 in temp2){
            // print({t1,fileName});
            if(t1 == "updatedFilesInfo"){
              p.add("updatedFilesInfo");
              break;
            }
          }
          for(var t1 in temp2){
            // print({t1,fileName});
            if(t1 == "userpref"){
              p.add("userpref");
              break;
            }
          }
          for(var t1 in temp2){
            // print({t1,fileName});
            if(t1 == "temp101"){
              p.add("temp101");
              break;
            }
          }
          for(var q in p){
            temp2.remove(q);
          }
          File('${await localPath}/updatedFilesInfo').writeAsStringSync(temp2.join('\n')) ;
          // print(temp2.join('\n'));

          temp1 = await File('${await localPath}/allFilesClient').readAsString();
          var temp3 = temp1.split("\n");
          p = [];
          for(var t1 in temp3){
            // print({t1,fileName});
            if(t1 == "updatedFilesInfo"){
              p.add("updatedFilesInfo");
              break;
            }
          }
          for(var t1 in temp3){
            // print({t1,fileName});
            if(t1 == "userpref"){
              p.add("userpref");
              break;
            }
          }
          for(var t1 in temp3){
            // print({t1,fileName});
            if(t1 == "temp101"){
              p.add("temp101");
              break;
            }
          }
          for(var q in p){
            temp3.remove(q);
          }
          File('${await localPath}/allFilesClient').writeAsStringSync(temp3.join("\n")) ;
          

          List<String> temp = [myModel.username,myModel.password];
          // print(temp);
          if(temp[0].isEmpty) return;
          p = [];
          for(var path in temp2){
            if(path.isEmpty) continue;
            var filename = path.split("/").last;
            // print(filename);
            if(filename.endsWith("png") || filename.endsWith("jpg") || filename.endsWith("jpeg") || filename.endsWith("webp") || filename.endsWith("gif") || filename.endsWith("bmp")){
              var q = await setImageFile(temp[0], temp[1], path);
              if(q == 'invalid') continue;
              p.add(path);
              // print(err);
            }else if(filename.endsWith("mp4") || filename.endsWith("webm") || filename.endsWith("mkv")){
              var q = await setVideoFile(temp[0], temp[1], path);
              if(q == 'invalid') continue;
              p.add(path);
            }else if(filename.endsWith("json")){
              // print("hhh");
              var q = await setJsonFile(temp[0], temp[1], path);
              if(q == 'invalid') continue;
              p.add(path);
            }else{
              var q = await setAnyOtherFile(temp[0], temp[1], path);
              if(q == 'invalid') continue;
              p.add(path);
              // print(err);
            }
          }
          for(var q in p){
            temp2.remove(q);
          }
          File('${await localPath}/updatedFilesInfo').writeAsStringSync(temp2.join('\n')) ;
        }


        Navigator.pushNamed(context, "/home");
      }
    });
  }

  // Future<>

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(context),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32,),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: username,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        } else if (value.length < 3) {
                          return 'Name must be at least 3 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8,),
                    TextFormField(
                      controller: password,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,  // Hides the text
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try{
                            final val = await getData(username.text, password.text);
                          // use the object id provided by val
                          // print(val);
                            if(val != "invalid"){
                              // print("skksk");
                              Future.microtask(() async{
                                final myModel = Provider.of<CustomProvider>(context, listen: false);
                                await myModel.set_auth(username.text, password.text);
                                // print("kk");
                                await getFile("userpref");
                                // print("ll");
                                await writeFile("userpref", "${username.text}=${password.text}");

                                
                                var temp = [username.text,password.text];
                                print(temp);

                                Map<String,dynamic> q1 = jsonDecode(await getMyFiles(temp[0], temp[1]));
                                if(q1.containsKey("error")){
                                  print(q1["error"]);
                                }else if(q1.containsKey("files")){
                                  // print(q1.files);
                                  if(q1["files"] == null) return;
                                  var q11 = q1["files"];
                                  for(String path in q11!){
                                    // to get and update files
                                    var filename = path.split("/").last;
                                    if(filename.endsWith("png") || filename.endsWith("jpg") || filename.endsWith("jpeg") || filename.endsWith("webp") || filename.endsWith("gif") || filename.endsWith("bmp")){
                                      await getImageFile(temp[0], temp[1], path);
                                    }else if(filename.endsWith("mp4") || filename.endsWith("webm") || filename.endsWith("mkv")){
                                      await getVideoFile(temp[0], temp[1], path);
                                    }else if(filename.endsWith("json")){
                                      await getJsonFile(temp[0], temp[1], path);
                                    }else{
                                      await getAnyOtherFile(temp[0], temp[1], path);
                                    }
                                  }
                                }
                                Navigator.pushNamed(context, "/home");
                              });
                            }
                          }catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text("Incorrect Username or password")));
                            print(e);
                          }
                            
                        }
                      },
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 64,),
                    Row(
                      children: [
                        const Text("Not registered yet!",
                        style: TextStyle(fontSize: 16),),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text(
                            "Click Here",
                            style: TextStyle(color: Colors.blue, fontSize: 16)
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32,)
          ],
        ),
      ),
    );
  }

  AppBar appBarWidget(BuildContext context) {
    return AppBar(
      title: const Text(appname),
    );
  }
}

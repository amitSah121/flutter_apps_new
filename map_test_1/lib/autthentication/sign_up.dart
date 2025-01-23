import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:map_test_1/constants/constants.dart';
import 'package:map_test_1/helpers_funcs/apis.dart';
import 'package:map_test_1/helpers_funcs/file_funcs.dart';
import 'package:map_test_1/provider/provider.dart';
import 'package:provider/provider.dart';



class Register extends StatefulWidget{
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register>{

  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirm_password = TextEditingController();


  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext content){
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
                    const SizedBox(height: 8,),
                    TextFormField(
                      controller: confirm_password,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,  // Hides the text
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }else if(value != password.text){
                          return 'Password and confirm password do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Form Submitted')));
                          try{
                            final val = await getDataReg(username.text, password.text);
                          // use the object id provided by val
                            // print(val);
                            if(val == "invalid") {
                              throw Exception("invalid");
                            }
                            Future.microtask(()async{
                              final myModel = Provider.of<CustomProvider>(context, listen: false);
                              await myModel.set_auth(username.text, password.text);
                              await getFile("userpref");
                              await writeFile("userpref", "${username.text}=${password.text}");
                              Navigator.pushNamed(context, "/signin");
                            });
                          }catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text("Incorrect Username or password")));
                            // print(e);
                          }
                            
                        }
                      },
                      child: const Text('Register'),
                    ),
                    const SizedBox(height: 64,),
                    Row(
                      children: [
                        const Text("Already signed up!",
                        style: TextStyle(fontSize: 16),),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signin');
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
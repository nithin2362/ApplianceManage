// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'main.dart';

class Pwd extends StatefulWidget {
  const Pwd({ Key? key }) : super(key: key);

  @override
  State<Pwd> createState() => _PwdState();
}

class _PwdState extends State<Pwd> {
  @override
  final _formKey = GlobalKey<FormState>();
  String userName = '',pwd = '',cpwd = '',security = '';
  final dBr = FirebaseDatabase.instance.ref();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Change Password",style: TextStyle(color: Colors.white,fontSize: 20))),
        backgroundColor: Color(0xFF163057),
      ),
      backgroundColor:Color.fromARGB(255, 14, 39, 62),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           Text("Enter username",style: TextStyle(color: Colors.white,fontSize: 20)),
            
          Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration:BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(255, 33, 72, 131),
                ),
          
                child: TextFormField(
                cursorColor: Colors.white,
                style: TextStyle(color: Colors.white,fontSize: 15),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid username !';
                  }
                  else
                  {
                    userName = value.toString();
                  }
                  return null;
                },
               )),
        ),
        Text("Enter new password",style: TextStyle(color: Colors.white,fontSize: 20)),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration:BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color.fromARGB(255, 33, 72, 131),
                    ),
                        
                    child: TextFormField(
                    controller: TextEditingController(),
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white,fontSize: 15),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid password !';
                      }
                      else if(value.length < 4)
                      {
                        return 'Password must be atleast 4 characters long !!';
                      }
                      else
                      {
                        pwd = value.toString();
                      }
                      return null;
                    },
                    onSaved: (value) => pwd = value.toString(),
                    obscureText: true,
                   ))),
              
                   Text("Confirm new password",style: TextStyle(color: Colors.white,fontSize: 20)),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration:BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:Color.fromARGB(255, 33, 72, 131),
                    ),
                        
                    child: TextFormField(
                    controller: TextEditingController(),
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white,fontSize: 15),
                    validator: (value) {
                      if (!(pwd == value)) {
                        return 'Please enter the same password';
                      }
                      return null;
                    },
                    obscureText: true,
                   ))),
                   Text("Enter your favourite sport/color",style: TextStyle(color: Colors.white,fontSize: 20)),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration:BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:Color.fromARGB(255, 33, 72, 131),
                    ),
                        
                    child: TextFormField(
                    controller: TextEditingController(),
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white,fontSize: 15),
                    validator: (value){
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid Sport !';
                      }
                      else
                      {
                        security = value.toString();
                      }
                      return null;
                    },
                   ))),
           ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                      var temp = await sharedPreferences.getString(userName) ?? "Blue";
                      if(temp == security)
                      {
                        await dBr.child("Users/${userName}/Credentials").update({"Password":pwd.toString()});
                        ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Password changed !!!')));
                        setState((){});
                        Navigator.pop(context);
                      }
                      else
                      {
                        ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Incorrect details !!!')));
                      }
                    }
                  },
                  child: Text("Change ",style: TextStyle(fontSize: 20)),
                  ),
              ],
            ),
          ),
    );
  }
}
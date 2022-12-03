import 'dart:math';

import 'package:appliance/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'wait.dart';
class Signup extends StatefulWidget {
  String username;
  Signup(this.username);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final dBr = FirebaseDatabase.instance.ref();

  List users = [],ids = [];
  var data;
  void getIds(var list) async
  {
    list.forEach((user) => ids.add(user["Flags"]["Id"]));
  }
  Future<void> getUsers(var dBr) async
  {
    final snapshot = await dBr.child("Users").get();
    if(snapshot.exists)
    {
      data = snapshot.value;
      users = data.keys.toList();
      var vals = data.values.toList();
      getIds(vals);
    }
  prefs = await SharedPreferences.getInstance();
  }

var prefs;
List<TextEditingController> controllers = [TextEditingController(),TextEditingController(),TextEditingController(),TextEditingController()];
  TextEditingController tc1 = new TextEditingController();
  bool isChecked = false;
  String password = '',security = "cricket";

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        showDialog(
                context: context, 
                builder: (context) => AlertDialog(
                backgroundColor: Color.fromARGB(255, 33, 72, 131), 
                title: Text("Exit", style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold),),
                content: Text("Are you sure you want to Exit ?",style: TextStyle(color: Colors.white,fontSize: 15),),
                actions: [
                  ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("No",style: TextStyle(color: Colors.white,fontSize: 15),)),
                  TextButton(onPressed: (){
                    SystemNavigator.pop();
                  }, child: Text("Yes",style: TextStyle(color: Colors.blue,fontSize: 15),)),
                ],
              ));
              return false;
      },
      child: FutureBuilder(
        future: getUsers(dBr),
        builder: ((context, snapshot) {
          if(snapshot.connectionState == ConnectionState.done)
          {
            return Scaffold(
              appBar: AppBar(title: Center(child: Text("Sign Up",style: TextStyle(color: Colors.white,fontSize: 20.0,fontWeight: FontWeight.bold),)),
              backgroundColor: Color(0xFF163057),
              ),
              backgroundColor: Color(0xFF163057),
              body: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text("Enter a Username",style: TextStyle(color: Colors.white,fontSize: 20)),
                Padding(
                  padding: const EdgeInsets.only(left:10.0,right: 10.0),
                  child: Container(
                    decoration:BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color.fromARGB(255, 33, 72, 131),
                    ),
                        
                    child: TextFormField(
                    controller: controllers[2],
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white,fontSize: 15),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid Username !';
                      }
                      else if(users.contains(value))
                      {
                        return 'Please enter some other username !';
                      }
                      else if(value.contains(" "))
                      {
                        return 'Username should not contain spaces !';
                      }
                      else
                      {
                        widget.username = value.toString();
                      }
                      return null;
                    },
                    onSaved: (value) => widget.username = value.toString(),
                   ))),
              
                   Text("Enter a Password",style: TextStyle(color: Colors.white,fontSize: 20)),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration:BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color.fromARGB(255, 33, 72, 131),
                    ),
                        
                    child: TextFormField(
                    controller: controllers[0],
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
                        password = value.toString();
                      }
                      return null;
                    },
                    onSaved: (value) => password = value.toString(),
                    obscureText: true,
                   ))),
              
                   Text("Confirm Password",style: TextStyle(color: Colors.white,fontSize: 20)),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration:BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:Color.fromARGB(255, 33, 72, 131),
                    ),
                        
                    child: TextFormField(
                    controller: controllers[1],
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white,fontSize: 15),
                    validator: (value) {
                      if (!(password == value)) {
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
                    controller: tc1,
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
                   Padding(
                       padding: EdgeInsets.only(left: 60),
                       child: Row(
                        children: [
                          Checkbox(
                            checkColor: Colors.white,
                            activeColor: Colors.blue,
                            value: isChecked,
                            onChanged: (bool? value) async{
                              setState(() {
                                isChecked = value!;
                              });
                              
                              }),
                              Text("Keep me signed in",style: TextStyle(color: Colors.white,fontSize: 20),),
                        ],
                       ),
                     ),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       ElevatedButton(
                          
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Signed up successfully !')));
                              dBr.child("Users/${widget.username}/Credentials").set({"Username":widget.username,"Password":password});
                              var id1 = Random().nextInt(1000);
                              while(ids.contains(id1))
                              {
                                id1 = Random().nextInt(1000);
                              }
                              SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                              await sharedPreferences.setString(widget.username,security);
                              dBr.child("Users/${widget.username}/Flags").set({"Person_count":1,"forceStop":0,"Id":id1});
                              print("Username: ${widget.username}");
                              print("Password: $password");
                              prefs.setString("Username",widget.username);
                              prefs.setBool("Flag", isChecked);
                              Navigator.pushAndRemoveUntil(context,
                                MaterialPageRoute(builder: (context) => HomeScreen(widget.username)),(route)=> false);
                              setState((){});
                            }
                          },
                          child: Text("Register ",style: TextStyle(fontSize: 20)),
                          ),
                          Center(child: TextButton(onPressed: (){
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SignInScreen()),(route)=>false);
                      }, child: Text("Sign In",style: TextStyle(color: Colors.blue,fontSize: 20),))),
                     ],
                   ),
                      
                  ],
                ),
              ),
            );
          }
          else
          {
            return WaitScreen(false);
          }
      })),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:appliance/signup.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'wait.dart';
import 'main.dart';
import 'forgotpwd.dart';
class Signin extends StatefulWidget {
  const Signin({ Key? key }) : super(key: key);

  @override
  State<Signin> createState() => _SigninState();
}
var data;
final _formKey = GlobalKey<FormState>();
List<TextEditingController> controllers = [TextEditingController(),TextEditingController()];
String username='',password='';
List users = [];
bool isChecked = false;
var prefs;
Future<void> getAllData() async
{
  final dBr = FirebaseDatabase.instance.ref();
  var Snapshot = await dBr.child("Users").get();
  if(Snapshot.exists)
  {
    data = Snapshot.value;
    data.keys.toList().forEach((key) => users.add(key));
    
  }
  else
  {
    print("Data not found !");
  }
  prefs = await SharedPreferences.getInstance();
  
}

Map getUserinfo()
{
  Map info = {};
  data.keys.toList().forEach((key) => info[key.toString()] = data[key]["Credentials"]["Password"]);
  print(info);
  return info;
}

class _SigninState extends State<Signin> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) 
        {
          return Container(
            child: Text(
              "Found some error"
            ),
          );
        }
        else if(snapshot.connectionState == ConnectionState.done)
        {
          return SignInScreen();
        }
        else
          return WaitScreen(true);
      }
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({ Key? key }) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
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
        // Initialize FlutterFire
        future: getAllData(),
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) 
          {
            return Container(
              child: Text(
                "Unable to fetch data !!!"
              ),
            );
          }
          else if(snapshot.connectionState == ConnectionState.done)
          {
            return Scaffold(
              appBar: AppBar(title: Center(child: Text("Sign In",style: TextStyle(color: Colors.white,fontSize: 20.0,fontWeight: FontWeight.bold),)),backgroundColor: Color(0xFF163057),),
              backgroundColor: Color(0xFF163057),
              body: Form(
                key: _formKey,
                child: Center(
                  child: Column(
                    children: [
                      Text("Enter Username",style: TextStyle(color: Colors.white,fontSize: 20)),
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
                      style: TextStyle(color: Colors.white,fontSize: 20),
                      validator: (value) {
                        var d1 = data;
                        // print("D1: $d1");
                        // print("Users: $users");
                        if (value == null || value.isEmpty) {
                          return 'Enter a valid username';
                        }
                        else if(d1 != null && users.contains(value) == false)
                        {
                          return 'Invalid Username';
                        }
                        else{
                          username = value.toString();
                        }
                        return null;
                      },
                      onSaved: (value) => username = value.toString(),
                     ))),
              
                     Text("Enter Password",style: TextStyle(color: Colors.white,fontSize: 20)),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      decoration:BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromARGB(255, 33, 72, 131),
                      ),
                          
                      child: TextFormField(
                      controller: controllers[1],
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.white,fontSize: 20),
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
                    ElevatedButton(
                        onPressed: () {
                          if(_formKey.currentState == null)
                          {
                            print("Null");
                          }
                          else if (_formKey.currentState!.validate()) {
                            Map users1 = getUserinfo();
                            print("Users1: $users1");
                            print("Username: $username");
                            if(users1[username] == password)
                            {
                            
                              prefs.setString("Username",username);
                              prefs.setBool("Flag", isChecked);
                              ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Signed in successfully !')));
                              setState((){});
                              Navigator.pushAndRemoveUntil(context,
                              MaterialPageRoute(builder: (context) => HomeScreen(username)),(route)=> false);
                            }
                            else
                            {
                              ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Invalid User credentials !')));
                            }
                            
                          }
                        },
                        child: Text("Sign In ",style: TextStyle(fontSize: 20)),
                        ),
                        Center(child: TextButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Pwd()));
                      }, child: Text("Forgot your password ?",style: TextStyle(color: Colors.blue,fontSize: 20),))),
                      Center(child: Text("Don't have an account ?",style: TextStyle(color: Colors.white,fontSize: 20),)),
                      Center(child: TextButton(onPressed: (){
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Signup("")),(route)=>false);
                      }, child: Text("Sign Up",style: TextStyle(color: Colors.blue,fontSize: 20),))),
              
                    ],
                  ),
                ),
              ),
              );
          }
          else
            return WaitScreen(true);
      }),
    );
}
}
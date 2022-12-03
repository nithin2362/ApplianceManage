import 'package:appliance/device.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class Timer1 extends StatefulWidget {
  final String username,devicename;
  Timer1(this.username,this.devicename);

  @override
  State<Timer1> createState() => _Timer1State();
}
bool isDigit(String s) {
  if (s == null) {
    return false;
  }
  return int.tryParse(s) != null;
}
class _Timer1State extends State<Timer1> {
  @override
  final _formKey = GlobalKey<FormState>();
  TextEditingController _controller = TextEditingController();
  final items = ["Seconds","Minutes"];
  String type = '';
  int time = 0;
  final dBr = FirebaseDatabase.instance.ref();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Timer",style: TextStyle(color: Colors.white,fontSize: 20))),
        backgroundColor: Color(0xFF163057),
      ),
      backgroundColor:Color.fromARGB(255, 14, 39, 62),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           Text("Enter timer limit in seconds",style: TextStyle(color: Colors.white,fontSize: 20)),
            
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
                    return 'Please enter a valid timer limit !';
                  }
                  else if(!isDigit(value.toString()))
                  {
                    return 'Timer limit should be a number';
                  }
                  else if(int.parse(value) < 20)
                  {
                    return 'Timer limit should be atleast be 20 seconds';
                  }else
                  {
                    time = int.parse(value);
                  }
                  return null;
                },
               )),
        ),
           ElevatedButton(
                  
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Timer started !')));
                        print(time);
                      final snapp = await dBr.child("Users/${widget.username}/Devices/${widget.devicename}/updated_state").get();
                      var isON = snapp.value;
                      await dBr.child("Users/${widget.username}/Devices/${widget.devicename}").update({"Timer":DateTime.now().add(Duration(seconds: time)).toString()});
                      await dBr.child("Users/${widget.username}/Flags").update({"forceStop":-1});
                      if(isON == false)
                      {
                        await dBr.child("Users/${widget.username}/Devices/${widget.devicename}").update({"updated_state":true});  
                      }
                      setState((){});
                      Navigator.pop(context);
                      
                    }
                  },
                  child: Text("Set ",style: TextStyle(fontSize: 20)),
                  ),
           
           
           
           
           
           
            
            
              ],
            ),
          ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:appliance/device.dart';
import 'package:appliance/main.dart';
import 'wait.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
class DeviceAdd extends StatefulWidget {

  final String username;
  DeviceAdd(this.username);
  @override
  State<DeviceAdd> createState() => _DeviceAddState();
}
bool isDigit(String s) {
  if (s == null) {
    return false;
  }
  return int.tryParse(s) != null;
}
class _DeviceAddState extends State<DeviceAdd> {
  @override
  final _formKey = GlobalKey<FormState>();
  final dBr = FirebaseDatabase.instance.ref();
  String? value;
  String? dropval,ic;
  String deviceName = "",icon = "",rating='';
 
  final _controller = TextEditingController();
  final items = ["Light","Fan","TV","Other"];
  DropdownMenuItem<String> buildItem(String data)
  {
    return DropdownMenuItem(
      value: data,
      child: Text(
        data,
        style: TextStyle(fontSize: 15, color: Colors.white,fontWeight: FontWeight.bold),),
    );
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Add a device",style: TextStyle(color: Colors.white,fontSize: 20))),
        backgroundColor: Color(0xFF163057),
      ),
      backgroundColor:Color.fromARGB(255, 14, 39, 62),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Device Name",style: TextStyle(color: Colors.white,fontSize: 20)),
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
                controller: _controller,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid Device name !';
                  }
                  else
                  {
                    deviceName = value;
                  }
                  return null;
                },
               )),
        ),
            SizedBox(
              height: 30,
            ),
          Text("Device Type",style: TextStyle(color: Colors.white,fontSize: 20)),
          DropdownButton<String>(
          items: items.map(buildItem).toList(),
          dropdownColor: Color.fromARGB(255, 81, 113, 161),
          value: value,
           onChanged: (value) => setState(() => this.value = value),
            ),
            SizedBox(height: 10,),
            Text("Device Rating in kWh",style: TextStyle(color: Colors.white,fontSize: 20)),
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
                    return 'Please enter a valid Rating !';
                  }
                  else if(!isDigit(value.toString()))
                  {
                    return 'Rating should be a number';
                  }
                  else
                  {
                    rating = value;
                  }
                  return null;
                },
               )),
        ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 50,right: 50,top:20,bottom: 20),
                  child: ElevatedButton(
                  
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Device added !')));
                      //iconData = dropval;
                      var d2 = DateTime.parse(DateTime.now().toString());
                      if(this.value == "Light")
                        isBulb = 0;
                      else if(this.value == "Fan")
                        isBulb = 1;
                      else if(this.value == "TV")
                        isBulb = 2;
                      else if(this.value == "Other")
                        isBulb = 3;
                      dBr.child("Users/${widget.username}/Devices/${deviceName}").set({"updated_state":false,"Last Toggled":d2.toString(),"DeviceType":isBulb,"Rating":rating,"Hours":0,"Last Updated":DateTime.now().toString(),"Timer":"-1"});
                      setState((){});
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomeScreen(widget.username)), (route) => false);
                      
                    }
                  },
                  child: Text("Add ",style: TextStyle(fontSize: 20)),
                  ),
                ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                child: TextButton(onPressed: () =>Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomeScreen(widget.username)), (route) => false),
                         child: Text("Cancel",style: TextStyle(fontSize: 20,color: Colors.blue))),
              ),
              ],
            ),
          ]),
      ),
    );

  
  
  }
}

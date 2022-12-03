import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'package:appliance/addappl.dart';
import 'package:appliance/notification.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'timer.dart';
int getRandom()
{
  var r = Random();
  return r.nextInt(10000);
}
Color bulbcolor = Colors.white;
final dBr = FirebaseDatabase.instance.ref();
int isBulb = 0;
double iconsize = 70;
int timeDifference = 10;
bool isNotified = false;
late final LocalNotificationService service = LocalNotificationService();
String bulbtext = "Off",state = "",dtext = "Unavailable",diff = "";
DateTime d1 = DateTime.now(),d2 = DateTime.now();
int num = 0,forceStop = -3,personCount = -1,id = -1;
class Device extends StatefulWidget {
  final String username,path,dname;
  final IconData iconData;
  bool isOn;
  
  Future<void> notify(var ref) async
  {
    
    final snap1 = await ref.child("Users/${this.username}/Flags").get();
    final snap2 = await ref.child("Users/${this.username}/Devices/${this.dname}/Last Toggled").get();
    if(snap1.exists)
    {
      personCount = snap1.value["Person_count"];
      forceStop = snap1.value["forceStop"];
      id = snap1.value["Id"];
    }
    if(snap2.exists)
    {
      DateTime dd = DateTime.now();
      DateTime dd1 = DateTime.parse(snap2.value.toString());
      timeDifference = dd.difference(dd1).inMinutes;
    }
    if(personCount < 1 && this.isOn == true && forceStop == 0)
    {

      if(timeDifference >= 1 && !isNotified)
      {
        print("Notification called...Dev name: ${dname} Count: $personCount, Diff: $timeDifference, isOn: ${this.isOn}");
        service.initialize();
        await service.showNotification(id: id + 1, title:"Device Update",body: "A Device is turned ON with nobody present in the room. Click here to turn off !");
        isNotified = true;
      }
      else if(timeDifference >= 3 && isNotified)
      {
        Future.delayed(Duration(seconds: 2));
        dBr.child("Users/${this.username}/Flags").update({"forceStop":1});
        isNotified = false;
        forceStop = 1;
        await dBr.child("Users/${this.username}/Devices/${this.dname}").update({"Last Toggled":DateTime.now().toString()});
        await service.showNotification(id: id, title: "Force Turn Off", body: "Force Turn OFF enabled !");
        print("Force stop called !");
      }
    }
    else if(personCount > 1)
    {
      isNotified = false;
    }
    
  }
  Future<void> monitorTime(var ref) async
  {
    final snap2 = await ref.child("Users/${this.username}/Devices/${path}").get();
    if(snap2.exists)
    {
      bool isOn1 = snap2.value["updated_state"];
      int initialHrs = 0;
      int hrs_db = 0;
      DateTime temp = DateTime.now();
      if(isOn1)
      {
        if(temp.hour == 0 || temp.hour == 24)
        {
          if(temp.minute >= 30)
            initialHrs = 1;
          else
            initialHrs = 0;
        }
        else
        {
          initialHrs = int.parse(snap2.value["Hours"].toString());
        }
        DateTime d3 = DateTime.parse(snap2.value["Last Updated"]);
        DateTime d4 = DateTime.parse(DateTime.now().toString());
        int measured = d4.difference(d3).inHours.toInt();
        if((initialHrs + measured) <= 24)
        {  hrs_db = initialHrs + measured;}
        ref.child("Users/${this.username}/Devices/${path}").update({"Hours":hrs_db,"Last Updated":DateTime.now().toString()});
      }
    }
  }
  Future<void> getTime(var ref) async
  {
    String timer1 = "-1";
    final snap1 = await ref.child("Users/${this.username}/Devices/${path}").get();
    if(snap1.exists)
    {
      d1 = DateTime.parse(snap1.value["Last Toggled"]);
      d2 = DateTime.parse(DateTime.now().toString());
      timer1 = snap1.value["Timer"].toString();
      timeDifference = d2.difference(d1).inMinutes;
      if(timer1 != "-1")
      {
        if(DateTime.now().compareTo(DateTime.parse(timer1)) >= 0)
        {
          print(DateTime.now().toString());
          print(DateTime.parse(timer1).toString());
          isOn = snap1.value["updated_state"];
          isOn = !isOn;
          await ref.child("Users/${this.username}/Devices/${path}").update({"updated_state":isOn,"Timer":"-1","Last Toggled":DateTime.now().toString()});
          timer1 = "-1";
          if(isOn)
            await ref.child("Users/${this.username}/Devices/${path}").update({"Last Updated":DateTime.now().toString()});
          await dBr.child("Users/${this.username}/Flags").update({"forceStop":0});
        }
        
      }
      diff = timeDifference <= 60 ? d2.difference(d1).inMinutes.toString() + " minute(s) ago" : d2.difference(d1).inHours.toString() + " hour(s) ago";
      
    }
    else
      {
        dtext = "Unavailable";
        diff = "Last Toggle data unavailable";
      
      }
  }
  Future<void> getVal(var ref) async
  {
    final snapshot = await ref.child("Users/${this.username}/Devices/${this.path}").get();
    if (snapshot.exists) {
      Map m1 = snapshot.value;
      this.isOn = m1["updated_state"];
      isBulb = m1["DeviceType"];
      if(isOn)
        {if(isBulb == 0)
          bulbcolor = Colors.yellow;
         else if(isBulb == 1)
          bulbcolor = Colors.blue;
        else if(isBulb == 2)
          bulbcolor = Colors.orangeAccent;
        else
          bulbcolor = Colors.deepPurple;
        }
      else
        bulbcolor = Colors.white;
      bulbtext = isOn ? "On" : "Off";
      
    }
    else {
        bulbcolor = Colors.white;
        bulbtext = "Unavailable";
    } 
    await getTime(ref);
  }
  
  Device(this.username,this.dname,this.path,this.iconData,this.isOn);
  @override
  State<Device> createState() => _DeviceState();
}

class _DeviceState extends State<Device> {
  @override
  bool isViewed = false;
  late final LocalNotificationService service;
  var tim = Timer.periodic(const Duration(seconds:60),(timer) { });
  @override
  void initState() {
    service = LocalNotificationService();
    service.initialize();
    super.initState();
    tim = Timer.periodic(Duration(seconds: 10), (timer) {
    widget.getVal(dBr);
    Future.delayed(Duration (seconds: 2));
    widget.notify(dBr);
    Future.delayed(Duration (seconds: 2));
    widget.monitorTime(dBr);
    Future.delayed(Duration (seconds: 2));
    setState(() {});
      
    });
     if(isViewed)
        tim.cancel();
  }
  @override
  void dispose() {
    isViewed = true;
    tim.cancel();
    super.dispose();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("${widget.dname}")),
        backgroundColor: Color(0xFF163057),
      ),
      backgroundColor:Color(0xFF002647),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FutureBuilder(
              future: widget.getVal(dBr),
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.done)
                {
                  return Column(
                    children: [
                  IconButton(icon: Icon(widget.iconData,size: iconsize,),
                  color: bulbcolor,
                  onPressed: ()async{
                    widget.isOn = !widget.isOn;
                    d2 = DateTime.parse(DateTime.now().toString());
                    if(widget.iconData == Icons.lightbulb)
                      isBulb = 0;
                    else if(widget.iconData == FontAwesomeIcons.fan)
                      isBulb = 1;
                    else if(widget.iconData == Icons.tv)
                      isBulb = 2;
                    else
                      isBulb = 3;
                    diff = d2.difference(d1).inMinutes.toString();
                    await dBr.child("Users/${widget.username}/Devices/${widget.path}").update({"updated_state":widget.isOn,"Last Toggled":d2.toString(),"DeviceType":isBulb});
                    if(widget.isOn)
                    {
                      await dBr.child("Users/${widget.username}/Devices/${widget.path}").update({"Last Updated":DateTime.now().toString()});
                    }
                    Future.delayed(const Duration(milliseconds: 2000), () {
                        setState(() {
                          if(widget.isOn)
                            {if(isBulb == 0)
                              bulbcolor = Colors.yellow;
                            else if(isBulb == 1)
                              bulbcolor = Colors.blue;
                            else if(isBulb == 2)
                              bulbcolor = Colors.orangeAccent;
                             else
                              bulbcolor = Colors.deepPurple;
                            }
                          else
                            bulbcolor = Colors.white;
                          bulbtext = widget.isOn ? "On" : "Off";
                          });

                        });
                  },
                  iconSize: 70.0,
                  ),
                  Center(
                    child: Text(
                      "$bulbtext",
                      style: TextStyle(color: Colors.white,fontSize: 40.0,fontWeight: FontWeight.bold),

                    ),
                  ),
                  Center(
                    child: Text(
                      "\n$diff",
                      style: TextStyle(color: Colors.white,fontSize: 20.0),

                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Center(
                      child: ElevatedButton.icon(onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => Timer1(widget.username,widget.dname)));

                      },icon: Icon(Icons.timer,color:Colors.yellowAccent), label: Text("Set a Timer",style: TextStyle(color: Colors.white),)),
                    ),
                  ),
                  ]);
                }
                else
                { num++;
              return Center(
                          child: SpinKitCubeGrid(
                                color: Colors.white,
                                size: 70.0,
                                
                              ),
                  );
                }
              }
            ),
          ]),
      ));
}
}
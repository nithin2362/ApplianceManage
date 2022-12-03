import 'dart:ffi';
import 'package:appliance/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'wait.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'device.dart';
import 'package:appliance/notification.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'forgotpwd.dart';
import 'addappl.dart';

final dBr = FirebaseDatabase.instance.ref();
late LocalNotificationService service1 = LocalNotificationService();
// final service = FlutterBackgroundService();
var tim = Timer.periodic(const Duration(seconds:60),(timer) { });
String uname = '';
int ForceStop = -3;
var finalname;
bool? val = false;
var sharedPreferences;
Future <void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  uname = await keepMeSignedIn();
  print("Uname1: $uname");
  // await initializeService();
  runApp(
  MaterialApp(
  home: val == true ? HomeScreenPage(uname) : Signin(),
  debugShowCheckedModeBanner: false,
  ));
    
}
var notificationChannelId = channel_Id;
var notificationId = notificationId1;

// Future<void> initializeService() async
// {
// WidgetsFlutterBinding.ensureInitialized();
// await service.configure(
//   androidConfiguration: AndroidConfiguration(
//     onStart: onStart,
//     autoStart: true,
//     isForegroundMode: true,
//     notificationChannelId: notificationChannelId,
    
//   ),
//   iosConfiguration: IosConfiguration(autoStart: false));
// }
// Future<void> onStart(ServiceInstance service) async {
 
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   await Firebase.initializeApp();
//   Timer.periodic(const Duration(seconds: 10), (timer) async {
//     if (service is AndroidServiceInstance) {
//     for(int i = 0;i<devices.length;++i)
//     {
//       devices[i].getVal(dBr);
//       Future.delayed(const Duration(seconds: 3));
//       devices[i].notify(dBr);
//       Future.delayed(const Duration(seconds: 3));
//     }
//    }
//   });
// }
Future<String> keepMeSignedIn()async
{
  sharedPreferences = await SharedPreferences.getInstance();
  String remember = await sharedPreferences.getString("Username").toString();
  val = await sharedPreferences.getBool("Flag");
  return remember;
}
Future<void> addDevices(var dBr,var username) async
{
  final snapshot = await dBr.child("Users/$username/Devices").get();
  Map devs = {};
  if(snapshot.exists)
  {
    devs = snapshot.value;
  }
  int index;
  var k = devs.keys.toList();
  var v = devs.values.toList();
  if(k.length >= devicelimit)
    isButtonDisabled = true;
  else
    isButtonDisabled = false;
  int i = 0;
  Device dev;
for(final key in k)
    {
      if(!deviceNames.contains(key))
      {
        i = k.indexOf(key);
        IconData ic;
        if(v[i]["DeviceType"] == 0)
          ic = Icons.lightbulb;
        else if(v[i]["DeviceType"] == 1)
          ic = FontAwesomeIcons.fan;
        else if(v[i]["DeviceType"] == 2)
          ic = Icons.tv;
        else
          ic = Icons.devices;
        dev = Device(username,key,key,ic,false); 
        devices.add(dev);
        deviceNames.add(key);
        await devices[i].getVal(dBr);
        Future.delayed(const Duration(seconds: 2));
        await devices[i].notify(dBr);
        Future.delayed(const Duration(seconds: 2));
        ++id;
        
      }
    }
}
int id = 0,devicelimit = 5;
bool isButtonDisabled = false;
class HomeScreenPage extends StatefulWidget {
  final String uname;
  HomeScreenPage(this.uname);

  @override
  State<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
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
          
          return HomeScreen(uname);
          
        }
        else
          return WaitScreen(true);
      }
    );
  }
}
class HomeScreen extends StatefulWidget {
  String username;
  HomeScreen(this.username);
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
@override
List<Device> devices = [];
List<String> deviceNames = [];
class _HomeScreenState extends State<HomeScreen>{
  @override
  bool isViewed = false;
  void initState() {
    service1 = LocalNotificationService();
    service1.initialize();
    // service.startService();
    super.initState();
    tim = Timer.periodic(Duration(seconds: 15), (timer) {
     for(int i = 0;i<devices.length;++i)
     {
      devices[i].getVal(dBr);
      Future.delayed(const Duration(seconds: 3));
      devices[i].notify(dBr);
      Future.delayed(const Duration(seconds: 3));
      devices[i].monitorTime(dBr);
      Future.delayed(const Duration(seconds: 3));
     }
    });
  }
  @override
  void dispose() {
    isViewed = true;
    tim.cancel();
    super.dispose();
  }

  Future<void> getDevices(var dBr,var username) async
  {
    
    print("From getdevs: ${uname}");
    final snapss = await dBr.child("Users/$username/Flags/forceStop").get();
    ForceStop = await snapss.value;
    final snapshot = await dBr.child("Users/$username/Devices").get();
    if(snapshot.exists)
    {
      await addDevices(dBr,username);
      for(int i = 0;i<devices.length;++i)
      {
        devices[i].monitorTime(dBr);
        Future.delayed(const Duration(seconds: 3));
      }
    }
  else
  {
    devices = [];
    print("\nDevices not found !!");
    return;
  }
    
  }
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        showDialog(
                context: context, 
                builder: (context) => AlertDialog(
                                backgroundColor: Color.fromARGB(255, 33, 72, 131), 
                                title: Text("Logout", style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold),),
                                content: Text("Are you sure you want to Logout ?",style: TextStyle(color: Colors.white,fontSize: 15),),
                                actions: [
                                  ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("No",style: TextStyle(color: Colors.white,fontSize: 15),)),
                                  TextButton(onPressed: (){
                                    devices.clear();
                                    deviceNames.clear();
                                    sharedPreferences.setBool("Flag", false);
                                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Signin()), (route) => false);
                                  }, child: Text("Yes",style: TextStyle(color: Colors.blue,fontSize: 15),)),
                                ],
              ));
              return false;
      },
      child: FutureBuilder(
        future: getDevices(dBr,widget.username),
        builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done)
        {
          return Scaffold(
              appBar: AppBar(
                leading: IconButton(onPressed: (){
                      if(!isButtonDisabled)
                      {
                        
                        Navigator.push(context,
                        MaterialPageRoute(builder: (context) => DeviceAdd(widget.username)));
                      }
                      else
                      {
                        ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Device limit reached !')));
                        return null;
                      }
                
              }, icon: Icon(Icons.add,color: isButtonDisabled ? Colors.grey : Colors.white,size: 40),),
                title: Center(child: Text("${widget.username}",style: TextStyle(color: Colors.white,fontSize: 20.0,fontWeight: FontWeight.bold),)),backgroundColor: Color(0xFF163057),
              actions: [
                IconButton(onPressed: (){
                showDialog(
                context: context, 
                builder: (context) => AlertDialog(
                                backgroundColor: Color.fromARGB(255, 33, 72, 131), 
                                title: Text(ForceStop >= 0 ? "Ignore Mode" : "Appliance Control Mode", style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold),),
                                content: Text(ForceStop >= 0 ? "Do you want to halt automatic switching of devices ?" : "Do you want to enable automatic switching of devices ?",style: TextStyle(color: Colors.white,fontSize: 15),),
                                actions: [
                                  ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("No",style: TextStyle(color: Colors.white,fontSize: 15),)),
                                  TextButton(onPressed: (){
                                    setState(() {
                                    dBr.update({"Users/${widget.username}/Flags/forceStop":ForceStop >=0 ? -1 : 0});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Click the button again to enable/disable automatic control')));
                                    Navigator.pop(context);
                            }); 
                                  }, child: Text("Yes",style: TextStyle(color: Colors.blue,fontSize: 15),)),
                                ],
              ));
              }, icon: Icon(Icons.dangerous,color: Colors.red[500],size: 40,)),
              ],
              ),
              backgroundColor:Color.fromARGB(255, 14, 39, 62),
              body: ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final item = devices[index];
    
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color.fromARGB(255, 81, 113, 161),                      
                        ),
                      
                        height: 60,
                        child: ListTile(
                          title: Padding(padding:EdgeInsets.only(left: 80),child: Text("${item.dname}",style: TextStyle(color: Colors.white,fontSize: 20.0),)),
                          leading: Icon(item.iconData,color: Colors.white,size: 40),
                          iconColor: bulbcolor,
                          trailing: IconButton(icon: Icon(Icons.delete),iconSize: 40,color:Colors.red,onPressed: (){
                            showDialog(
                              context: context, 
                              builder: (context) => AlertDialog(
                                backgroundColor: Color.fromARGB(255, 33, 72, 131), 
                                title: Text("Delete ${item.dname} ?", style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold),),
                                content: Text("Are you sure you want to delete this device ?",style: TextStyle(color: Colors.white,fontSize: 15),),
                                actions: [
                                  ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("Cancel",style: TextStyle(color: Colors.white,fontSize: 15),)),
                                  TextButton(onPressed: (){
                                    setState(() {
                                    dBr.child("Users/${widget.username}/Devices/${item.dname}").remove();
                                    devices.remove(item);
                                    deviceNames.remove(item.dname);
                                    Navigator.pop(context);
                            });
                                  }, child: Text("Delete",style: TextStyle(color: Colors.blue,fontSize: 15),)),
                                ],
                              ));
                            
                          },),
                          onTap: ()
                          {
                          Navigator.push(context,
                          MaterialPageRoute(builder: (context) => item));
                          }
                          
                        ),
                      ),
                    );
                  },
                ),
            );
        }
      else
        return WaitScreen(false);
      }
       ),
    );
  }
}

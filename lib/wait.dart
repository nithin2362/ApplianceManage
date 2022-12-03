import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class WaitScreen extends StatelessWidget {
  final bool flag;
  WaitScreen(this.flag);

  @override
  Widget build(BuildContext context) {
    if(flag == false){
    return Scaffold(
    backgroundColor: Color(0xFF002647),
    body: Center(
      child: SpinKitCubeGrid(
            color: Colors.white,
            size: 70.0,
      ),
    ));
  }
  else
  {
    return Scaffold(
      backgroundColor: Color(0xFF002647),
      body: Container(
        child: Column(
          mainAxisAlignment:MainAxisAlignment.spaceEvenly,
          children: [
            Text("APPLIANCE CONTROL", style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold),),
            SpinKitSpinningLines(
              color: Colors.white,
              size: 80,
            ),
            Text("Loading...",style: TextStyle(color: Colors.white,fontSize: 20),),
          ],
        ),
      ),
    );
  }
}
}

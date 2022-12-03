import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
final channel_Id = 'channel_id1';
final notificationId1 = 888;


class LocalNotificationService
{
  LocalNotificationService();


final _localNotificationService = FlutterLocalNotificationsPlugin();
Future<void> initialize() async
{
  const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings("@drawable/ic_stat_lightbulb");
  final InitializationSettings settings = InitializationSettings(android: androidInitializationSettings);

  await  _localNotificationService.initialize(settings);
}

Future<NotificationDetails> _notificationDetails() async
{
const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        "channel_id1",
        "channel_name1",
        channelDescription: "Appliance Control Notification Channel",
        importance: Importance.max,
        priority: Priority.max,
        playSound: true);



return const NotificationDetails(android: androidNotificationDetails);
}

Future<void> showNotification({
  required int id,
  required String title,
  required String body
}) async
{
  final details = await _notificationDetails();
  await _localNotificationService.show(id,title,body,details);


}


void _onReceiveLocalNotification(int id,String body,String payload)
{
  print("id $id");

}

}
import 'package:flutter/material.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'dart:async';
import 'package:vibration/vibration.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:torch_light/torch_light.dart';


void main(List<String> args) {

  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize('resource://drawable/notification_icon', [
    // notification icon
    NotificationChannel(
      channelGroupKey: 'basic_test',
      channelKey: 'basic',
      channelName: 'Basic notifications',
      channelDescription: 'Notification channel for basic tests',
      channelShowBadge: true,
      importance: NotificationImportance.High,
    ),

  ]);
    
  AwesomeNotifications()
      .actionStream
      .listen((ReceivedNotification receivedNotification) {
    print(receivedNotification.payload!['name']);
    
  });

  runApp(SensorNotification());
}

class SensorNotification extends StatefulWidget {
  @override
  _SensorNotificationState createState() => _SensorNotificationState();
}

class _SensorNotificationState extends State<SensorNotification> {
  bool _isNear = false;
  bool hasflashlight = false; 
  bool isturnon = false; 
  late StreamSubscription<dynamic> _streamSubscription;


  notification() async {
    bool isallowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isallowed) {
      //no permission of local notification
      AwesomeNotifications().requestPermissionToSendNotifications();
    } else {
      //show notification
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              //simgple notification
              id: 123,
              channelKey: 'basic', //set configuration wuth key "basic"
              title: 'Welcome to FlutterCampus.com',
              body: 'This simple notification is from Flutter App',
              payload: {"name": "FlutterCampus"}));
    }
  }

  @override
  void initState() {
    listenSensor();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
  }

  

  //Sensor 
  Future<void> listenSensor() async {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (foundation.kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
    };

    _streamSubscription = ProximitySensor.events.listen((int event) {
      setState(()  {
        _isNear = (event > 0) ? true : false;
        print('está perto? ${_isNear}');
        if(_isNear == false){
          
          _disableTorch(context);
         
        }
        
        
        if(_isNear == true) {
          
          Vibration.vibrate(
            duration: 1500,
            amplitude: 128,
          );

          //notification();
           
          _enableTorch(context);

         
        }
        
      });
    });
  }


 // LANTERNA 
  Future<void> _enableTorch(BuildContext context) async {
    try {
      await TorchLight.enableTorch();
    } on Exception catch (_) {
      _showMessage('Could not enable torch', context);
    }
  }

  Future<void> _disableTorch(BuildContext context) async {
    try {
      await TorchLight.disableTorch();
    } on Exception catch (_) {
      _showMessage('Could not disable torch', context);
    }
  }

  void _showMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }


  // IMAGENS USADAS
  Image imagemEleven(){
    return  const Image(
            image: AssetImage('assets/eleven.jpg'),
            width: 300,
            height: 300,
            );}

  Image imagemDernogogon(){
    return  const Image(
            image: AssetImage('assets/dermogogon.jpeg'),
            width: 300,
            height: 300,
            );}

 Image imagemList(){
  if (_isNear == true){
      return imagemEleven();
  }else{
    return imagemDernogogon();
  }
  
 }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Stranger Things'),
          centerTitle: true,
          backgroundColor: Colors.red,
        ),
        body: Center(
          child:Column(
            children:[
             imagemList(),
             const SizedBox(height: 80),
             Text(
              'Está perto? ${(_isNear == true ? 'sim(luz acessa)' : 'não(Dermogogon)')}',
              style: const TextStyle(fontSize: 40,
              color: Colors.red)),
              
              
        ]),
      ),
    ));
  }
}
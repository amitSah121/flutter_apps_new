import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:map_test_1/autthentication/sign_in.dart';
import 'package:map_test_1/autthentication/sign_up.dart';
import 'package:map_test_1/constants/constants.dart';
import 'package:map_test_1/explore/explore_home.dart';
import 'package:map_test_1/helpers_funcs/file_funcs.dart';
import 'package:map_test_1/helpers_funcs/file_funcs_user_dir.dart';
import 'package:map_test_1/home.dart';
import 'package:map_test_1/journey_notes/journey_notes_home.dart';
import 'package:map_test_1/mainForgroundService.dart';
import 'package:map_test_1/manual/manual_home.dart';
import 'package:map_test_1/notifications/notification_home.dart';
import 'package:map_test_1/pageEditors/media_reader.dart';
import 'package:map_test_1/pageEditors/page_editor.dart';
import 'package:map_test_1/pageEditors/media_editor.dart';
import 'package:map_test_1/pageEditors/page_reader.dart';
import 'package:map_test_1/pageEditors/view_as_story.dart';
import 'package:map_test_1/profile/profile_home.dart';
import 'package:map_test_1/provider/provider.dart';
import 'package:map_test_1/search/searchHome.dart';
import 'package:map_test_1/settings/settings.dart';
import 'package:map_test_1/tracer/manual_editor.dart';
import 'package:map_test_1/tracer/tracer_home.dart';
import 'package:provider/provider.dart';


@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}



Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    await FMTCObjectBoxBackend().initialise();
    await const FMTCStore('mapStore').manage.create();
    
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CustomProvider())],
      child: const MainApp()
    )
  );
}



class MainApp extends StatefulWidget {
  const MainApp({super.key});


  @override
  State<MainApp> createState() => _MainAppState();

}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver{
    Timer? p;

  void _onReceiveTaskData(Object data) {
    if (data is Map<String, dynamic>) {
      final dynamic timestampMillis = data["timestampMillis"];
      if (timestampMillis != null) {
        final DateTime timestamp =
            DateTime.fromMillisecondsSinceEpoch(timestampMillis, isUtc: true);
        print('timestamp: ${timestamp.toString()}');
      }
    }
    // print(data);
  }

  @override
  void initState() {
    super.initState();
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissions();
      _initService();
    });


    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() async{
      final myModel = Provider.of<CustomProvider>(context, listen: false);
      defaultAppPath = await localPath;
      await myModel.loadJourney();
      await myModel.loadOtherNodes();
      deviceWidth = MediaQuery.of(context).size.width;
      deviceHeight = MediaQuery.of(context).size.height;

      if(!Directory("${await localPath}/media").existsSync()){
        await getDir("media");
      }

      if(!Directory("${await localPath}/media/images").existsSync()){
        await getDir("media/images");
      }

      if(!Directory("${await localPath}/media/videos").existsSync()){
        await getDir("media/videos");
      }

      if(!Directory("${await localPath}/media/audios").existsSync()){
        await getDir("media/audios");
      }
      
      if(!Directory("${await localPath}/journey").existsSync()){
        await getDir("journey");
      }

      if(!Directory("${await localPath}/pageNode").existsSync()){
        await getDir("pageNode");
      }

      if(!Directory("${await localPath}/mediaNode").existsSync()){
        await getDir("mediaNode");
      }


      if(!File("${await localPath}/userpref").existsSync()){
        await getFile("userpref");
      }

      if(!File("${await localPath}/allFilesClient").existsSync()){
        // print("kakkskaalslkas");
        await getFile("allFilesClient");
      }
      
      await getUserDirectory();

      await _startService();

      // await listFilesDirs(dir: "",pattern: "*/*");
    });

    
    

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // print(state);
    // if(state == AppLifecycleState.paused){
    //   print("paused");
    // }else if(state == AppLifecycleState.resumed){
    //   print("resumed");
    // }else if(state == AppLifecycleState.detached){
    //   print("detached");
    // }else if(state == AppLifecycleState.hidden){
    //   print("hidden");
    // }else if(state == AppLifecycleState.inactive){
    //   print("inactive");
    // }
    // if(state == AppLifecycleState.paused || state == AppLifecycleState.hidden || state == AppLifecycleState.inactive){
    //   if(p != null) {
    //     p!.cancel();
    //   };
    //   p = Timer.periodic(const Duration(seconds: 1), (t)async{
    //     // print("Hhh");
    //     final myModel = Provider.of<CustomProvider>(context, listen: false);
    //     var searchResult = myModel.currentJourney;
    //     if(searchResult == null) return;
    //     var pos = await determinePositionWithoutCallingPermission();
    //     if(searchResult.metadata.split(";")[1].split("=")[1] == "false"){
    //       var q = searchResult.pathNodes.last;
    //       var p = sqrt(pow(pos.altitude-q.altitude,2)+pow(pos.latitude-q.latitude,2)+pow(pos.longitude-q.longitude,2));
    //       // print(p);
    //       if(p<distanceToRecord) return;
    //       var time = DateTime.now();
    //       int id = time.year*pow(10,16)+time.month*pow(10,14)+time.day*pow(10,12)+time.hour*pow(10,10)+time.minute*pow(10,8)+time.second*pow(10,6)+time.microsecond*pow(10,4) as int;
    //       searchResult.pathNodes.add(PathNode.fromPosition(pos,id));
          
    //     }
    //   });
      
    // }else if(state == AppLifecycleState.resumed){
    //   p?.cancel();
    // }
  }

  Future<void> _requestPermissions() async {
    
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      if (!await FlutterForegroundTask.canScheduleExactAlarms) {
        await FlutterForegroundTask.openAlarmsAndRemindersSettings();
      }
    }
  }

  Future<ServiceRequestResult> _startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        notificationIcon: null,
        notificationButtons: [
          const NotificationButton(id: 'btn_hello', text: 'hello'),
        ],
        notificationInitialRoute: '/',
        callback: startCallback,
      );
    }
  }

  void _initService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<ServiceRequestResult> _stopService() {
    return FlutterForegroundTask.stopService();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    _stopService();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Map',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SignIn(),
      routes: {
        "/home": (context) => const Home(),
        "/explore": (context) => const ExploreHome(),
        "/tracer": (context) => const TracerHome(),
        "/profile": (context) => const ProfileHome(),
        "/settings": (context) => const Settings(),
        "/journey_notes": (context) => const JourneyNotesHome(),
        "/search": (context) => const SearchHome(),
        "/notifications": (context) => const NotificationHome(),
        "/pageEditor": (context) => const PageEditor(),
        "/mediaEditor": (context) => const MediaEditor(),
        "/pageReader": (context) => PageReader(),
        "/mediaReader": (context) => MediaReader(),
        "/manualEditor": (context) => const ManualEditor(),
        "/manualPage": (context) => const ManualHome(),
        "/viewAsStory": (context) => const ViewAsStory(),
        "/register": (context) => const Register(),
        "/signin": (context) => const SignIn()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}



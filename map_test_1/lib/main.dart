import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:map_test_1/constants/constants.dart';
import 'package:map_test_1/explore/explore_home.dart';
import 'package:map_test_1/helpers_funcs/file_funcs.dart';
import 'package:map_test_1/helpers_funcs/file_funcs_user_dir.dart';
import 'package:map_test_1/home.dart';
import 'package:map_test_1/journey_notes/journey_notes_home.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() async{
      final myModel = Provider.of<CustomProvider>(context, listen: false);
      defaultAppPath = await localPath;
      await myModel.loadJourney();
      await myModel.loadOtherNodes();
      deviceWidth = MediaQuery.of(context).size.width;
      deviceHeight = MediaQuery.of(context).size.height;

      await getDir("media");
      await getDir("media/images");
      await getDir("media/videos");
      await getDir("media/audios");

      await getDir("journey");
      await getDir("pageNode");
      await getDir("mediaNode");

      await getUserDirectory();

      // await listFilesDirs(dir: "",pattern: "*/*");
    });
    

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print(state);
    if(state == AppLifecycleState.paused){
      print("paused");
    }else if(state == AppLifecycleState.resumed){
      print("resumed");
    }else if(state == AppLifecycleState.detached){
      print("detached");
    }else if(state == AppLifecycleState.hidden){
      print("hidden");
    }else if(state == AppLifecycleState.inactive){
      print("inactive");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
      home: const Home(),
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
        "/viewAsStory": (context) => const ViewAsStory()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}



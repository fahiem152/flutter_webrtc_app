import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:flutter_webrtc_app/firebase_options.dart';
import 'package:flutter_webrtc_app/src_2/app.dart';
import 'package:flutter_webrtc_app/src_2/common/app_initializer.dart';
import 'package:flutter_webrtc_app/src_2/common/dependecy_injection.dart';
import 'package:flutter_webrtc_app/src_2/services/socket_service.dart';
import 'package:flutter_webrtc_app/src_2/shared/logger/logger_utils.dart';
import 'package:flutter_webrtc_app/src_3/home_page.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

// Injector injector = Injector();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   DependencyInjection().initialise(injector);
//   await AppInitializer().initialise(injector);
//   final SocketService socketService = injector.get<SocketService>();
//   socketService.createSocketConnection();
//   runApp(
//     GetMaterialApp(
//       enableLog: true,
//       logWriterCallback: Logger.write,
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Chat Realtime',
//       home: App(),
//     ),
//   );
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: HomePage(),
      home: WebRTCExample(),
      // home: GetDisplayMedia(),
      // home: GetUserMedia(),
      //  home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   Signaling signaling = Signaling();
//   final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
//   final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
//   // String? roomId;
//   TextEditingController textEditingController = TextEditingController(text: '');

//   @override
//   void initState() {
//     _localRenderer.initialize();
//     _remoteRenderer.initialize();

//     signaling.onAddRemoteStream = ((stream) {
//       _remoteRenderer.srcObject = stream;
//       log("OnAddRemoteStream: ${stream.id}");

//       setState(() {});
//     });

//     super.initState();
//   }

//   @override
//   void dispose() {
//     _localRenderer.dispose();
//     _remoteRenderer.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // log("_remoteRenderer: ${_remoteRenderer}");
//     // log("_LocalRenderer: ${_localRenderer}");
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(" Flutter - WebRTC"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(30),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black,
//                 foregroundColor: Colors.white,
//               ),
//               onPressed: () async {
//                 String roomId = await signaling.createRoom(_remoteRenderer);
//                 // signaling.openUserMedia(_localRenderer, _remoteRenderer);
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => RoomPage(
//                             roomId: roomId,
//                             isCreated: true,
//                           )),
//                 );
//               },
//               child: const Text("Create room"),
//             ),
//             const SizedBox(
//               height: 12.0,
//             ),
//             Divider(),
//             const SizedBox(
//               height: 12.0,
//             ),
//             Container(
//               padding: const EdgeInsets.all(12),
//               margin: const EdgeInsets.only(),
//               child: TextFormField(
//                 maxLength: 20,
//                 controller: textEditingController,
//                 decoration: const InputDecoration(
//                   labelText: 'Room',
//                   labelStyle: TextStyle(
//                     color: Colors.blueGrey,
//                   ),
//                   hintText: 'Room ID',
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(
//                       color: Colors.blueGrey,
//                     ),
//                   ),
//                 ),
//                 onChanged: (value) {},
//               ),
//             ),
//             const SizedBox(
//               height: 8.0,
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black,
//                 foregroundColor: Colors.white,
//               ),
//               onPressed: () {
//                 signaling.joinRoom(
//                   textEditingController.text.trim(),
//                   _remoteRenderer,
//                 );
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => RoomPage(
//                             roomId: textEditingController.text.trim(),
//                             isCreated: false,
//                           )),
//                 );
//               },
//               child: const Text("Join Room"),
//             ),
//             // const SizedBox(height: 8),
//             // Row(
//             //   mainAxisAlignment: MainAxisAlignment.center,
//             //   children: [
//             //     ElevatedButton(
//             //       onPressed: () {
//             //         signaling.openUserMedia(_localRenderer, _remoteRenderer);
//             //       },
//             //       child: const Text("Open camera & microphone"),
//             //     ),
//             //     const SizedBox(
//             //       width: 8,
//             //     ),
//             //     ElevatedButton(
//             //       onPressed: () async {
//             //         roomId = await signaling.createRoom(_remoteRenderer);
//             //         textEditingController.text = roomId!;
//             //         setState(() {});
//             //       },
//             //       child: const Text("Create room"),
//             //     ),
//             //     const SizedBox(
//             //       width: 8,
//             //     ),
//             //     ElevatedButton(
//             //       onPressed: () {
//             //         // Add roomId
//             //         signaling.joinRoom(
//             //           textEditingController.text.trim(),
//             //           _remoteRenderer,
//             //         );
//             //       },
//             //       child: const Text("Join room"),
//             //     ),
//             //     const SizedBox(
//             //       width: 8,
//             //     ),
//             //     ElevatedButton(
//             //       onPressed: () {
//             //         signaling.hangUp(_localRenderer);
//             //       },
//             //       child: const Text("Hangup"),
//             //     )
//             //   ],
//             // ),
//             // const SizedBox(height: 8),
//             // Expanded(
//             //   child: Padding(
//             //     padding: const EdgeInsets.all(8.0),
//             //     child: Row(
//             //       mainAxisAlignment: MainAxisAlignment.center,
//             //       children: [
//             //         Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
//             //         SizedBox(
//             //           width: 20,
//             //         ),
//             //         Expanded(
//             //           child: RTCVideoView(_remoteRenderer),
//             //         )
//             //       ],
//             //     ),
//             //   ),
//             // ),
//             // Padding(
//             //   padding: const EdgeInsets.all(8.0),
//             //   child: Row(
//             //     mainAxisAlignment: MainAxisAlignment.center,
//             //     children: [
//             //       const Text("Join the following Room: "),
//             //       Flexible(
//             //         child: TextFormField(
//             //           controller: textEditingController,
//             //         ),
//             //       )
//             //     ],
//             //   ),
//             // ),
//             // const SizedBox(height: 8)
//           ],
//         ),
//       ),
//     );
//   }
// }

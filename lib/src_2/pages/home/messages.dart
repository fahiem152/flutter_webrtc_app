// import 'package:flutter/material.dart';
// import 'package:flutter_feather_icons/flutter_feather_icons.dart';
// import 'package:flutter_webrtc_app/module/home_page.dart';
// import 'package:get/get.dart';

// import '../../../main.dart';
// import '../../common/styles.dart';
// import '../../services/socket_service.dart';

// class Messages extends StatefulWidget {
//   const Messages({super.key});

//   @override
//   _MessagesState createState() => _MessagesState();
// }

// class _MessagesState extends State<Messages> {
//   final SocketService socketService = injector.get<SocketService>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Center(
//             child: StreamBuilder(
//       stream: socketService.getListUser,
//       builder: (context, AsyncSnapshot snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return CircularProgressIndicator();
//         }

//         if (snapshot.hasError) {
//           Get.log('Error: ${snapshot.error}');
//           return Text('Error: ${snapshot.error}');
//         }

//         if (!snapshot.hasData || snapshot.data.isEmpty) {
//           Get.log('No data available');

//           return Text('No data available');
//         }

//         Get.log('datanya: ${snapshot.data}');
//         return ListView.builder(
//           shrinkWrap: true,
//           physics: NeverScrollableScrollPhysics(),
//           itemCount: snapshot.data.length,
//           itemBuilder: (context, index) {
//             return FriendItem(
//               name: snapshot.data[index]['name'] as String,
//               image: snapshot.data[index]['image'] as String,
//               id: snapshot.data[index]['id'] as int,
//             );
//           },
//         );
//       },
//     )));
//   }
// }

// class FriendItem extends StatelessWidget {
//   final int? id;
//   final String? name;
//   final String? image;
//   final bool isOnline = false;

//   FriendItem({this.name, this.image, this.id});

//   final SocketService socketService = injector.get<SocketService>();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 16.0),
//       padding: EdgeInsets.symmetric(horizontal: 12.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Container(
//                 height: 46.0,
//                 width: 46.0,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   image: DecorationImage(
//                     image: NetworkImage(image!),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               SizedBox(width: 12.0),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     name!,
//                     style: TextStyle(
//                       color: colorTitle,
//                       fontSize: 16.5,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   SizedBox(height: 4.0),
//                   Text(
//                     isOnline ? 'Active Now' : 'Offline',
//                     style: TextStyle(
//                       color: isOnline ? Colors.green.shade400 : Colors.red,
//                       fontSize: 14.0,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           IconButton(
//             onPressed: () {
//               // socketService.createSocketConnection();
//               socketService.setUserInfo(
//                 {'id': id, 'name': name, 'image': image, 'isOnline': isOnline},
//               );
//               Get.to(HomePage(), arguments: id);
//             },
//             icon: Icon(
//               FeatherIcons.logIn,
//               color: colorPrimary,
//               size: 20.0,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

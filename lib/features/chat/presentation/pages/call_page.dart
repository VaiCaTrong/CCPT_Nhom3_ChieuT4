import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'dart:math';
import '../../../../services/zego_service.dart';

// Zego config được lấy từ backend thông qua ZegoService
// Không còn hardcode keys nữa!

class CallPage extends StatelessWidget {
  final String callID;
  final String userID;
  final String userName;
  final String chatId; // Thêm chatId để lưu lịch sử

  const CallPage({
    super.key,
    required this.callID,
    required this.userID,
    required this.userName,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context) {
    final zegoService = ZegoService();

    return ZegoUIKitPrebuiltCall(
      appID: zegoService.appId,
      appSign: zegoService.appSign,
      userID: userID,
      userName: userName,
      callID: callID,

      // Config cuộc gọi 1-1
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),

      // Xử lý sự kiện kết thúc cuộc gọi để lưu lịch sử
      events: ZegoUIKitPrebuiltCallEvents(
        onCallEnd: (event, defaultAction) async {
          // Lưu log cuộc gọi vào Firestore
          final timestamp = FieldValue.serverTimestamp();

          await FirebaseFirestore.instance
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .add({
            'senderId': userID,
            'senderName': userName,
            'content': 'Cuộc gọi video',
            'type': 'call', // Loại tin nhắn là call
            'createdAt': timestamp,
            'isEdited': false,
            // 'duration': event.duration.inSeconds, // Có thể thêm duration nếu event hỗ trợ
          });

          // Cập nhật lastMessage cho box chat
          await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
            'lastMessage': '📞 Cuộc gọi video',
            'lastUpdated': timestamp,
          }, SetOptions(merge: true));

          // Thực hiện hành động mặc định (thường là thoát màn hình gọi)
          defaultAction();
        },
      ),
    );
  }
}

// Hàm tiện ích để tạo Call ID ngẫu nhiên
String generateCallId() {
  return Random().nextInt(1000000).toString();
}

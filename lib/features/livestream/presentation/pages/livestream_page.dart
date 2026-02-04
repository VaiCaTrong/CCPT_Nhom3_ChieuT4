import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

// ****************************************************************************************************
// BƯỚC QUAN TRỌNG: Hãy thay thế AppID và AppSign của bạn vào đây
// Bạn có thể lấy các giá trị này từ ZegoCloud Console của bạn.
// ****************************************************************************************************
const int yourAppID = 872327054;
const String yourAppSign = '9f51b89db7cefc82a011d91e70a7596314f199e4623f9e9dc6b70697989c0711'; // ** ĐÃ CÓ VÍ DỤ **

class LiveStreamPage extends StatefulWidget {
  final String liveId;
  final bool isHost;

  const LiveStreamPage({
    super.key,
    required this.liveId,
    required this.isHost,
  });

  @override
  State<LiveStreamPage> createState() => _LiveStreamPageState();
}

class _LiveStreamPageState extends State<LiveStreamPage> {

  @override
  void dispose() {
    // Khi Host thoát trang, cập nhật trạng thái livestream là không còn hoạt động
    // Đây là cơ chế dự phòng quan trọng, nó sẽ chạy khi màn hình bị hủy
    if (widget.isHost) {
      _updateLiveStatus(false);
    }
    super.dispose();
  }

  Future<void> _updateLiveStatus(bool isLive) async {
    try {
      await FirebaseFirestore.instance
          .collection('livestreams')
          .doc(widget.liveId)
          .update({'isLive': isLive});
    } catch (e) {
      // Bỏ qua lỗi nếu document không tồn tại
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Lỗi: Bạn cần đăng nhập để sử dụng tính năng này.'),
        ),
      );
    }

    return SafeArea(
      child: ZegoUIKitPrebuiltLiveStreaming(
        appID: yourAppID,
        appSign: yourAppSign,
        userID: currentUser.uid,
        userName: currentUser.displayName ?? 'User',
        liveID: widget.liveId,

        // Cấu hình giao diện và sự kiện dựa trên vai trò
        config: widget.isHost
            ? _buildHostConfig() // Cấu hình cho Host
            : ZegoUIKitPrebuiltLiveStreamingConfig.audience( // Cấu hình cho Khán giả
                plugins: [ZegoUIKitSignalingPlugin()], 
              ),
      ),
    );
  }

  // ** PHIÊN BẢN SỬA LỖI DỨT ĐIỂM **
  ZegoUIKitPrebuiltLiveStreamingConfig _buildHostConfig() {
    return ZegoUIKitPrebuiltLiveStreamingConfig.host(
      plugins: [ZegoUIKitSignalingPlugin()],
      // Tham số callback gây lỗi đã được XÓA HOÀN TOÀN.
      // Việc cập nhật trạng thái sẽ được xử lý trong hàm dispose().
    );
  }
}

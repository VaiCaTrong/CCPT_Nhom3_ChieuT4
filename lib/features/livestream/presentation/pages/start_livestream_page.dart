import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'livestream_page.dart';

class StartLiveStreamPage extends StatefulWidget {
  const StartLiveStreamPage({super.key});

  @override
  State<StartLiveStreamPage> createState() => _StartLiveStreamPageState();
}

class _StartLiveStreamPageState extends State<StartLiveStreamPage> {
  final _liveIdController = TextEditingController();
  final _currentUser = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;
  bool _isPublic = true; // ** Thêm state để quản lý loại phòng **

  @override
  void dispose() {
    _liveIdController.dispose();
    super.dispose();
  }

  Future<void> _startLiveStream() async {
    final liveId = _liveIdController.text.trim();
    if (liveId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Live ID'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: không tìm thấy người dùng'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Tạo bản ghi trên Firestore
      await FirebaseFirestore.instance.collection('livestreams').doc(liveId).set({
        'liveID': liveId,
        'hostID': _currentUser!.uid,
        'hostName': _currentUser!.displayName ?? 'Người dùng',
        'isLive': true,
        'isPublic': _isPublic, // ** Lưu loại phòng vào Firestore **
        'createdAt': FieldValue.serverTimestamp(),
        'viewers': 0,
      });

      if (!mounted) return;

      // Điều hướng tới trang livestream
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LiveStreamPage(
            liveId: liveId,
            isHost: true,
          ),
        ),
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tạo phòng: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Livestream'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chào, ${_currentUser?.displayName ?? 'Host'}!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhập một ID cho buổi phát trực tiếp của bạn',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _liveIdController,
              decoration: const InputDecoration(
                labelText: 'Live ID',
                hintText: 'ví dụ: live_stream_123',
                prefixIcon: Icon(Icons.live_tv),
              ),
            ),
            const SizedBox(height: 24),

            // ** Thêm lựa chọn Public/Private **
            SwitchListTile(
              title: const Text('Phòng công khai'),
              subtitle: const Text('Nếu tắt, người khác cần ID để vào phòng'),
              value: _isPublic,
              onChanged: (value) {
                setState(() {
                  _isPublic = value;
                });
              },
              secondary: Icon(_isPublic ? Icons.public : Icons.lock, color: Theme.of(context).primaryColor),
            ),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _startLiveStream,
              icon: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0))
                  : const Icon(Icons.sensors),
              label: Text(_isLoading ? 'ĐANG TẠO...' : 'BẮT ĐẦU PHÁT SÓNG'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'livestream_page.dart';
import 'start_livestream_page.dart';

class LivestreamListPage extends StatelessWidget {
  const LivestreamListPage({super.key});

  void _joinPrivateRoom(BuildContext context) {
    final liveIdController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vào phòng riêng tư'),
        content: TextField(
          controller: liveIdController,
          decoration: const InputDecoration(labelText: 'Nhập Live ID'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final liveId = liveIdController.text.trim();
              if (liveId.isNotEmpty) {
                Navigator.pop(context); // Đóng dialog
                Navigator.push(context, MaterialPageRoute(builder: (_) => 
                  LiveStreamPage(liveId: liveId, isHost: false)
                ));
              }
            },
            child: const Text('Vào xem'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        // ** SỬA LỖI: Đơn giản hóa query và lọc trong code để tránh lỗi index **
        stream: FirebaseFirestore.instance
            .collection('livestreams')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
             return Center(child: Text('Đã có lỗi xảy ra: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Lọc thủ công các phòng đang hoạt động
          final liveDocs = snapshot.data?.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return data?['isLive'] == true;
          }).toList() ?? [];

          if (liveDocs.isEmpty) {
            return const Center(
              child: Text('Chưa có phòng live nào'), // ** Sửa lại thông báo **
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: liveDocs.length,
            itemBuilder: (context, index) {
              final live = liveDocs[index].data() as Map<String, dynamic>;
              final liveId = live['liveID'] ?? '';
              final hostName = live['hostName'] ?? 'Host';
              final isPublic = live['isPublic'] ?? true; 

              return InkWell(
                onTap: () {
                  if (isPublic) {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => 
                      LiveStreamPage(liveId: liveId, isHost: false)
                    ));
                  } else {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Phòng riêng tư'),
                        content: const Text('Đây là phòng riêng tư. Vui lòng sử dụng nút "Tùy chọn" ở góc dưới và chọn "Vào phòng bằng ID" để tham gia.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                           gradient: isPublic
                            ? LinearGradient(colors: [Colors.purple.shade400, Colors.deepPurple.shade600], begin: Alignment.topLeft, end: Alignment.bottomRight)
                            : LinearGradient(colors: [Colors.grey.shade700, Colors.grey.shade800], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isPublic ? Icons.public : Icons.lock, color: Colors.white, size: 40),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              hostName,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (!isPublic)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('RIÊNG TƯ', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (ctx) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.add_circle_outline),
                    title: const Text('Tạo phòng livestream mới'),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const StartLiveStreamPage()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.vpn_key),
                    title: const Text('Vào phòng bằng ID'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _joinPrivateRoom(context);
                    },
                  ),
                ],
              ),
            ),
          );
        },
        icon: const Icon(Icons.video_call),
        label: const Text('Tùy chọn'),
      ),
    );
  }
}

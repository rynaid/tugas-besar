import 'package:flutter/material.dart';
import '../state_data.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi Aplikasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // TOMBOL RAHASIA UNTUK SIMULASI DEMO DI DEPAN DOSEN
          TextButton.icon(
            icon: const Icon(Icons.add_alert, color: Colors.white, size: 16),
            label: const Text('Demo Notif', style: TextStyle(color: Colors.white, fontSize: 11)),
            onPressed: () {
              state.tambahNotifikasi(
                'Pesanan Selesai Dimasak!',
                'Mie Ayam Elektro pesananmu telah disiapkan oleh juru masak Kantin Kodok. Silakan ambil di konter pelayanan.',
                'order'
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Simulasi: Notifikasi push berhasil ditambahkan secara live!'), backgroundColor: Colors.blue),
              );
            },
          )
        ],
      ),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, child) {
          if (state.notifikasi.isEmpty) {
            return const Center(child: Text('Tidak ada notifikasi baru.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.notifikasi.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = state.notifikasi[index];
              IconData iconData;
              Color iconColor;

              switch (item['type']) {
                case 'order':
                  iconData = Icons.restaurant_menu;
                  iconColor = Colors.green;
                  break;
                case 'payment':
                  iconData = Icons.qr_code_scanner;
                  iconColor = Colors.blue;
                  break;
                default:
                  iconData = Icons.local_offer;
                  iconColor = Colors.orange;
              }

              return Card(
                elevation: item['read'] ? 0.5 : 2.0,
                color: item['read'] ? Colors.white : Colors.blue[50]?.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    state.tandaiDibaca(item['id'] as String);
                    _tampilkanDetailNotif(context, item);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: iconColor.withValues(alpha: 0.1),
                          child: Icon(iconData, color: iconColor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['title'] as String, 
                                      style: TextStyle(fontWeight: item['read'] ? FontWeight.normal : FontWeight.bold, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(item['time'] as String, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['body'] as String,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _tampilkanDetailNotif(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: Color(0xFF1E3A8A)),
            SizedBox(width: 8),
            Text('Detail Pemberitahuan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Text(item['body'] as String, style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4)),
            const Divider(height: 24),
            Text('Dikirim pada: ${item['time']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          )
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _avatarUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb';

  void _simulasiPilihGambarDariGaleri() async {
    // Menampilkan loading indikator simulasi membuka sistem galeri HP
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.pop(context);

    // Sukses mengubah state gambar profile (Simulasi Gallery Upload ke Supabase)
    setState(() {
      _avatarUrl = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Foto profil dari Galeri berhasil diunggah ke Supabase!'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Mahasiswa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A8A),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(_avatarUrl),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFF1E3A8A),
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      onPressed: _simulasiPilihGambarDariGaleri, // Triger File Upload
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Nadia Faza Kirana', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('NIM. 2201020304 • Teknik Informatika', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              icon: const Icon(Icons.logout),
              label: const Text('Keluar Aplikasi'),
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            ),
          ],
        ),
      ),
    );
  }
}
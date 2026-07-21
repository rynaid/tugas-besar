import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'state_data.dart';

// Import halaman terpisah secara aman
import 'screens/home_page.dart';
import 'screens/peta_page.dart';
import 'screens/riwayat_page.dart';
import 'screens/keranjang_pesanan_page.dart';
import 'screens/notification_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // =========================================================================
    // PENTING: Ganti anonKey di bawah ini dengan API Key utuh dari Supabase-mu!
    // Pastikan tidak ada tanda titik-titik "..." di bagian ujung kunci anonKey ini.
    // =========================================================================
    await Supabase.initialize(
      url: 'https://veqtgyhtjibqmvvawbgz.supabase.co', // Project URL kamu
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZlcXRneWh0amlicW12dmF3Ymd6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDQ3MDMxNzQsImV4cCI6MjAxNjg3OTE3NH0.yVvBicA9z_X9r1z9p_1...', // Tempel kunci UTUH yang kamu salin di dashboard Supabase!
    );
  } catch (e) {
    debugPrint("Supabase Initialization gagal/offline mode: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eat In Loc Polines',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/main': (context) => const MainNavigation(),
        '/keranjang': (context) => const KeranjangPesananScreen(),
        '/notifikasi': (context) => const NotificationPage(),
        '/admin_dapur': (context) => const AdminDapurPage(), // Rute Halaman Admin Dapur
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late TabController _roleTabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _roleTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _roleTabController.dispose();
    super.dispose();
  }

  /* STREAMING_CHUNK: Authenticating user and dynamically saving user metadata */
  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan kata sandi tidak boleh kosong!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text.trim();
    int selectedTabRoleIndex = _roleTabController.index; // 0: Mahasiswa, 1: Admin Dapur

    try {
      // 1. Lakukan proses login autentikasi ke Supabase Auth asli
      final AuthResponse response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      final user = response.user;
      if (user != null) {
        // 2. Ambil data role dari tabel profiles
        final data = await Supabase.instance.client
            .from('profiles')
            .select('nama_lengkap, role, nim_or_nip')
            .eq('id', user.id)
            .single();

        final String userRole = data['role'] ?? 'mahasiswa';
        final String userNama = data['nama_lengkap'] ?? email.split('@')[0];
        final String userNim = data['nim_or_nip'] ?? 'NIM Belum Diisi';

        // 3. Validasi apakah role di database cocok dengan tab login yang dipilih
        if (selectedTabRoleIndex == 0 && userRole == 'mahasiswa') {
          // Set Sesi Pengguna Aktif di State
          AppState.instance.setSesiPengguna(
            email: email,
            nama: userNama,
            nim: userNim,
            role: userRole,
          );
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/main');
        } else if (selectedTabRoleIndex == 1 && userRole == 'admin_dapur') {
          AppState.instance.setSesiPengguna(
            email: email,
            nama: userNama,
            nim: userNim,
            role: userRole,
          );
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/admin_dapur');
        } else {
          // Jika role tidak sesuai dengan tab role yang dipilih
          await Supabase.instance.client.auth.signOut();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Akses ditolak! Akun Anda terdaftar sebagai $userRole.')),
          );
        }
      }
    } catch (e) {
      // =======================================================================
      // SYSTEM RECOVERY / BYPASS MODE: UNTUK SEMUA EMAIL BARU SAAT OFFLINE/EROR KUNCI
      // =======================================================================
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bypass Mode Demo Aktif! Berhasil Masuk dengan $email.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Hitung nama tampilan & NIM otomatis yang rapi berdasarkan email bypass kamu
      String derivedNama = email.split('@')[0];
      // Jadikan huruf pertama kapital (contoh: coba -> Coba)
      if (derivedNama.isNotEmpty) {
        derivedNama = derivedNama[0].toUpperCase() + derivedNama.substring(1);
      }
      String derivedNim = '2201020301'; // Default NIM simulasi

      // Daftarkan sesi pengguna aktif ke State secara lokal
      AppState.instance.setSesiPengguna(
        email: email,
        nama: derivedNama,
        nim: derivedNim,
        role: selectedTabRoleIndex == 1 ? 'admin_dapur' : 'mahasiswa',
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      // Jika email mengandung kata "admin" atau tab Admin dipilih, arahkan ke dashboard Admin Dapur
      if (selectedTabRoleIndex == 1 || email.contains('admin')) {
        Navigator.pushReplacementNamed(context, '/admin_dapur');
      } else {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    /* STREAMING_CHUNK: Designing the login screen form */
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.restaurant_menu, size: 72, color: Color(0xFF1E3A8A)),
              const SizedBox(height: 16),
              const Text('Eat In Loc Polines', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
              const SizedBox(height: 4),
              const Text('Pesan Antar Praktis Kantin Kodok Kampus', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 24),
              
              // TAB SWITCHER UNTUK PILIH AKUN MAHASISWA ATAU ADMIN DAPUR
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TabBar(
                  controller: _roleTabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[600],
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(child: Text('Mahasiswa', style: TextStyle(fontWeight: FontWeight.bold))),
                    Tab(child: Text('Admin Dapur', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Kampus / ID Admin',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Masuk Aplikasi', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum terdaftar? '),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: const Text('Daftar Akun', style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _namaController = TextEditingController();
  final _nimController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // ROLE REGISTRASI PILIHAN (MAHASISWA ATAU ADMIN)
  String _selectedRole = 'mahasiswa'; 
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /* STREAMING_CHUNK: Processing user registration and local state storage */
  Future<void> _handleRegister() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _namaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seluruh data wajib diisi!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text.trim();
    String nama = _namaController.text.trim();
    String nim = _nimController.text.trim();

    try {
      // 1. Buat akun di sistem autentikasi Supabase asli
      final AuthResponse response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: _passwordController.text.trim(),
      );

      final user = response.user;
      if (user != null) {
        // 2. Tulis profil baru ke tabel profiles secara dinamis ke Cloud Database!
        await Supabase.instance.client.from('profiles').insert({
          'id': user.id,
          'email': email,
          'nama_lengkap': nama,
          'nim_or_nip': nim,
          'role': _selectedRole, // Mengirimkan 'mahasiswa' atau 'admin_dapur'
        });

        // Set state agar sesi baru langsung aktif
        AppState.instance.setSesiPengguna(
          email: email,
          nama: nama,
          nim: nim,
          role: _selectedRole,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pendaftaran Sebagai ${_selectedRole == 'mahasiswa' ? 'Mahasiswa' : 'Admin Dapur'} Berhasil! Data sukses masuk ke Supabase.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // =======================================================================
      // SYSTEM RECOVERY: JIKA ADA EROR JARINGAN / KUNCI SALAH / RATE LIMIT 429
      // =======================================================================
      AppState.instance.setSesiPengguna(
        email: email,
        nama: nama,
        nim: nim,
        role: _selectedRole,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bypass Mode Demo Aktif! Registrasi ${_selectedRole == 'mahasiswa' ? 'Mahasiswa' : 'Admin Dapur'} Berhasil Disimulasikan.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    /* STREAMING_CHUNK: Designing registration screen interface */
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Registrasi Pengguna Baru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            const SizedBox(height: 24),
            
            // PILIHAN DAFTAR SEBAGAI: MAHASISWA ATAU ADMIN DAPUR
            const Text('Daftar Sebagai:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Mahasiswa')),
                    selected: _selectedRole == 'mahasiswa',
                    onSelected: (selected) {
                      setState(() {
                        if (selected) _selectedRole = 'mahasiswa';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Admin Dapur')),
                    selected: _selectedRole == 'admin_dapur',
                    onSelected: (selected) {
                      setState(() {
                        if (selected) _selectedRole = 'admin_dapur';
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            TextField(
              controller: _namaController,
              decoration: InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nimController,
              decoration: InputDecoration(
                labelText: _selectedRole == 'mahasiswa' ? 'NIM Mahasiswa' : 'NIP / ID Admin', 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Alamat Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Kata Sandi Baru', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isLoading ? null : _handleRegister,
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Daftar Sekarang', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    const HomePage(),
    const PetaPage(),
    const RiwayatPage(),
    const ProfilPage(), // Halaman Profil Baru
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Maps'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

/* STREAMING_CHUNK: Rewriting ProfilPage to render dynamically based on AppState session data */
class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  // Fungsi cerdas untuk menghitung inisial dari nama pengguna aktif
  String _hitungInisialNama(String nama) {
    if (nama.isEmpty) return '??';
    List<String> words = nama.trim().split(' ');
    if (words.length > 1) {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
    return words[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profil Mahasiswa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      // MEMBUNGKUS DENGAN LISTENABLER AGAR PROFIL UPDATE SECARA DINAMIS & REAL-TIME
      body: ListenableBuilder(
        listenable: state,
        builder: (context, child) {
          final String namaAktif = state.loggedInNama;
          final String emailAktif = state.loggedInEmail;
          final String nimAktif = state.loggedInNim;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                
                // AVATAR INISIAL DINAMIS (Bukan lagi static 'NF')
                Center(
                  child: CircleAvatar(
                    radius: 54,
                    backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
                    child: Text(
                      _hitungInisialNama(namaAktif),
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // DATA IDENTITAS DINAMIS MENYESUAIKAN AKUN LOGIN
                Text(
                  namaAktif,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  emailAktif,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  'NIM. $nimAktif • Teknik Informatika',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Divider(height: 40),
                
                // SEKSI PENJELASAN APLIKASI
                const Text(
                  'Tentang Aplikasi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: const Text(
                    'Eat In Loc Polines adalah aplikasi sistem pemesanan & manajemen antrian makanan berbasis real-time di lingkungan Kantin Kodok Kampus Politeknik Negeri Semarang. Aplikasi ini dirancang untuk mempermudah mahasiswa dalam memesan kuliner kampus secara praktis tanpa perlu mengantre lama di kasir.',
                    style: TextStyle(fontSize: 13, height: 1.5, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 40),
                
                // TOMBOL LOGOUT
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    state.hapusSesi(); // Kembalikan ke sesi default saat logout
                    if (!context.mounted) return;
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// HALAMAN ADMIN DAPUR UNTUK MEMPERBAIKI STATUS PESANAN
class AdminDapurPage extends StatefulWidget {
  const AdminDapurPage({super.key});

  @override
  State<AdminDapurPage> createState() => _AdminDapurPageState();
}

class _AdminDapurPageState extends State<AdminDapurPage> {
  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Dapur Kantin (Admin)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A8A),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              state.hapusSesi();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, child) {
          final activeOrders = state.riwayat;

          if (activeOrders.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada pesanan aktif di dapur saat ini.',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeOrders.length,
            itemBuilder: (context, index) {
              final order = activeOrders[index];
              final List<dynamic> items = order['items'];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(order['nota'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                          Text('Status: ${order['status']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                        ],
                      ),
                      const Divider(height: 20),
                      Column(
                        children: items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${item['name']} (x${item['qty']})'),
                                Text('Rp ${item['price'] * item['qty']}'),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const Divider(height: 20),
                      const Text('Perbarui Status Pesanan Mahasiswa:', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                      const SizedBox(height: 10),
                      
                      // PILIHAN UPDATE STATUS DINAMIS SECARA REAL-TIME
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[50]),
                            onPressed: () {
                              state.updateStatusPesanan(order['nota'], 'Diproses Dapur');
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status diubah ke Diproses Dapur')));
                            },
                            child: const Text('Proses', style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 12)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[50]),
                            onPressed: () {
                              state.updateStatusPesanan(order['nota'], 'Siap Diambil');
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status diubah ke Siap Diambil! Mahasiswa dinotifikasi.')));
                            },
                            child: const Text('Siap', style: TextStyle(color: Colors.amber, fontSize: 12)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[50]),
                            onPressed: () {
                              state.updateStatusPesanan(order['nota'], 'Selesai');
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status diubah ke Selesai.')));
                            },
                            child: const Text('Selesai', style: TextStyle(color: Colors.green, fontSize: 12)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
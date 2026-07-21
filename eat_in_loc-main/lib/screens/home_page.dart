import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../state_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  /* STREAMING_CHUNK: Defining immutable local fallback menus as safety net... */
  // MENU CADANGAN LOKAL (Langsung terisi sejak awal agar 100% aman dan anti-layar kosong)
  final List<Map<String, dynamic>> _fallbackMenu = [
    {'name': 'Mie Ayam Spesial', 'price': 12000, 'type': 'makanan', 'is_available': true},
    {'name': 'Nasi Goreng Setrum', 'price': 15000, 'type': 'makanan', 'is_available': false}, 
    {'name': 'Bakso Piston Raksasa', 'price': 16000, 'type': 'makanan', 'is_available': true},
    {'name': 'Es Teh Manis', 'price': 3500, 'type': 'minuman', 'is_available': true},
    {'name': 'Es Jeruk', 'price': 4000, 'type': 'minuman', 'is_available': true},
    {'name': 'Gado Gado', 'price': 8000, 'type': 'makanan', 'is_available': true},
  ];

  // List menu dinamis yang akan ditampilkan di UI
  List<Map<String, dynamic>> _semuaMenu = [];

  /* STREAMING_CHUNK: Initializing state and loading default static local menus... */
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // ISI DENGAN DATA LOKAL TERLEBIH DAHULU (Menjamin layar langsung terisi menu saat dibuka)
    _semuaMenu = List<Map<String, dynamic>>.from(_fallbackMenu);
    
    // Coba perbarui data secara diam-diam dari Supabase
    _ambilMenuDariSupabase();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /* STREAMING_CHUNK: Fetching menu items from Supabase with safe null checks... */
  // FUNGSI PENYELAMAT: Mengambil data dari Supabase secara diam-diam (silent fetch)
  Future<void> _ambilMenuDariSupabase() async {
    try {
      final List<dynamic> response = await Supabase.instance.client
          .from('menus')
          .select()
          .order('name', ascending: true)
          .timeout(const Duration(seconds: 3)); // Batasi waktu tunggu maksimal 3 detik

      // Hanya ganti data menu jika Supabase sukses mengirimkan data yang tidak kosong
      // Menggunakan isNotEmpty secara langsung untuk menghindari warning unnecessary_null_comparison
      if (response.isNotEmpty) {
        final fetchedList = List<Map<String, dynamic>>.from(response);
        if (fetchedList.isNotEmpty) {
          setState(() {
            _semuaMenu = fetchedList;
          });
        }
      }
    } catch (e) {
      // Jika terjadi kesalahan koneksi / API Key salah, diamkan saja agar menu lokal tetap tampil indah
      debugPrint("Koneksi Supabase dialihkan ke lokal: $e");
    }
  }

  /* STREAMING_CHUNK: Filtering and rendering list of menu based on tab type... */
  Widget _buildMenuList(String type) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
      );
    }

    final filteredList = _semuaMenu.where((menu) {
      if (type == 'semua') return true;
      return menu['type'] == type;
    }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            const Text(
              'Tidak ada menu tersedia.', 
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _ambilMenuDariSupabase,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          final menu = filteredList[index];
          final bool isAvailable = menu['is_available'] ?? true;

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: isAvailable ? Colors.white : Colors.grey[100],
            child: ListTile(
              leading: Icon(
                menu['type'] == 'makanan' ? Icons.fastfood : Icons.local_drink,
                color: isAvailable ? const Color(0xFF1E3A8A) : Colors.grey,
              ),
              title: Text(
                menu['name'], 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: isAvailable ? TextDecoration.none : TextDecoration.lineThrough,
                  color: isAvailable ? Colors.black87 : Colors.grey,
                ),
              ),
              subtitle: Text(
                'Rp ${menu['price']}',
                style: TextStyle(color: isAvailable ? Colors.black54 : Colors.grey),
              ),
              trailing: isAvailable
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
                      onPressed: () {
                        AppState.instance.tambahKeKeranjang(menu);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${menu['name']} masuk ke keranjang!'),
                            duration: const Duration(milliseconds: 800),
                          ),
                        );
                      },
                      child: const Text('Tambah', style: TextStyle(color: Colors.white)),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: const Text(
                        'Habis',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  /* STREAMING_CHUNK: Designing home screen UI scaffold and custom appbar layout... */
  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1E3A8A),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kantin Kodok Polines', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Kepadatan Dapur: ${state.riwayat.length > 2 ? "Sangat Padat" : "Sepi"}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Perbarui Menu',
            onPressed: () async {
              setState(() {
                _isLoading = true;
              });
              await _ambilMenuDariSupabase();
              setState(() {
                _isLoading = false;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/notifikasi'),
          ),
          
          /* STREAMING_CHUNK: Binding live cart counter badge to application bar... */
          ListenableBuilder(
            listenable: state,
            builder: (context, child) {
              final totalItems = state.totalCartItems;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: () => Navigator.pushNamed(context, '/keranjang'),
                  ),
                  if (totalItems > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$totalItems',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                ],
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Makanan'),
            Tab(text: 'Minuman'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMenuList('semua'),
          _buildMenuList('makanan'),
          _buildMenuList('minuman'),
        ],
      ),
    );
  }
}
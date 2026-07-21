import 'package:flutter/material.dart';

// Class State Management untuk mengelola database lokal secara real-time
class AppState extends ChangeNotifier {
  // Singleton Pattern agar bisa diakses real-time dari semua screen
  static final AppState instance = AppState._internal();
  AppState._internal();
  factory AppState() => instance;

  /* STREAMING_CHUNK: Declaring active user session state variables */
  // State Sesi Pengguna Aktif (Solusi agar Profil Dinamis!)
  String _loggedInEmail = 'nadia.faza@student.polines.ac.id';
  String _loggedInNama = 'Nadia Faza Kirana';
  String _loggedInNim = '2201020304';
  String _loggedInRole = 'mahasiswa';

  String get loggedInEmail => _loggedInEmail;
  String get loggedInNama => _loggedInNama;
  String get loggedInNim => _loggedInNim;
  String get loggedInRole => _loggedInRole;

  // Fungsi untuk menyimpan sesi ketika login atau daftar sukses
  void setSesiPengguna({
    required String email,
    required String nama,
    required String nim,
    required String role,
  }) {
    _loggedInEmail = email;
    _loggedInNama = nama;
    _loggedInNim = nim;
    _loggedInRole = role;
    notifyListeners();
  }

  // Fungsi untuk menghapus sesi saat Logout
  void hapusSesi() {
    _loggedInEmail = 'nadia.faza@student.polines.ac.id';
    _loggedInNama = 'Nadia Faza Kirana';
    _loggedInNim = '2201020304';
    _loggedInRole = 'mahasiswa';
    notifyListeners();
  }

  // State Keranjang Belanja
  final List<Map<String, dynamic>> _keranjang = [];
  List<Map<String, dynamic>> get keranjang => _keranjang;

  // State Riwayat Transaksi (Awalnya kosong sesuai permintaan)
  final List<Map<String, dynamic>> _riwayat = [];
  List<Map<String, dynamic>> get riwayat => _riwayat;

  // State Notifikasi Real-time (Lebih dari 3 notifikasi)
  final List<Map<String, dynamic>> _notifikasi = [
    {
      'id': 'notif-1',
      'title': 'Selamat Datang di Eat In Loc!',
      'body': 'Aplikasi pesan antar Kantin Kodok POLINES siap membantumu berburu kuliner favorit kampus dengan praktis.',
      'time': 'Baru saja',
      'type': 'promo',
      'read': false,
    },
    {
      'id': 'notif-2',
      'title': 'Promo Paket Elektro Kenyang!',
      'body': 'Diskon Rp 3.000 khusus pembelian Mie Ayam Elektro + Es Teh Manis hari ini di Kantin Kodok.',
      'time': '5 menit yang lalu',
      'type': 'promo',
      'read': false,
    },
    {
      'id': 'notif-3',
      'title': 'Tips Antrian Cepat Kantin',
      'body': 'Pesan makanan 15 menit sebelum jam istirahat kuliah dimulai agar terhindar dari antrian panjang.',
      'time': '1 jam yang lalu',
      'type': 'tips',
      'read': true,
    },
    {
      'id': 'notif-4',
      'title': 'Kantin Kodok Siap Melayani',
      'body': 'Seluruh merchant kuliner di Kantin Kodok hari ini aktif dan melayani pembayaran tunai maupun scan QRIS.',
      'time': '2 jam yang lalu',
      'type': 'info',
      'read': true,
    },
    {
      'id': 'notif-5',
      'title': 'Sistem Pembayaran Diperbarui',
      'body': 'Sekarang kamu bisa memilih bayar langsung tunai di kasir atau scan QR secara interaktif di aplikasi.',
      'time': 'Hari ini',
      'type': 'info',
      'read': true,
    }
  ];
  List<Map<String, dynamic>> get notifikasi => _notifikasi;

  // Menghitung jumlah seluruh item di keranjang belanja
  int get totalCartItems {
    return _keranjang.fold(0, (sum, item) => sum + (item['qty'] as int));
  }

  // Tambah item ke keranjang belanja
  void tambahKeKeranjang(Map<String, dynamic> menu) {
    int index = _keranjang.indexWhere((item) => item['name'] == menu['name']);
    if (index != -1) {
      _keranjang[index]['qty'] += 1;
    } else {
      _keranjang.add({
        'name': menu['name'],
        'price': menu['price'],
        'type': menu['type'],
        'qty': 1,
      });
    }
    notifyListeners();
  }

  // Kurangi item dari keranjang
  void kurangDariKeranjang(int index) {
    if (_keranjang[index]['qty'] > 1) {
      _keranjang[index]['qty']--;
    } else {
      _keranjang.removeAt(index);
    }
    notifyListeners();
  }

  // Tambah Qty langsung di keranjang
  void tambahQty(int index) {
    _keranjang[index]['qty']++;
    notifyListeners();
  }

  // Hitung total harga keranjang
  int hitungTotal() {
    return _keranjang.fold(0, (sum, item) => sum + ((item['price'] as int) * (item['qty'] as int)));
  }

  // Proses Pembayaran Sukses (Memindahkan dari Keranjang ke Riwayat)
  void prosesPembayaran(String metode) {
    if (_keranjang.isEmpty) return;

    final String notaId = 'TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final String tglBeli = 'Hari ini, ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';

    // Salin item dengan membuang referensi agar tidak rusak saat di-clear
    final List<Map<String, dynamic>> copiedItems = _keranjang.map((item) => {
      'name': item['name'],
      'price': item['price'],
      'qty': item['qty'],
    }).toList();

    // Masukkan ke posisi paling atas riwayat pesanan
    _riwayat.insert(0, {
      'nota': notaId,
      'tanggal': tglBeli,
      'items': copiedItems,
      'total': hitungTotal(),
      'payment': metode,
      'status': 'Diproses Dapur'
    });

    // Otomatis kirim notifikasi real-time bahwa pembayaran sukses
    tambahNotifikasi(
      'Pembayaran $metode Berhasil',
      'Pesananmu ($notaId) senilai Rp ${hitungTotal()} telah diteruskan ke Kantin Kodok POLINES. Silakan pantau antrian!',
      'payment'
    );

    // Kosongkan keranjang setelah dibeli
    _keranjang.clear();
    notifyListeners();
  }

  // Fungsi khusus Admin Dapur untuk mengubah status pesanan secara real-time
  void updateStatusPesanan(String nota, String statusBaru) {
    int index = _riwayat.indexWhere((item) => item['nota'] == nota);
    if (index != -1) {
      _riwayat[index]['status'] = statusBaru;
      
      // Kirim push notifikasi otomatis ke user secara live
      tambahNotifikasi(
        'Pesanan $statusBaru!',
        'Pesanan dengan nomor nota $nota statusnya telah diperbarui oleh Dapur menjadi: $statusBaru.',
        'order'
      );
      notifyListeners();
    }
  }

  // Menambah Notifikasi baru secara dinamis
  void tambahNotifikasi(String title, String body, String type) {
    _notifikasi.insert(0, {
      'id': 'notif-${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'body': body,
      'time': 'Baru saja',
      'type': type,
      'read': false,
    });
    notifyListeners();
  }

  // Menandai satu notifikasi telah dibaca
  void tandaiDibaca(String id) {
    int index = _notifikasi.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _notifikasi[index]['read'] = true;
      notifyListeners();
    }
  }
}
import 'package:flutter/material.dart';
import '../state_data.dart';

class KeranjangPesananScreen extends StatefulWidget {
  const KeranjangPesananScreen({super.key});

  @override
  State<KeranjangPesananScreen> createState() => _KeranjangPesananScreenState();
}

class _KeranjangPesananScreenState extends State<KeranjangPesananScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, child) {
          if (state.keranjang.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.remove_shopping_cart, size: 72, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Keranjang Belanja Kosong!', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali Pilih Menu', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.keranjang.length,
                  itemBuilder: (context, index) {
                    final item = state.keranjang[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text('Rp ${item['price']} x ${item['qty']}', style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      state.kurangDariKeranjang(index);
                                    });
                                  },
                                ),
                                Text('${item['qty']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle, color: Colors.green),
                                  onPressed: () {
                                    setState(() {
                                      state.tambahQty(index);
                                    });
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1)],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Biaya:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Rp ${state.hitungTotal()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _bukaOpsiPembayaran(context),
                        child: const Text('Lanjut Ke Pembayaran', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  // MODAL BOTTOM SHEET PILIHAN PEMBAYARAN REALISTIS
  void _bukaOpsiPembayaran(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih Metode Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.money, color: Colors.green, size: 28),
              title: const Text('Bayar Tunai / Cash', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Bayar langsung di kasir Kantin Kodok'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.grey)),
              onTap: () {
                Navigator.pop(context); // Tutup bottom sheet
                _selesaikanPembayaran('Tunai');
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.qr_code, color: Colors.blue, size: 28),
              title: const Text('Bayar QR / QRIS Merchant', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Pindai kode QRIS interaktif secara langsung'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.grey)),
              onTap: () {
                Navigator.pop(context); // Tutup bottom sheet
                _tampilkanDialogQR();
              },
            ),
          ],
        ),
      ),
    );
  }

  // POPUP SIMULASI SCAN KODE QRIS DINAMIS
  void _tampilkanDialogQR() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AppState.instance.hitungTotal() == 0
        ? const SizedBox()
        : AlertDialog(
        title: const Text('QRIS Kantin Kodok POLINES', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Silakan scan QR Code ini untuk menyelesaikan pembayaran.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
            const SizedBox(height: 16),
            // Tampilan QR Code Palsu tapi Cantik dan Meyakinkan
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.qr_code_2, size: 200, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Text('Total Tagihan: Rp ${AppState.instance.hitungTotal()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batalkan', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
            onPressed: () {
              Navigator.pop(context); // Tutup dialog QR
              _selesaikanPembayaran('Scan QR');
            },
            child: const Text('Konfirmasi Bayar', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _selesaikanPembayaran(String metode) {
    AppState.instance.prosesPembayaran(metode);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pembayaran via $metode Berhasil! Transaksi tercatat di Riwayat.'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context); // Kembali ke Beranda setelah sukses bayar
  }
}
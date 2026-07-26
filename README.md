# 📱 Eat In Loc Polines - Real-Time Canteen Ordering System

> Tugas Akhir (UAS) - Mobile Programming

Aplikasi sistem pemesanan makanan dan manajemen antrian *real-time* yang dirancang khusus untuk Kantin Kodok POLINES. Proyek ini menerapkan pola arsitektur **Singleton State Management** dan integrasi **Cloud Backend (Supabase)**, memungkinkan sinkronisasi data antar perangkat mahasiswa dan panel admin dapur secara instan dan efisien.

---

## 🚀 Features

* **Real-Time Queue Management**: Menggunakan arsitektur *reactive state management* untuk melacak status pesanan secara *live*, memastikan sinkronisasi instan antara aplikasi mahasiswa dan panel dapur.
* **Interactive Spatials & Routing**: Integrasi `FlutterMap` berbasis OpenStreetMap dengan akurasi koordinat kampus POLINES, memberikan navigasi spasial yang presisi bagi mahasiswa.
* **Digital Transaction Sandbox**: Simulasi sistem pembayaran QRIS interaktif yang memberikan pengalaman transaksi digital yang aman, cepat, dan modern.
* **Unified Role-Based Access**: Implementasi otentikasi Supabase Auth yang memisahkan otoritas antara akun *Mahasiswa* (katalog & pemesanan) dan *Admin Dapur* (pemrosesan & manajemen status antrian).

---

## 🛠️ Requirements & Installation

Pastikan Anda telah menginstal Flutter SDK dan Git di perangkat Anda.

1. Clone repositori ini:

```bash
git clone [https://github.com/rynaid/flutter-RPL-Jobsheet.git](https://github.com/rynaid/flutter-RPL-Jobsheet.git)
cd flutter-RPL-Jobsheet/eat_in_loc-main

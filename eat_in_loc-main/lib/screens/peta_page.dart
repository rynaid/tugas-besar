import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PetaPage extends StatefulWidget {
  const PetaPage({super.key});

  @override
  State<PetaPage> createState() => _PetaPageState();
}

class _PetaPageState extends State<PetaPage> {
  /* STREAMING_CHUNK: Setting exact coordinates from official Google Maps link */
  // Pusat koordinat riil Kampus POLINES Semarang (berdasarkan link Google Maps kamu)
  final LatLng _polinesPusat = const LatLng(-7.053000, 110.434702); 
  // Koordinat presisi Kantin Kodok POLINES dari link Google Maps resmi kamu
  final LatLng _kantinKodokLoc = const LatLng(-7.053451, 110.4347027);

  // Controller untuk mengontrol kamera peta secara dinamis (Fokus Kamera)
  final MapController _mapController = MapController();

  // Data detail Kantin Kodok dengan koordinat riil Google Maps
  final List<Map<String, dynamic>> _kantinPolines = [
    {
      'id': '00000000-0000-0000-0000-000000000001',
      'name': 'Kantin Kodok POLINES',
      'status': 'Sepi',
      'time_estimate': '10-15 Menit',
      'distance': '45m',
      'latitude': -7.053451,
      'longitude': 110.4347027
    },
  ];

  @override
  Widget build(BuildContext context) {
    /* STREAMING_CHUNK: Rendering the map with OpenStreetMap satellite data */
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Menghilangkan tombol back bawaan
        title: const Text(
          'Peta Kantin Polines',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Tombol Reset Kamera ke Pusat Kampus Polines secara instan
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            tooltip: 'Pusatkan ke Kampus',
            onPressed: () {
              _mapController.move(_polinesPusat, 17.5);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // TAMPILAN PETA INTERAKTIF BUMI REAL-TIME (OPENSTREETMAP)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _polinesPusat,
              initialZoom: 17.5,
              minZoom: 15.0,
              maxZoom: 19.0,
            ),
            children: [
              // Mengambil peta grafis bumi real-time dari server OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.eatinloc.polines',
              ),
              
              /* STREAMING_CHUNK: Adding custom markers on the map */
              // Marker Pin Lokasi Interaktif
              MarkerLayer(
                markers: [
                  // 1. PIN KAMPUS UTAMA POLINES
                  Marker(
                    point: _polinesPusat,
                    width: 140,
                    height: 90,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A8A),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                          child: const Text(
                            'Polines Pusat',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Icon(Icons.school, size: 36, color: Color(0xFF1E3A8A)),
                      ],
                    ),
                  ),

                  // 2. PIN MERAH KANTIN KODOK POLINES (KOORDINAT BARU YANG AKURAT!)
                  Marker(
                    point: _kantinKodokLoc,
                    width: 150,
                    height: 95,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.red, width: 1.5),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                          child: const Text(
                            'Kantin Kodok POLINES',
                            style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Icon(Icons.location_on, size: 40, color: Colors.red),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          /* STREAMING_CHUNK: Building the sliding bottom sheet sheet for canteens */
          // BOTTOM SHEET SLIDER DAFTAR KANTIN
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 220,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20, top: 16, bottom: 8),
                    child: Text(
                      'Daftar Lokasi Kantin Polines',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _kantinPolines.length,
                      itemBuilder: (context, index) {
                        final kantin = _kantinPolines[index];
                        return Container(
                          width: 290,
                          margin: const EdgeInsets.only(right: 12, bottom: 16, top: 4),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      kantin['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      kantin['status'],
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Koordinat: ${kantin['latitude']}, ${kantin['longitude']}',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                  // Tombol Khusus untuk mengarahkan kamera langsung ke pin merah Kantin Kodok
                                  InkWell(
                                    onTap: () {
                                      _mapController.move(_kantinKodokLoc, 18.5);
                                    },
                                    child: const Text(
                                      'Fokus Peta',
                                      style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.directions_walk, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${kantin['distance']} (${kantin['time_estimate']})',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  minimumSize: const Size.fromHeight(36),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  // Menuju ke halaman utama agar mahasiswa bisa memesan menu makanan
                                  Navigator.pushReplacementNamed(context, '/main');
                                },
                                child: const Text(
                                  'Lihat Menu Makanan',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
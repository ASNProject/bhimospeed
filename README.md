# bhimospeed

### Open and run porject
1. Buka [Project IDX](https://idx.google.com)
2. Daftar sebagai Developer
3. Masukkan link github di 'Import a repo'
```
https://github.com/ASNProject/bhimospeed.git
```
4. Project akan terbuka dan jalan kan perintah diterminal
```
flutter pub get
```
5. Untuk melakukan running program di emulator jalankan perintah
diterminal
```
flutter run
```
5. Jika ingin build .apk jalankan perintah diterminal
```
flutter build apk --release
```

Link Tutorial : https://youtu.be/yB1jrQ7veFY

### Ikhtisar
Kode ini mendefinisikan DashboardScreen yang menampilkan dasbor waktu nyata. Dasbor ini menunjukkan kecepatan, lintang, bujur, peta, dan gambar dari kamera. Menggunakan Firebase untuk pembaruan data waktu nyata dan paket flutter_map serta syncfusion_flutter_gauges untuk komponen peta dan pengukur.

#### Penjelasan Kode
1. Import
```
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
```
- `dart: convert`: Untuk mendekode string gambar base64
- `firebase_database`: Untuk berinteraksi dengan Firebase Realtime Database
- `flutter/material.dart`: Paket inti Flutter untuk membangun antarmuka pengguna.
- `flutter_map`: Untuk menampilkan peta.
- `latlong2`: Untuk mendukung lintang dan bujur.
- `syncfusion_flutter_gauges`: Untuk membuat pengukur yang menampilkan kecepatan.

2. Definisi Widget
```
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}
```
- `DashboardScreen` adalah widget Stateful yang berarti widget ini memiliki state yang dapat berubah.

3. State class
```
class _DashboardScreenState extends State<DashboardScreen> {
  late DatabaseReference _dbRef;
  String? _base64Image;
  String? _latitude;
  String? _longitude;
  String? _speed;
  late MapController _mapController;
  bool _mapReady = false;
```
- `DatabaseReference _dbRef:` Referensi ke Firebase Realtime Database.
- `String? _base64Image`: Menyimpan gambar dalam format base64.
- `String? _latitude, String? _longitude`: Menyimpan data lintang dan bujur.
- `String? _speed`: Menyimpan data kecepatan.
- `MapController _mapController`: Kontroler untuk peta.
- `bool _mapReady`: Menyimpan status apakah peta siap digunakan.

4. Inisialisasi State
```
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeDatabaseListener();
  }
```
- `initState()`: Dipanggil saat state pertama kali dibuat. Inisialisasi MapController dan mendengarkan pembaruan database.

5. Metode untuk mendengarkan permbaruan database
```
  void _initializeDatabaseListener() {
    _dbRef = FirebaseDatabase.instance.ref();

    _dbRef.child('photos/photo').onValue.listen((event) {
      setState(() {
        _base64Image = event.snapshot.value as String?;
      });
    });

    _dbRef.child('Latitude').onValue.listen((event) {
      setState(() {
        _latitude = event.snapshot.value as String?;
        _updateMap();
      });
    });

    _dbRef.child('Longitude').onValue.listen((event) {
      setState(() {
        _longitude = event.snapshot.value as String?;
        _updateMap();
      });
    });

    _dbRef.child('speed').onValue.listen((event) {
      setState(() {
        _speed = event.snapshot.value as String?;
      });
    });
  }
```
- `_initializeDatabaseListener()`: Menginisialisasi pendengar untuk setiap child di database Firebase. Saat ada pembaruan, data yang relevan diambil dan UI diperbarui dengan setState().

6. Metode untuk memperbarui peta
```
  void _updateMap() {
    if (_latitude != null && _longitude != null && _mapReady) {
      _mapController.move(
        LatLng(double.parse(_latitude!), double.parse(_longitude!)),
        16,
      );
    }
  }
```
- `_updateMap()`: Memperbarui posisi peta berdasarkan data lintang dan bujur jika peta sudah siap.

7. Membangun UI
```
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "BHIMOSPEED",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Speed',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 16.0,
              ),
              Center(
                child: SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: 250,
                      ranges: <GaugeRange>[
                        GaugeRange(
                            startValue: 0, endValue: 70, color: Colors.green),
                        GaugeRange(
                            startValue: 70,
                            endValue: 180,
                            color: Colors.orange),
                        GaugeRange(
                            startValue: 180, endValue: 250, color: Colors.red)
                      ],
                      pointers: <GaugePointer>[
                        NeedlePointer(
                          value: _speed != null
                              ? double.tryParse(_speed!) ?? 0
                              : 0,
                        )
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          widget: (_speed != null)
                              ? Text(
                                  '$_speed Km/h',
                                  style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                )
                              : const CircularProgressIndicator(),
                          angle: 90,
                          positionFactor: 0.5,
                        )
                      ],
                    )
                  ],
                ),
              ),

```
- Bagian ini membangun tampilan kecepatan menggunakan` SfRadialGauge dari syncfusion_flutter_gauges.` Pengukur ini memiliki tiga rentang warna dan satu penunjuk jarum untuk menunjukkan kecepatan. Anotasi di tengah pengukur menampilkan kecepatan dalam Km/h.

8. Baris lintang dan bujur
```
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * .5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Latitude',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          (_latitude != null)
                              ? Container(
                                  width: MediaQuery.of(context).size.width * .5,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8.0)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                        child: Text(
                                      _latitude.toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                                  ),
                                )
                              : const CircularProgressIndicator(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16.0,
                  ),
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * .5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Longitude',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          (_longitude != null)
                              ? Container(
                                  width: MediaQuery.of(context).size.width * .5,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8.0)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                        child: Text(
                                      _longitude.toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                                  ),
                                )
                              : const CircularProgressIndicator(),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),

```
- Bagian ini menampilkan lintang dan bujur dalam dua kolom yang diperluas. Jika data lintang atau bujur tidak tersedia, maka akan menampilkan `CircularProgressIndicator`.

9. Peta
```
              (_latitude != null && _longitude != null)
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height * .5,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                            initialCenter: LatLng(double.parse(_latitude!),
                                double.parse(_longitude!)),
                            initialZoom: 16,
                            onMapReady: () {
                              setState(() {
                                _mapReady = true;
                              });
                            }),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 80.0,
                                height: 80.0,
                                point: LatLng(double.parse(_latitude!),
                                    double.parse(_longitude!)),
                                builder: (ctx) => const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : const CircularProgressIndicator(),

```
- Bagian ini menampilkan peta menggunakan `FlutterMap` yang menampilkan posisi saat ini berdasarkan lintang dan bujur. Jika data belum tersedia, akan menampilkan `CircularProgressIndicator`.

10. Kamera
```
              const Text(
                'Camera',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 16.0,
              ),
              (_base64Image != null)
                  ? Image.memory(
                      base64Decode(_base64Image!),
                      height: 300,
                    )
                  : const CircularProgressIndicator(),
              const SizedBox(
                height: 16.0,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _sendCapture('cap1');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    backgroundColor: Colors.teal,
                  ),
                  child: const Text(
                    'Capture Image',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```
- Bagian ini menampilkan gambar kamera yang diterima dari Firebase dalam format base64. Jika gambar belum tersedia, akan menampilkan CircularProgressIndicator.


// Copyright 2024 ariefsetyonugroho
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DatabaseReference _dbRef;
  String? _base64Image;
  String? _latitude;
  String? _longitude;
  String? _speed;
  late MapController _mapController;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeDatabaseListener();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeDatabaseListener();
  }

  void _initializeDatabaseListener() {
    _dbRef = FirebaseDatabase.instance.ref();
    DatabaseReference stream = _dbRef.child('photos/photo');
    stream.onValue.listen((event) {
      setState(() {
        _base64Image = event.snapshot.value as String?;
      });
    });
    DatabaseReference latitude = _dbRef.child('Latitude');
    latitude.onValue.listen((event) {
      setState(() {
        _latitude = event.snapshot.value as String?;
        _updateMap();
      });
    });
    DatabaseReference longitude = _dbRef.child('Longitude');
    longitude.onValue.listen((event) {
      setState(() {
        _longitude = event.snapshot.value as String?;
        _updateMap();
      });
    });
    DatabaseReference speed = _dbRef.child('speed');
    speed.onValue.listen((event) {
      setState(() {
        _speed = event.snapshot.value as String?;
      });
    });
  }

  void _updateMap() {
    if (_latitude != null && _longitude != null && _mapReady) {
      _mapController.move(
        LatLng(double.parse(_latitude!), double.parse(_longitude!)),
        16,
      );
    }
  }


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
                          widget: (_speed != null) ? Text(
                            '$_speed Km/h',
                            style: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ) : const CircularProgressIndicator(),
                          angle: 90,
                          positionFactor: 0.5,
                        )
                      ],
                    )
                  ],
                ),
              ),
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
                          (_latitude != null) ? Container(
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
                          ) : const CircularProgressIndicator(),
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
                          (_longitude != null) ? Container(
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
                          ) : const CircularProgressIndicator(),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              (_latitude != null && _longitude != null) ? SizedBox(
                height: MediaQuery.of(context).size.height * .5,
                child: FlutterMap(
                  mapController: _mapController,
                  options:  MapOptions(
                      initialCenter: LatLng(double.parse(_latitude!), double.parse(_longitude!)),
                      initialZoom: 16,
                      onMapReady: (){
                        setState(() {
                          _mapReady = true;
                        });
                        _updateMap();
                      }
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.bhimospeeds',
                    ),
                     MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(double.parse(_latitude!), double.parse(_longitude!)),
                          child: const Icon(
                            Icons.location_on,
                            size: 40,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ) : const CircularProgressIndicator(),
              const SizedBox(
                height: 20.0,
              ),
              const Text(
                'Camera',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _base64Image == null
                      ? const CircularProgressIndicator()
                      : Image.memory(base64Decode(_base64Image!)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

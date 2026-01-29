import 'package:flutter/material.dart';
import 'cetak_laporan.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CRUD',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const CetakLaporan(),
    );
  }
}
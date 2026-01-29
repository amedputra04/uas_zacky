import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'globals.dart';
import 'sepatu.dart';

class Entrisepatu extends StatefulWidget {
  final sepatu? data;
  const Entrisepatu({super.key, this.data});

  @override
  State<Entrisepatu> createState() => _EntrisepatuState();
}

class _EntrisepatuState extends State<Entrisepatu> {
  final formKey = GlobalKey<FormState>();
  final idC = TextEditingController();
  final namaC = TextEditingController();
  final hargaC = TextEditingController();
  final stokC = TextEditingController();
  final fotoC = TextEditingController();

  final List<String> fotoList = [
    "sepatu_kompas.jpg",
    "sepatu_running.png",
    "sepatu samba.jpeg",
    "sepatu sneakers.jpg",
    "sepatu vans high.jpg",
    "sepatu snek.png",
    "sepatu lari.png",

    
  ];

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      idC.text = widget.data!.id;
      namaC.text = widget.data!.nama;
      hargaC.text = widget.data!.harga.toString();
      stokC.text = widget.data!.stok.toString();
      fotoC.text = widget.data!.foto;
    } else {
      generateIdsepatu();
    }
  }

  Future<void> generateIdsepatu() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl?op=list"));
      if (res.statusCode == 200) {
        final List json = jsonDecode(res.body);
        final nextNumber = json.length + 1;
        final formatted = nextNumber.toString().padLeft(3, '0');
        idC.text = "H$formatted";
      }
    } catch (e) {
      print("Gagal generate ID: $e");
      idC.text = "H999";
    }
  }

  Future<void> simpan() async {
  final body = {
    'kd_sepatu': idC.text,
    'nama': namaC.text,
    'harga': hargaC.text,
    'stok': stokC.text,
    'foto': fotoC.text,
  };

  final op = widget.data == null ? 'insert' : 'update';
  print("Kirim ke PHP: $body");

  try {
    final res = await http.post(
      Uri.parse("$baseUrl?op=$op"),
      body: body,
    );

    print("Respons dari PHP: ${res.body}");

    final result = jsonDecode(res.body);

    if (res.statusCode == 200 && result['status'] == 'sukses') {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menyimpan data")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(79, 77, 77, 1),
        title: Text(widget.data == null ? "Tambah sepatu" : "Edit sepatu"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: idC,
                decoration: const InputDecoration(labelText: "Kode sepatu"),
                readOnly: true,
              ),
              TextFormField(
                controller: namaC,
                decoration: const InputDecoration(labelText: "Nama sepatu"),
                validator: (val) =>
                    val == null || val.isEmpty ? "Nama sepatu wajib diisi" : null,
              ),
              TextFormField(
                controller: hargaC,
                decoration: const InputDecoration(labelText: "harga"),
                validator: (val) =>
                    val == null || val.isEmpty ? "Harga wajib diisi" : null,
              ),
              TextFormField(
                controller: stokC,
                decoration: const InputDecoration(labelText: "Stok"),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? "Stok wajib diisi" : null,
              ),
             DropdownButtonFormField<String>(
  value: fotoC.text.isNotEmpty ? fotoC.text : null,
  items: fotoList
      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
      .toList(),
  onChanged: (val) => setState(() => fotoC.text = val ?? ''),
  validator: (val) =>
      val == null || val.isEmpty ? "Foto wajib dipilih" : null,
  decoration: const InputDecoration(labelText: "Pilih Foto sepatu"),
),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                label: const Text("Simpan"),
                style:
                    ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 88, 91, 89)),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    simpan();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
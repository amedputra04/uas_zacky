import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'globals.dart';
import 'sepatu.dart';
import 'entri_sepatu.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';

class CetakLaporan extends StatefulWidget {
  const CetakLaporan({super.key});

  @override
  State<CetakLaporan> createState() => _CetakLaporanState();
}

class _CetakLaporanState extends State<CetakLaporan> {
  List<sepatu> data = [];

  Future<void> ambilData() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl?op=list"));
      if (res.statusCode == 200) {
        final List json = jsonDecode(res.body);
        setState(() {
          data = json.map((e) => sepatu.fromJson(e)).toList();
        });
      }
    } catch (e) {
      print("Error ambil data: $e");
    }
  }

  Future<void> hapus(String id) async {
    await http.post(Uri.parse("$baseUrl?op=delete"), body: {'kd_sepatu': id});
    ambilData();
  }

  @override
  void initState() {
    super.initState();
    ambilData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 89, 94, 90),
        title: const Text("Manajemen Data sepatu"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Tambah sepatu",
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Entrisepatu()),
              );
              ambilData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Data",
            onPressed: ambilData,
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: "Cetak PDF",
            onPressed: () async {
              final pdf = await _generatePdf(data);
              await Printing.layoutPdf(onLayout: (format) async => pdf.save());
            },
          ),
        ],
      ),
      body: data.isEmpty
          ? const Center(child: Text("Belum ada data"))
          : Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: 157,
                    dataRowHeight: 80,
                    headingRowColor:
                        MaterialStateProperty.all(const Color.fromARGB(255, 103, 110, 104)),
                    columns: const [
                      DataColumn(label: Text("Kode sepatu")),
                      DataColumn(label: Text("Foto")),
                      DataColumn(label: Text("Nama sepatu")),
                      DataColumn(label: Text("Harga")),
                      DataColumn(label: Text("Stok")),
                      DataColumn(label: Text("Aksi")),
                    ],
                    rows: data.map((b) {
                      return DataRow(cells: [
                        DataCell(Text(b.id)),                       
                        DataCell(Image.asset(
                          "assets/foto/${b.foto}",
                          width: 100,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported),
                        )),                        
                        DataCell(Text(b.nama)),                        
                        DataCell(Text("Rp ${b.harga}")),
                        DataCell(Text(b.stok.toString())),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color.fromARGB(255, 59, 66, 59)),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => Entrisepatu(data: b)),
                                );
                                ambilData();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Color.fromARGB(255, 173, 40, 31)),
                              onPressed: () => hapus(b.id),
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
    );
  }

  Future<pw.MemoryImage> _loadImage(String filename) async {
    final bytes = await rootBundle.load('assets/foto/$filename');
    return pw.MemoryImage(bytes.buffer.asUint8List());
  }

  Future<pw.Document> _generatePdf(List<sepatu> data) async {
    final totalStok = data.fold<int>(0, (sum, b) => sum + b.stok);

    final pdf = pw.Document();


    final rows = <pw.TableRow>[
      pw.TableRow(
        children: [
          pw.Center(child:pw.Text("Kode")),
          pw.Center(child:pw.Text("Foto")),
          pw.Center(child:pw.Text("Nama sepatu")),
          pw.Center(child:pw.Text("Harga")),
          pw.Center(child:pw.Text("Stok")),
        ],
      ),
    ];


    final grafikStok = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: data.map((b) {
        return pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.SizedBox(width: 150, child: pw.Text(b.nama)),
            pw.Container(
              width: b.stok * 5.0,
              height: 12,
              decoration: pw.BoxDecoration(                
              color: PdfColors.black,
                border: pw.Border.all(width: 0.5),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Text("${b.stok}"),
          ],
        );
      }).toList(),
    );

    for (final b in data) {
      final foto = await _loadImage(b.foto);
      rows.add(
  pw.TableRow(
    children: [
      pw.SizedBox(width: 20, child: pw.Center(child: pw.Text(b.id))),
      pw.SizedBox(width: 60, child: pw.Center(child: pw.Image(foto, width: 40, height: 40))),
      pw.SizedBox(
        width: 100,
        child: pw.Text(
          b.nama,
          overflow: pw.TextOverflow.clip,
        ),
      ),
      pw.SizedBox(width: 30, child: pw.Text("Rp ${b.harga}")),
      pw.SizedBox(width: 30, child: pw.Center(child: pw.Text("${b.stok}"))),
    ],
  ),
);
    }

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Center(
            child: pw.Column(children: [
              pw.Text("PT. PARA NIAGA DIGITA",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text("Manajemen Data sepatu"),
              pw.SizedBox(height: 20),
            ]),
          ),
          pw.Text("Tanggal cetak: ${DateTime.now().toLocal()}"),
          pw.SizedBox(height: 16),

          pw.Text("Grafik Stok sepatu",
              style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          grafikStok,
          pw.SizedBox(height: 18),

          pw.Table(
            border: pw.TableBorder.all(width: 1),
            defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
            children: rows,
          ),
          pw.SizedBox(height: 5),
          pw.Text("Total Stok sepatu: $totalStok"),

          pw.Container(
            alignment: pw.Alignment.bottomRight,
            margin: const pw.EdgeInsets.only(top: 80),
            child: pw.Text("Tanda Tangan",
                style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
          ),
        ],
      ),
    );

    return pdf;
  }
}
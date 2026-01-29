class sepatu {
  String id;
  String nama;  
  int harga;
  int stok;
  String foto;

  sepatu({
    required this.id,
    required this.nama,
    required this.harga,
    required this.stok,
    required this.foto,
  });

  factory sepatu.fromJson(Map<String, dynamic> json) => sepatu(
    id: json['kd_sepatu'] ?? '',
    nama: json['nama'] ?? '',   
    harga: int.tryParse(json['harga'].toString()) ?? 0,
    stok: int.tryParse(json['stok'].toString()) ?? 0,
    foto: json['foto'] ?? '',
  );

  Map<String, String> toForm() => {
    'kd_sepatu': id,
    'nama': nama,
    'harga': harga.toString(),
    'stok': stok.toString(),
    'foto': foto,
  };
}
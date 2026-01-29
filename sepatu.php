<?php
include "koneksi.php";
$op = $_GET['op'] ?? '';

if ($op == 'list') {
    $sql = mysqli_query($conn, "SELECT * FROM sepatu ORDER BY kd_sepatu ASC");
    $data = [];
    while ($row = mysqli_fetch_assoc($sql)) {
        $data[] = $row;
    }
    echo json_encode($data);
}

elseif ($op == 'insert') {
    $id    = $_POST['kd_sepatu'];
    $nama  = $_POST['nama'];
    $harga = $_POST['harga'];
    $stok  = $_POST['stok'];
    $foto  = $_POST['foto'];
    $q = mysqli_query($conn, "INSERT INTO sepatu (kd_sepatu,nama,harga,stok,foto) VALUES ('$id','$nama','$harga','$stok','$foto')");
    echo json_encode(['status' => $q ? 'sukses' : 'gagal']);
}

elseif ($op == 'update') {
    $id    = $_POST['kd_sepatu'];
    $nama  = $_POST['nama'];
    $harga = $_POST['harga'];
    $stok  = $_POST['stok'];
    $foto  = $_POST['foto'];
    $q = mysqli_query($conn, "UPDATE sepatu SET nama='$nama', harga='$harga', stok='$stok', foto='$foto' WHERE kd_sepatu='$id'");
    echo json_encode(['status' => $q ? 'sukses' : 'gagal']);
}

elseif ($op == 'delete') {
    $id = $_POST['kd_sepatu'];
    $q = mysqli_query($conn, "DELETE FROM sepatu WHERE kd_sepatu='$id'");
    echo json_encode(['status' => $q ? 'sukses' : 'gagal']);
}
?>
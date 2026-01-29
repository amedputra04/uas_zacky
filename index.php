<?php
$host = gethostname();
$ip = gethostbyname($host);
?>
<html>
<title>Login Admin</title>
<style>
    body {
        height: 100%;
        margin: 0;
        display: grid;
        justify-content: center;
        align-items: center;
        align-content: center;
    }

    h1 {
        height: 100%;
        margin: 0;
        display: grid;
        justify-content: center;
        align-items: center;
    }
</style>
<body>
<?php
$path = "C:\Users\DELL\Documents\UAS_MT\uas_natan\assets\ip.txt";
if(file_put_contents($path, $ip)) {
    echo "<h1>Sukses!</h1>";
    echo "Anda boleh menutup halaman ini sekarang";
} else {
    echo "<h1>Gagal!</h1>";
    echo "Terdapat kesalahan; periksa koneksi dan coba lagi";
}
?>
</body>
</html>
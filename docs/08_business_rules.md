# 08. Aturan Bisnis Utama (*Core Business Rules*)

Dokumentasi ini merangkum seluruh aturan bisnis, batasan fungsional, dan logika operasional yang berhasil diekstraksi dari hasil *reverse engineering* kode sumber CetakDanom.

---

## 1. Aturan Autentikasi, Otorisasi, & Integritas Proses

1. **Format Hashing Kata Sandi**:
   - Kata sandi tidak pernah dikirim dalam bentuk teks polos (*plaintext*).
   - Pola hash wajib: `MD5(UserID + Password)`.
   - Kode sumber: `ULogin.pas:89`:
     ```pascal
     ADOloginQuery.Parameters.ParamByName('PASS_PETUGAS').Value := StrToMD5(txt_UserId.Text + txt_Passwd.Text);
     ```

2. **Kunci Versi Aplikasi (*Version Locking*)**:
   - Stored Procedure `SIKAP_LOGIN` memvalidasi parameter `APPVERSI`. Jika versi aplikasi pada klien (`UParam.appVersi = '4.1.9'`) tidak sesuai dengan versi minimum yang ditentukan di tabel server, sistem menolak proses login dan memicu alur *auto-update*.

3. **Format Profil Petugas Terotentikasi**:
   - Server mengembalikan string gabungan dipisahkan tanda pipa (`|`) jika login berhasil (kode status `'000'`):
     ```
     [0] IdPetugas | [1] Nippos | [2] NamaPetugas | [3] Nopend | [4] Kantor | [5] Jabatan
     Contoh: 12045|987654321|AHMAD JUNAEDI|40100|KANTOR POS BANDUNG|MAN LAYANAN
     ```
   - Nilai `Nopend` (Nomor Pendirian Kantor Pos) digunakan sebagai filter wajib pada seluruh kueri hierarki penarikan data berikutnya.

4. **Pencegahan Multi-Instans (*Single Instance Mutex*)**:
   - Menggunakan Win32 Mutex dengan nama aplikasi. Jika instance sudah berjalan di Windows, aplikasi kedua tidak diperbolehkan terbuka:
     ```pascal
     CreateMutex(nil, true, PChar(Application.Title));
     if GetLastError = Error_Already_Exists then Halt;
     ```

5. **Pengawasan Antar-Proses (*Companion Process Dependency*)**:
   - Berkas biner `cetak.exe` (Tool Cetak QR) memverifikasi bahwa proses induk `cetakDanom.exe` sedang aktif di sistem melalui `Toolhelp32Snapshot`. Jika `cetakDanom.exe` tidak ditemukan, `cetak.exe` segera keluar (`Utama.pas:673-678`).

---

## 2. Aturan Dual-Mode Operasional (Online vs Mode Lokal)

1. **Pemicu Mode Lokal**:
   - Ditekan melalui tombol keyboard **F5** pada form login.
2. **Batasan Mode Lokal**:
   - Digunakan khusus saat petugas berada di lokasi bayar luar ruangan / *community payout* tanpa jaringan internet/VPN Pos.
   - Pada mode lokal, seluruh fitur penarikan data pusat dinonaktifkan.
   - Petugas hanya diizinkan membaca file `.POS` yang sudah diunduh sebelumnya ke folder lokal `data/`, menampilkan di grid, dan mencetak dokumen fisik.

---

## 3. Aturan Partisi Administratif Wilayah & Batch Data

1. **Hierarki Geografis Berjenjang**:
   - Pengambilan data harus mengikuti urutan: **Layanan Bansos &rarr; Tahap &rarr; Kabupaten &rarr; Kecamatan &rarr; Kelurahan/Desa**.
   - Tidak diperbolehkan menarik data lintas kabupaten dalam satu file kerja.
2. **Granulitas File 1 Kelurahan = 1 File `.POS`**:
   - Setiap berkas `.POS` yang dihasilkan oleh stored procedure `SIKAP_GET_DATA_BANSOSRS` merepresentasikan seluruh penerima manfaat dalam **satu kelurahan/desa tunggal**.
3. **Penyimpanan Berkas Terenkripsi & Terkompresi**:
   - Pada versi awal (`ToolCetakDanom`), stream dataset `kbmMemTable` dikompresi `ZLib zcMax` dan dienkripsi `Blowfish` sebelum ditulis ke file.
   - Pada versi QR (`ToolCetakDanom_QR`), data disimpan dalam bentuk teks berpemisah titik koma (`;`) sebanyak 24 kolom.

---

## 4. Aturan Siklus Hidup File & Proteksi Cetak Ganda (*Double-Print Protection*)

Untuk memastikan tidak terjadi penyaluran atau pencetakan ganda di lapangan, sistem menerapkan *state machine* berbasis pemindahan file (*directory relocation*):

```
[Tahap 1: Unprinted]
Berkas disimpan di: data/<nama_file>.POS
Status: Tampil di listFile (Daftar File Danom Siap Cetak)

        │ (Saat Tombol "Cetak Danom" Ditekan)
        ▼
[Tahap 2: Danom Printed / Ready for Receipt]
Berkas dipindahkan ke: data/sudah_cetak/<nama_file>.POS
dan disalin ke:        data/sudah_cetak/sudah_cetak_bukti/<nama_file>.POS
Status: Hilang dari listFile Danom, Muncul di listFile_bt (Siap Cetak Kuitansi)

        │ (Saat Tombol "Cetak Bukti Terima" Ditekan)
        ▼
[Tahap 3: Completed Archive]
Berkas diarsipkan di: data/sudah_cetak/sudah_cetak_bukti/<nama_file>.POS
Status: Selesai seluruh siklus cetak
```

---

## 5. Aturan Ekspor Berkas *By Name By Address* (BNBA)

Sebelum dokumen Danom fisik dicetak ke printer, sistem mewajibkan pembuatan file CSV BNBA untuk diserahkan ke pihak audit/kelurahan:

1. **Format File**: Semicolon-delimited CSV (`.csv`), disimpan di folder `data/BNBA/BNBA_<namafile>.csv`.
2. **Skema Header Wajib**:
   ```csv
   BST;REGIONAL;KANTOR;PROVINSI;KABUPATEN;KECAMATAN;DESA/KELURAHAN;BATCH;NAMA;NOMINAL;NIK;ALAMAT;DANOM;PERCENTILE
   ```
3. **Aturan Preservasi Teks Numerik (Aturan Tanda Petik / Backtick)**:
   - Field `NIK` dan nomor `DANOM` **wajib diawali karakter backtick (`` ` ``)**.
   - **Tujuan**: Mencegah Microsoft Excel mengonversi nomor NIK 16-digit menjadi notasi ilmiah (misal: `3.201E+15`) atau memotong angka nol di digit awal saat file dibuka oleh petugas kelurahan.

---

## 6. Aturan Barcode 2D & Pencetakan Kuitansi (Bukti Bayar BST)

1. **Payload Barcode 2 Dimensi (QR Code) - Kontrak Integrasi Delimiter Pipa (`|`)**:
   - Barcode pada bukti penerimaan mengodekan data KPM yang **wajib dipisahkan menggunakan karakter pipa (`|`)** sebagai kontrak integrasi resmi agar dapat dibaca dan diparsing oleh scanner fisik serta aplikasi loket kasir/teller eksternal:
     ```
     [ID_PELANGGAN_19DIGIT][KODE_TAHAP]|[NIK]|[NAMA_PELANGGAN]|[ALAMAT_KTP]|[ALAMAT_DOMISILI]|[NOMINAL_BSU]
     ```
   - Aplikasi klien C# dilarang mengganti format pemisah pipa ini dengan format lain (seperti koma, titik koma, spasi, atau JSON).
   - Untuk menjaga konsistensi pembacaan 6 segmen kolom oleh aplikasi lain, karakter pipa yang tidak sengaja muncul di dalam teks nama/alamat dinetralisir agar tidak merusak struktur hasil parsing.
2. **Kondisi Dinamis Multi-Tahap (Tahap Awal vs Tahap Akhir)**:
   - Sistem memeriksa rentang tahap yang dicairkan (`thp_akhir - thp_awal`):
     - **Selisih 2 (Menerima 3 Tahap Sekaligus)**: Menampilkan 3 blok kuitansi dan 3 barcode 2D (`Barcode2D1`, `Barcode2D2`, `Barcode2D3`) pada satu lembar.
     - **Selisih 1 (Menerima 2 Tahap Sekaligus)**: Menampilkan 2 blok kuitansi dan 2 barcode 2D.
     - **Selisih 0 (Menerima 1 Tahap Tunggal)**: Menampilkan 1 blok kuitansi dan 1 barcode 2D.
3. **Pemuatan Logo Dinamis**:
   - Jika `STATUS_GARUDA = '1'`, logo Lambang Garuda Pancasila diaktifkan.
   - Logo mitra instansi dimuat berdasarkan 3 karakter pertama `ID_PELANGGAN`: `logo_ + LowerCase(Copy(ID_PELANGGAN, 1, 3)) + .jpg` (misal: `logo_bmu.jpg`).

---

## 7. Aturan Surat Pernyataan Tanggung Jawab Mutlak (Program Sembako)

1. **Ketentuan Hukum Komoditas Pangan**:
   - Surat pernyataan mewajibkan KPM membelanjakan dana bantuan tunai hanya untuk 4 unsur bahan pangan yang ditetapkan Kementerian Sosial:
     1. Karbohidrat (beras, jagung, dll.)
     2. Protein Hewani (daging, telur, ikan)
     3. Protein Nabati (tahu, tempe, kacang-kacangan)
     4. Vitamin dan Mineral (sayur dan buah-buahan)
2. **Klausul Sanksi**:
   - Pelanggaran penggunaan dana mengakibatkan pencabutan hak bantuan pada periode berikutnya dan pengeluaran dari data penerima manfaat Kemenkes/Kemensos.
3. **Pemuatan Format Teks Eksternal**:
   - Redaksional surat dimuat dari file parameter eksternal: `param_b[idproject]_[subfix].pos`. Jika file ini tidak tersedia, sistem memblokir pencetakan (`Format Surat Belum Ada`).

---

## 8. Aturan Cetak Danom Susulan (CDS BLT / BSU)

1. **Validasi Online Real-time**:
   - Pengecekan KPM susulan dilakukan langsung menggunakan nomor NIK via REST API Gateway (`/cds_blt/getData`).
2. **Rumus Perhitungan Nominal**:
   ```
   BSU = KUANTITAS * NOMINAL
   ```
   Data diambil dari atribut response JSON: `xl.getString('KUANTITAS')` dan `xl.getString('NOMINAL')`.
3. **Pencetakan Slip RAW Printer (Passbook / Thermal)**:
   - Menghasilkan struk tanda terima pembayaran kasir teller pos melalui instruksi byte mentah ESC/P.
   - Header memuat instansi pembayar (misal: *KEMENTRIAN KETENAGAKERJAAN RI* atau *KEMENTRIAN SOSIAL RI*), NIK, Nama, Alamat Perusahaan, Nominal BSU terformat (`Rp. #,##0.00`), tanggal bayar, dan kotak tanda tangan basah penerima.


# Spesifikasi Data Tiruan (Mock Data Specification) - Fase 1 Prototipe

Dokumen ini mendokumentasikan skema dan spesifikasi seluruh **data sintetis (mock data)** yang digunakan dalam Prototipe Desktop C# WPF CetakDanom.

> [!IMPORTANT]
> **Pernyataan Privasi & Keamanan Data**:
> Seluruh data penerima manfaat (KPM), Nomor Induk Kependudukan (NIK), nama orang, alamat jalan, dan nomor rekening yang digunakan pada prototipe ini adalah **100% data sintetis/buatan**. Tidak ada data pribadi (*Personally Identifiable Information* - PII) atau berkas dari server produksi PT Pos Indonesia / Kemensos yang disalin ke dalam prototipe ini.

---

## 1. Spesifikasi Akun Pengguna Demo (`MockAuthenticationService`)

| User ID | Kata Sandi | Nama Petugas | NIPPOS | NOPEND | Kantor Cabang Pos | Peran / Jabatan |
| :--- | :--- | :--- | :--- | :---: | :--- | :--- |
| `demo` | `demo123` | AHMAD HIDAYAT | 987654321 | 40000 | KCU BANDUNG | Petugas Loket Utama |
| `petugas01` | `pos12345` | SITI NURHALIZA | 987650001 | 40000 | KCU BANDUNG | Operator Cetak Danom |
| `supervisor`| `super123` | BAMBANG SUDARMO | 987600001 | 40000 | KCU BANDUNG | Manajer Pelayanan Bansos |

*Format string profil internal yang disimulasikan:*
`PETUGAS_DEMO|987654321|AHMAD HIDAYAT|40000|KCU BANDUNG|PETUGAS LOKET UTAMA`

---

## 2. Spesifikasi Program Layanan Bansos

| Kode Layanan | Nama Program Bantuan | Deskripsi Program | Nominal BSU Default | Daftar Tahap Tersedia |
| :--- | :--- | :--- | :---: | :---: |
| `BST` | Bantuan Sosial Tunai (Kemensos) | Penyaluran dana tunai Kemensos RI | Rp 600.000 | 1, 2, 3, 4 |
| `PKH` | Program Keluarga Harapan | Bantuan bersyarat keluarga prasejahtera | Rp 750.000 | 1, 2, 3, 4 |
| `SEMBAKO` | Program Sembako / BPNT | Bantuan pangan tunai / sembako | Rp 400.000 | 1, 2, 3, 4 |
| `BLT_BBM` | BLT Subsidi BBM | Kompensasi penyesuaian harga energi BBM | Rp 300.000 | 1, 2 |

---

## 3. Spesifikasi Hierarki Wilayah Administratif (`MockWilayahRepository`)

```text
32 - PROVINSI JAWA BARAT
│
├── 3273 - KOTA BANDUNG
│   ├── 327301 - KECAMATAN COBLONG
│   │   ├── 3273011001 - KELURAHAN DAGO (25 KPM Tiruan)
│   │   ├── 3273011002 - KELURAHAN LEBAKGEDE (15 KPM Tiruan)
│   │   ├── 3273011003 - KELURAHAN SADANG SERANG
│   │   └── 3273011004 - KELURAHAN SEKELOA
│   │
│   └── 327302 - KECAMATAN SUKASARI
│       ├── 3273021001 - KELURAHAN GEGERKALONG (15 KPM Tiruan)
│       ├── 3273021002 - KELURAHAN ISOLA
│       └── 3273021003 - KELURAHAN SARIJADI
│
└── 3277 - KOTA CIMAHI
    └── 327701 - KECAMATAN CIMAHI UTARA
        ├── 3277011001 - KELURAHAN CIBABAT
        └── 3277011002 - KELURAHAN CIPAGERAN
```

---

## 4. Karakteristik Dataset KPM Tiruan (`MockDanomRepository`)

Dataset in-memory memuat 55 baris data KPM sintetis dengan distribusi atribut:

1. **Format ID Pelanggan**: `BST + KodeKelurahan (10 digit) + Urutan (6 digit)` (contoh: `BST3273011001000001`).
2. **Format NIK**: 16 digit numerik berpola wilayah resmi (contoh: `3273011001900001`).
3. **Nama & Alamat**: Menggunakan nama-nama umum Indonesia (Budi Santoso, Siti Aminah, Joko Widodo, Dewi Lestari, dll.) dan nama jalan realistis di wilayah Bandung (Jl. Ir. H. Djuanda, Jl. Dago Barat, Jl. Gegerkalong Hilir).
4. **Variasi Status Cetak**:
   * Kelurahan Dago memuat 5 KPM dengan status `SudahCetak` (Danom) dan 2 KPM berstatus `SudahCetak` (Kuitansi) untuk menguji fungsionalitas badge dan kalkulator ringkasan status.
   * KPM lainnya berstatus `BelumCetak` (Siap Cetak).

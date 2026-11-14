using System.Text;
using CetakDanom.Application.DTOs;
using CetakDanom.Application.Interfaces;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Infrastructure.Printing;

/// <summary>
/// MOCK IMPLEMENTATION ONLY.
/// Menyiapkan model pratinjau dokumen cetak (Danom, Bukti Terima, Surat Pernyataan) secara terpisah dari UI.
/// Memvalidasi kontrak format QR Code pipa 6-segmen dan aturan presisi 20 baris per halaman.
/// </summary>
public class MockPrintService : IPrintService
{
    private readonly IQrCodeService _qrCodeService;

    public MockPrintService(IQrCodeService qrCodeService)
    {
        _qrCodeService = qrCodeService;
    }

    public Task<PrintPreviewDocument> PrepareDanomPrintPreviewAsync(
        IReadOnlyList<PenerimaBansos> records,
        string infoWilayah,
        Petugas? petugas)
    {
        var sb = new StringBuilder();
        int pageSize = 20; // Aturan Presisi Halaman Dokumen Danom (Maksimal 20 baris per halaman)
        int totalPages = (int)Math.Ceiling((double)records.Count / pageSize);
        if (totalPages == 0) totalPages = 1;

        decimal totalNominal = records.Sum(r => r.Nominal);

        sb.AppendLine("==========================================================================================================");
        sb.AppendLine("                                      PT POS INDONESIA (PERSERO)                                          ");
        sb.AppendLine("                         DAFTAR NOMINATIF PENYALURAN BANTUAN SOSIAL TUNAI (DANOM)                         ");
        sb.AppendLine($"Wilayah       : {infoWilayah}");
        sb.AppendLine($"Kantor / Nopend : {petugas?.Kantor ?? "KCU BANDUNG"} ({petugas?.Nopend ?? "40000"})");
        sb.AppendLine($"Waktu Cetak   : {DateTime.Now:dd/MM/yyyy HH:mm:ss} | Petugas: {petugas?.Nama ?? "OPERATOR"}");
        sb.AppendLine($"Total Data    : {records.Count} KPM | Total Halaman: {totalPages}");
        sb.AppendLine("==========================================================================================================");
        sb.AppendLine(string.Format("{0,-6} | {1,-18} | {2,-25} | {3,-30} | {4,-14} | {5,-10}",
            "NO/DANOM", "NIK", "NAMA KPM", "ALAMAT", "NOMINAL (RP)", "TANDA TANGAN"));
        sb.AppendLine("----------------------------------------------------------------------------------------------------------");

        int index = 1;
        int currentPage = 1;

        foreach (var r in records)
        {
            sb.AppendLine(string.Format("{0,-8} | {1,-18} | {2,-25} | {3,-30} | {4,14:N0} | [...........]",
                $"{r.Danom}", r.Nik, Truncate(r.Nama, 25), Truncate(r.Alamat, 30), r.Nominal));

            if (index % pageSize == 0 && index < records.Count)
            {
                currentPage++;
                sb.AppendLine("----------------------------------------------------------------------------------------------------------");
                sb.AppendLine($"[ Lembar {currentPage - 1} dari {totalPages} - Batas Maksimal 20 Baris Data Per Halaman ]");
                sb.AppendLine("\n\f"); // Form feed simulative page break
                sb.AppendLine("==========================================================================================================");
                sb.AppendLine($"DAFTAR NOMINATIF (LANJUTAN LEMBAR {currentPage}) - {infoWilayah}");
                sb.AppendLine("==========================================================================================================");
                sb.AppendLine(string.Format("{0,-6} | {1,-18} | {2,-25} | {3,-30} | {4,-14} | {5,-10}",
                    "NO/DANOM", "NIK", "NAMA KPM", "ALAMAT", "NOMINAL (RP)", "TANDA TANGAN"));
                sb.AppendLine("----------------------------------------------------------------------------------------------------------");
            }
            index++;
        }

        sb.AppendLine("==========================================================================================================");
        sb.AppendLine(string.Format("TOTAL KESELURUHAN ({0} KPM) : Rp {1,14:N0}", records.Count, totalNominal));
        sb.AppendLine("==========================================================================================================");
        sb.AppendLine("\nMengetahui / Mengesahkan,                                                      Petugas Juru Bayar Pos,");
        sb.AppendLine("Aparat Kelurahan / Desa Setempat,");
        sb.AppendLine("\n\n\n( .................................... )                                      ( " + (petugas?.Nama ?? "....................................") + " )");

        return Task.FromResult(new PrintPreviewDocument
        {
            DocType = DocumentType.DaftarNominatif,
            Title = "Daftar Nominatif (Danom)",
            Subtitle = $"{infoWilayah} - {records.Count} Penerima",
            HeaderInfo = $"Kantor Pos: {petugas?.Kantor ?? "40000"} | Total: Rp {totalNominal:N0}",
            Records = records,
            FormattedContent = sb.ToString(),
            QrCodePayloadSample = string.Empty,
            QrPayloadValid = true
        });
    }

    public Task<PrintPreviewDocument> PrepareBuktiTerimaPrintPreviewAsync(
        PenerimaBansos record,
        string tahap,
        Petugas? petugas)
    {
        // 1. Bangun Payload QR Code berpemisah pipa 6 segmen
        string qrPayload = _qrCodeService.GeneratePayload(
            record.IdPelanggan,
            tahap,
            record.Nik,
            record.Nama,
            record.AlamatKtp,
            record.Alamat,
            record.Nominal);

        // 2. Validasi keabsahan kontrak 6 segmen
        var (isValid, message, segments) = _qrCodeService.ValidatePayload(qrPayload);

        // 3. Render gambar PNG barcode QR Code
        byte[]? pngBytes = null;
        if (isValid)
        {
            try
            {
                pngBytes = _qrCodeService.GenerateQrCodePng(qrPayload, 8);
            }
            catch
            {
                // Fallback defensif jika GDI bitmap tidak tersedia
            }
        }

        var sb = new StringBuilder();
        sb.AppendLine("================================================================================");
        sb.AppendLine("                          PT POS INDONESIA (PERSERO)                            ");
        sb.AppendLine("                  KUITANSI BUKTI PENERIMAAN BANTUAN SOSIAL                      ");
        sb.AppendLine("================================================================================");
        sb.AppendLine($"ID VOUCHER / KPM : {record.IdPelanggan}");
        sb.AppendLine($"TERMIN / TAHAP   : TAHAP {tahap}");
        sb.AppendLine($"NOMOR INDUK KTP  : {record.Nik}");
        sb.AppendLine($"NAMA PENERIMA    : {record.Nama}");
        sb.AppendLine($"ALAMAT KTP       : {record.AlamatKtp}");
        sb.AppendLine($"ALAMAT DOMISILI  : {record.Alamat}");
        sb.AppendLine($"WILAYAH KERJA    : KEL. {record.Kelurahan}, KEC. {record.Kecamatan}, {record.Kabupaten}");
        sb.AppendLine($"JUMLAH BANTUAN   : Rp {record.Nominal:N0} ({Terbilang((long)record.Nominal)} Rupiah)");
        sb.AppendLine("--------------------------------------------------------------------------------");
        sb.AppendLine($"KONTRAK SCANNER QR : {qrPayload}");
        sb.AppendLine($"STATUS VALIDASI QR : [{(isValid ? "VALID 6 SEGMEN PIPA" : "TIDAK VALID")}] - {message}");
        sb.AppendLine("--------------------------------------------------------------------------------");
        sb.AppendLine("Telah diterima sejumlah uang tunai tersebut di atas dengan benar.");
        sb.AppendLine($"Diterima di loket pos pada: {DateTime.Now:dd MMMM yyyy HH:mm:ss}");
        sb.AppendLine("\n   Tanda Tangan / Cap Jempol KPM,                             Petugas Kasir Loket,");
        sb.AppendLine("\n\n\n   ( " + record.Nama + " )                             ( " + (petugas?.Nama ?? "PETUGAS LOKET") + " )");
        sb.AppendLine("================================================================================");

        return Task.FromResult(new PrintPreviewDocument
        {
            DocType = DocumentType.BuktiTerimaKuitansi,
            Title = "Kuitansi Bukti Penerimaan (BST)",
            Subtitle = $"{record.Nama} ({record.Nik}) - Rp {record.Nominal:N0}",
            HeaderInfo = $"ID KPM: {record.IdPelanggan} | Tahap: {tahap}",
            Records = new[] { record },
            FormattedContent = sb.ToString(),
            QrCodePayloadSample = qrPayload,
            QrPayloadValid = isValid,
            QrValidationMessage = message,
            QrCodeImagePngBytes = pngBytes
        });
    }

    public Task<PrintPreviewDocument> PrepareSuratPernyataanPrintPreviewAsync(
        PenerimaBansos record,
        Petugas? petugas)
    {
        var sb = new StringBuilder();
        sb.AppendLine("================================================================================");
        sb.AppendLine("                SURAT PERNYATAAN TANGGUNG JAWAB MUTLAK (SPTJM)                  ");
        sb.AppendLine("                 PENERIMA PROGRAM BANTUAN SEMBAKO TUNAI                         ");
        sb.AppendLine("================================================================================");
        sb.AppendLine("Yang bertanda tangan di bawah ini:");
        sb.AppendLine($"Nama Lengkap   : {record.Nama}");
        sb.AppendLine($"NIK            : {record.Nik}");
        sb.AppendLine($"Alamat Sesuai KTP: {record.AlamatKtp}");
        sb.AppendLine($"Nomor Danom    : {record.Danom} / {record.Kelurahan}");
        sb.AppendLine("\nMenyatakan dengan sesungguhnya bahwa dana bantuan sosial yang saya terima sebesar");
        sb.AppendLine($"Rp {record.Nominal:N0} ({Terbilang((long)record.Nominal)} Rupiah)");
        sb.AppendLine("akan saya pergunakan HANYA untuk membeli bahan kebutuhan pangan (sembako) yang memenuhi");
        sb.AppendLine("4 (empat) unsur gizi pangan sesuai ketetapan Kementerian Sosial RI:");
        sb.AppendLine("  1. Karbohidrat (beras, jagung, sagu)");
        sb.AppendLine("  2. Protein Hewani (telur, daging ayam/sapi, ikan)");
        sb.AppendLine("  3. Protein Nabati (kacang-kacangan, tahu, tempe)");
        sb.AppendLine("  4. Vitamin dan Mineral (sayur-mayur dan buah-buahan)");
        sb.AppendLine("\nApabila saya melanggar pernyataan ini (misal membeli rokok, miras, atau barang terlarang),");
        sb.AppendLine("saya bersedia dikeluarkan dari Data Terpadu Kesejahteraan Sosial (DTKS) dan tidak");
        sb.AppendLine("menerima bantuan sosial pada periode berikutnya.");
        sb.AppendLine("\nDemikian surat pernyataan ini saya buat dalam keadaan sadar tanpa paksaan dari pihak manapun.");
        sb.AppendLine($"\n{record.Kabupaten}, {DateTime.Now:dd MMMM yyyy}");
        sb.AppendLine("\nSaksi Petugas Pos,                                      Yang Membuat Pernyataan,");
        sb.AppendLine("\n\n\n( " + (petugas?.Nama ?? "PETUGAS POS") + " )                                  ( " + record.Nama + " )");
        sb.AppendLine("================================================================================");

        return Task.FromResult(new PrintPreviewDocument
        {
            DocType = DocumentType.SuratPernyataan,
            Title = "Surat Pernyataan Tanggung Jawab Mutlak (SPTJM)",
            Subtitle = $"{record.Nama} ({record.Nik})",
            HeaderInfo = "Pakta Integritas Pemanfaatan 4 Unsur Gizi Sembako",
            Records = new[] { record },
            FormattedContent = sb.ToString(),
            QrCodePayloadSample = string.Empty,
            QrPayloadValid = true
        });
    }

    private static string Truncate(string value, int maxLen)
    {
        if (string.IsNullOrEmpty(value)) return string.Empty;
        return value.Length <= maxLen ? value : value.Substring(0, maxLen - 2) + "..";
    }

    private static string Terbilang(long x)
    {
        string[] bil = { "", "Satu", "Dua", "Tiga", "Empat", "Lima", "Enam", "Tujuh", "Delapan", "Sembilan", "Sepuluh", "Sebelas" };
        if (x < 12) return bil[x];
        if (x < 20) return Terbilang(x - 10) + " Belas";
        if (x < 100) return Terbilang(x / 10) + " Puluh " + Terbilang(x % 10);
        if (x < 200) return "Seratus " + Terbilang(x - 100);
        if (x < 1000) return Terbilang(x / 100) + " Ratus " + Terbilang(x % 100);
        if (x < 2000) return "Seribu " + Terbilang(x - 1000);
        if (x < 1000000) return Terbilang(x / 1000) + " Ribu " + Terbilang(x % 1000);
        if (x < 1000000000) return Terbilang(x / 1000000) + " Juta " + Terbilang(x % 1000000);
        return x.ToString();
    }
}

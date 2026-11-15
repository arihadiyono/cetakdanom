using System.Text;
using CetakDanom.Application.DTOs;
using CetakDanom.Application.Interfaces;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Infrastructure.Mock;

/// <summary>
/// MOCK IMPLEMENTATION ONLY.
/// Menyimulasikan layanan pencarian KPM satuan (Inquiry NIK) dan pencetakan kuitansi tanda terima CDS.
/// Mengadopsi pola kerja CDS.exe dan kontrak endpoint Go API /api/v1/cds-blt/data.
/// </summary>
public class MockCdsBltService : ICdsBltService
{
    private readonly IQrCodeService _qrCodeService;

    // Database sintetis untuk simulasi CDS BLT
    private static readonly Dictionary<string, CdsBltRecipientDto> SyntheticCdsDatabase = new()
    {
        ["3201012304850001"] = new CdsBltRecipientDto
        {
            IdResponse = "000",
            Response = "Success",
            IdPelanggan = "3201010001",
            Nik = "3201012304850001",
            Nama = "AHMAD SURYANA",
            AlamatDtks = "JL. MERDEKA NO. 14 RT 02 RW 05",
            NmDesaDtks = "CIBINONG",
            NmKecDtks = "CIBINONG",
            NmKabDtks = "BOGOR",
            NmPropDtks = "JAWA BARAT",
            Nominal = 600000,
            Kuantitas = 1,
            Program = "BLT BBM TAHAP 2",
            HeaderDanom = "BANTUAN LANGSUNG TUNAI (BLT) BBM TAHAP 2",
            NoVoucher = "VCR-BLT-2026-0001",
            NamaPerusahaan = "KEMENTERIAN SOSIAL RI",
            AlamatPerusahaan = "JL. SALEMBA RAYA NO. 28 JAKARTA"
        },
        ["3201012304850002"] = new CdsBltRecipientDto
        {
            IdResponse = "000",
            Response = "Success",
            IdPelanggan = "3201010002",
            Nik = "3201012304850002",
            Nama = "SITI AISYAH",
            AlamatDtks = "KAMPUNG RAWA KELINCI RT 01 RW 03",
            NmDesaDtks = "CIBINONG",
            NmKecDtks = "CIBINONG",
            NmKabDtks = "BOGOR",
            NmPropDtks = "JAWA BARAT",
            Nominal = 600000,
            Kuantitas = 1,
            Program = "BLT BBM TAHAP 2",
            HeaderDanom = "BANTUAN LANGSUNG TUNAI (BLT) BBM TAHAP 2",
            NoVoucher = "VCR-BLT-2026-0002",
            NamaPerusahaan = "KEMENTERIAN SOSIAL RI",
            AlamatPerusahaan = "JL. SALEMBA RAYA NO. 28 JAKARTA"
        },
        ["3201012304850003"] = new CdsBltRecipientDto
        {
            IdResponse = "000",
            Response = "Success",
            IdPelanggan = "3201010003",
            Nik = "3201012304850003",
            Nama = "BAMBANG SUDRAJAT",
            AlamatDtks = "PERUM GRIYA KENCANA BLOK C NO 8",
            NmDesaDtks = "CIRIMEKAR",
            NmKecDtks = "CIBINONG",
            NmKabDtks = "BOGOR",
            NmPropDtks = "JAWA BARAT",
            Nominal = 900000,
            Kuantitas = 1,
            Program = "BANTUAN SUBSIDI UPAH (BSU)",
            HeaderDanom = "BANTUAN SUBSIDI UPAH PEKERJA FORMAL TAHAP 1",
            NoVoucher = "BSU-2026-0089",
            NamaPerusahaan = "PT TEXTILE NUSANTARA JAYA",
            AlamatPerusahaan = "KAWASAN INDUSTRI SENTUL BOGOR"
        }
    };

    public MockCdsBltService(IQrCodeService qrCodeService)
    {
        _qrCodeService = qrCodeService;
    }

    public Task<CdsBltRecipientDto?> InquiryNikAsync(string nik, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(nik))
            return Task.FromResult<CdsBltRecipientDto?>(null);

        string cleanNik = nik.Trim();

        // 1. Cek data yang sudah terdaftar
        if (SyntheticCdsDatabase.TryGetValue(cleanNik, out var existing))
        {
            return Task.FromResult<CdsBltRecipientDto?>(existing);
        }

        // 2. Untuk demonstrasi pengujian, jika NIK 16 digit valid namun belum ada di kamus, buatkan data sintetis dinamis
        if (cleanNik.Length == 16 && cleanNik.All(char.IsDigit))
        {
            var dynamicKpm = new CdsBltRecipientDto
            {
                IdResponse = "000",
                Response = "Success",
                IdPelanggan = "CDS-" + cleanNik.Substring(10),
                Nik = cleanNik,
                Nama = "PENERIMA SUSULAN " + cleanNik.Substring(12),
                AlamatDtks = "DUSUN KRAJAN RT 02 RW 01",
                NmDesaDtks = "SUKAMAJU",
                NmKecDtks = "CIBINONG",
                NmKabDtks = "BOGOR",
                NmPropDtks = "JAWA BARAT",
                Nominal = 600000,
                Kuantitas = 1,
                Program = "BLT BBM / BSU SUSULAN",
                HeaderDanom = "BANTUAN PENYALURAN SUSULAN LOKET",
                NoVoucher = "VCR-SUSULAN-" + cleanNik.Substring(10),
                NamaPerusahaan = "KEMENTERIAN SOSIAL RI",
                AlamatPerusahaan = "JL. SALEMBA RAYA NO. 28 JAKARTA"
            };

            return Task.FromResult<CdsBltRecipientDto?>(dynamicKpm);
        }

        return Task.FromResult<CdsBltRecipientDto?>(null);
    }

    public Task<PrintPreviewDocument> PrepareKuitansiCdsPrintPreviewAsync(
        CdsBltRecipientDto recipient, 
        Petugas? petugas)
    {
        // Format Payload Barcode 2D kuitansi (6 segmen pipa):
        // ID_PELANGGAN | TAHAP | NIK | NAMA | ALAMAT_KTP | ALAMAT | NOMINAL
        string qrPayload = _qrCodeService.GeneratePayload(
            recipient.IdPelanggan,
            "1",
            recipient.Nik,
            recipient.Nama,
            recipient.AlamatDtks,
            recipient.AlamatDtks,
            recipient.Nominal);

        var (isValid, message, segments) = _qrCodeService.ValidatePayload(qrPayload);
        byte[]? pngBytes = null;
        if (isValid)
        {
            try
            {
                pngBytes = _qrCodeService.GenerateQrCodePng(qrPayload, 8);
            }
            catch
            {
                pngBytes = null;
            }
        }

        var sb = new StringBuilder();
        sb.AppendLine("================================================================================");
        sb.AppendLine("                           PT POS INDONESIA (PERSERO)                           ");
        sb.AppendLine($"           {recipient.HeaderDanom.ToUpper()}           ");
        sb.AppendLine("                      BUKTI PEMBAYARAN / TANDA TERIMA                           ");
        sb.AppendLine("================================================================================");
        sb.AppendLine($"Nomor Voucher : {recipient.NoVoucher}");
        sb.AppendLine($"Kantor Bayar  : {petugas?.Kantor ?? "KCU BANDUNG"} ({petugas?.Nopend ?? "40000"})");
        sb.AppendLine($"Waktu Bayar   : {DateTime.Now:dd/MM/yyyy HH:mm:ss} | Petugas: {petugas?.Nama ?? "OPERATOR LOKET"}");
        sb.AppendLine("--------------------------------------------------------------------------------");
        sb.AppendLine($"DATA PENERIMA MANFAAT (KPM):");
        sb.AppendLine($"  NIK KPM     : {recipient.Nik}");
        sb.AppendLine($"  Nama KPM    : {recipient.Nama}");
        sb.AppendLine($"  Alamat KPM  : {recipient.AlamatDtks}");
        sb.AppendLine($"  Wilayah     : Kel. {recipient.NmDesaDtks}, Kec. {recipient.NmKecDtks}, Kab. {recipient.NmKabDtks}");
        sb.AppendLine($"  Provinsi    : {recipient.NmPropDtks}");
        if (!string.IsNullOrWhiteSpace(recipient.NamaPerusahaan))
        {
            sb.AppendLine($"  Instansi/Perusahaan: {recipient.NamaPerusahaan}");
        }
        sb.AppendLine("--------------------------------------------------------------------------------");
        sb.AppendLine($"RINCIAN DANA DITERIMA:");
        sb.AppendLine($"  Jumlah Dana : Rp {recipient.Nominal,14:N0}");
        sb.AppendLine($"  Potongan    : Rp              0  (GRATIS / TANPA POTONGAN)");
        sb.AppendLine($"  Diterima Tunai: Rp {recipient.Nominal,12:N0}");
        sb.AppendLine($"  Terbilang   : Enam Ratus Ribu Rupiah");
        sb.AppendLine("--------------------------------------------------------------------------------");
        sb.AppendLine($"PAYLOAD BARCODE 2D / QR CODE LOKET (6 SEGMEN):");
        sb.AppendLine($"  {qrPayload}");
        sb.AppendLine("--------------------------------------------------------------------------------");
        sb.AppendLine("\nTanda Tangan Petugas Loket,                             Tanda Tangan Penerima,");
        sb.AppendLine("\n\n\n( " + (petugas?.Nama ?? "PETUGAS LOKET POS") + " )                       ( " + recipient.Nama + " )");
        sb.AppendLine("================================================================================");

        return Task.FromResult(new PrintPreviewDocument
        {
            DocType = DocumentType.KuitansiCds,
            Title = "Kuitansi Bukti Terima (CDS Satuan)",
            Subtitle = $"{recipient.Nama} ({recipient.Nik}) - Rp {recipient.Nominal:N0}",
            HeaderInfo = $"Program: {recipient.Program} | No Voucher: {recipient.NoVoucher}",
            Records = Array.Empty<PenerimaBansos>(),
            FormattedContent = sb.ToString(),
            QrCodePayloadSample = qrPayload,
            QrPayloadValid = isValid,
            QrValidationMessage = message,
            QrCodeImagePngBytes = pngBytes
        });
    }
}

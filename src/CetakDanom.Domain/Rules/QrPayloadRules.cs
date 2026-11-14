using System.Text.RegularExpressions;

namespace CetakDanom.Domain.Rules;

/// <summary>
/// Aturan bisnis dan spesifikasi kontrak Barcode 2D (QR Code) Kuitansi Bukti Terima.
/// Berdasarkan implementasi FastReport Delphi (frBuktiTerima.fr3):
/// Payload = Copy(ID_PELANGGAN,1,19) + Tahap + '|' + NIK + '|' + NAMA + '|' + ALAMAT_KTP + '|' + ALAMAT + '|' + BSU
/// </summary>
public static class QrPayloadRules
{
    public const char Delimiter = '|';
    public const int RequiredSegmentCount = 6;

    /// <summary>
    /// Merangkai payload Barcode 2D kuitansi sesuai standar baku FastReport eksisting.
    /// Karakter pipa (|) adalah delimiter resmi yang wajib memisahkan ke-6 segmen data.
    /// Karakter pipa liar di dalam isi teks nama/alamat dinetralisir menjadi spasi.
    /// </summary>
    public static string BuildPayload(
        string idPelanggan,
        string tahap,
        string nik,
        string nama,
        string alamatKtp,
        string alamat,
        decimal nominal)
    {
        // 1. Ekstraksi ID Pelanggan (19 karakter pertama) + Tahap (1 karakter)
        string id19 = idPelanggan.Length >= 19 ? idPelanggan.Substring(0, 19) : idPelanggan.PadRight(19, '0');
        string thp = string.IsNullOrWhiteSpace(tahap) ? "1" : tahap.Trim().Substring(0, 1);
        string seg1IdTahap = id19 + thp;

        // 2. NIK (16 digit angka)
        string seg2Nik = SanitizeNik(nik);

        // 3. Nama KPM (netralkan karakter pipa liar di dalam nama jika ada)
        string seg3Nama = SanitizeTextField(nama);

        // 4. Alamat KTP (netralkan karakter pipa liar di dalam alamat jika ada)
        string seg4AlamatKtp = SanitizeTextField(alamatKtp);

        // 5. Alamat Domisili (netralkan karakter pipa liar di dalam alamat jika ada)
        string seg5Alamat = SanitizeTextField(alamat);

        // 6. BSU / Nominal (format ribuan sesuai FastReport: FormatFloat('#,##0', TOTAL))
        string seg6Bsu = nominal.ToString("#,##0", new System.Globalization.CultureInfo("en-US"));

        return $"{seg1IdTahap}{Delimiter}{seg2Nik}{Delimiter}{seg3Nama}{Delimiter}{seg4AlamatKtp}{Delimiter}{seg5Alamat}{Delimiter}{seg6Bsu}";
    }

    /// <summary>
    /// Validasi ketat bahwa payload memenuhi kontrak 6 segmen berpemisah pipa.
    /// </summary>
    public static (bool IsValid, string Message, string[] Segments) ValidatePayload(string payload)
    {
        if (string.IsNullOrWhiteSpace(payload))
        {
            return (false, "Payload barcode tidak boleh kosong.", Array.Empty<string>());
        }

        string[] segments = payload.Split(Delimiter);
        if (segments.Length != RequiredSegmentCount)
        {
            return (false, $"Pelanggaran kontrak payload QR Code: Ditemukan {segments.Length} segmen, diekspektasikan tepat {RequiredSegmentCount} segmen berpemisah pipa ('|').", segments);
        }

        // Validasi Segmen 1: ID Pelanggan + Tahap (Minimal 20 karakter)
        if (segments[0].Length < 20)
        {
            return (false, $"Segmen 1 (ID_PELANGGAN + TAHAP) tidak valid: Panjang {segments[0].Length} kurang dari 20 karakter.", segments);
        }

        // Validasi Segmen 2: NIK (Harus 16 digit angka)
        if (!Regex.IsMatch(segments[1], @"^\d{16}$"))
        {
            return (false, $"Segmen 2 (NIK) tidak valid: '{segments[1]}' bukan 16 digit angka numerik.", segments);
        }

        // Validasi Segmen 3: Nama KPM (Tidak boleh kosong)
        if (string.IsNullOrWhiteSpace(segments[2]))
        {
            return (false, "Segmen 3 (Nama KPM) tidak boleh kosong.", segments);
        }

        // Validasi Segmen 6: BSU / Nominal (Harus memiliki nilai nominal yang valid)
        if (string.IsNullOrWhiteSpace(segments[5]))
        {
            return (false, "Segmen 6 (Nominal BSU) tidak boleh kosong.", segments);
        }

        return (true, "Payload QR Code valid dan memenuhi kontrak 6 segmen berpemisah pipa.", segments);
    }

    /// <summary>
    /// Menetralkan karakter pipa liar (|) di dalam teks agar tidak memecah struktur parsing aplikasi lain.
    /// </summary>
    public static string SanitizeTextField(string? text)
    {
        if (string.IsNullOrEmpty(text)) return string.Empty;
        return text.Replace('|', ' ').Trim();
    }

    public static string SanitizeNik(string? nik)
    {
        if (string.IsNullOrWhiteSpace(nik)) return new string('0', 16);
        string digitsOnly = Regex.Replace(nik, @"\D", "");
        return digitsOnly.Length == 16 ? digitsOnly : digitsOnly.PadRight(16, '0');
    }
}

namespace CetakDanom.Domain.Models;

/// <summary>
/// Model baris data ekspor CSV BNBA (By Name By Address).
/// Sesuai skema 14 kolom persis pada TFrm_Main.btn_BNBAClick di Delphi:
/// BST;REGIONAL;KANTOR;PROVINSI;KABUPATEN;KECAMATAN;DESA/KELURAHAN;BATCH;NAMA;NOMINAL;NIK;ALAMAT;DANOM;PERCENTILE
/// Kolom NIK dan DANOM wajib diawali karakter backtick (`) untuk mencegah auto-konversi ilmiah Excel.
/// </summary>
public class BnbaRecord
{
    public const string HeaderLine = "BST;REGIONAL;KANTOR;PROVINSI;KABUPATEN;KECAMATAN;DESA/KELURAHAN;BATCH;NAMA;NOMINAL;NIK;ALAMAT;DANOM;PERCENTILE";

    public string Bst { get; set; } = string.Empty;
    public string Regional { get; set; } = string.Empty;
    public string Kantor { get; set; } = string.Empty;
    public string Provinsi { get; set; } = string.Empty;
    public string Kabupaten { get; set; } = string.Empty;
    public string Kecamatan { get; set; } = string.Empty;
    public string DesaKelurahan { get; set; } = string.Empty;
    public string Batch { get; set; } = string.Empty;
    public string Nama { get; set; } = string.Empty;
    public string Nominal { get; set; } = string.Empty;
    public string Nik { get; set; } = string.Empty;
    public string Alamat { get; set; } = string.Empty;
    public string Danom { get; set; } = string.Empty;
    public string Percentile { get; set; } = string.Empty;

    /// <summary>
    /// Menghasilkan 1 baris CSV berpemisah titik koma (;) dengan backtick pada NIK dan DANOM.
    /// </summary>
    public string ToCsvRow()
    {
        // Format NIK dengan backtick: `3201021234560001
        string nikWithBacktick = Nik.StartsWith("`") ? Nik : $"`{Nik}";

        // Format Danom dengan backtick: `0001
        string danomWithBacktick = Danom.StartsWith("`") ? Danom : $"`{Danom}";

        return $"{Sanitize(Bst)};{Sanitize(Regional)};{Sanitize(Kantor)};{Sanitize(Provinsi)};{Sanitize(Kabupaten)};{Sanitize(Kecamatan)};{Sanitize(DesaKelurahan)};{Sanitize(Batch)};{Sanitize(Nama)};{Sanitize(Nominal)};{nikWithBacktick};{Sanitize(Alamat)};{danomWithBacktick};{Sanitize(Percentile)};";
    }

    private static string Sanitize(string? value)
    {
        if (string.IsNullOrEmpty(value)) return string.Empty;
        // Hindari karakter titik koma internal agar tidak merusak delimitasi kolom CSV
        return value.Replace(';', ' ').Trim();
    }
}

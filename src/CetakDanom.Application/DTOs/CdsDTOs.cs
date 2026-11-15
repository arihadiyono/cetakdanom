namespace CetakDanom.Application.DTOs;

/// <summary>
/// DTO hasil inquiry NIK penerima bantuan satuan (CDS BLT BBM / BSU / Bansos Susulan).
/// Struktur ini sesuai persis dengan kontrak JSON response WSO2 Gateway /cds_blt/getData2 pada CDS.exe.
/// </summary>
public class CdsBltRecipientDto
{
    public string IdResponse { get; set; } = "000";
    public string Response { get; set; } = "Success";
    public string IdPelanggan { get; set; } = string.Empty;
    public string Nik { get; set; } = string.Empty;
    public string Nama { get; set; } = string.Empty;
    public string AlamatDtks { get; set; } = string.Empty;
    public string NmDesaDtks { get; set; } = string.Empty;
    public string NmKecDtks { get; set; } = string.Empty;
    public string NmKabDtks { get; set; } = string.Empty;
    public string NmPropDtks { get; set; } = string.Empty;
    public int Kuantitas { get; set; } = 1;
    public decimal Nominal { get; set; } = 0;
    public string HeaderDanom { get; set; } = string.Empty;
    public string NoVoucher { get; set; } = string.Empty;
    public string NamaPerusahaan { get; set; } = string.Empty;
    public string AlamatPerusahaan { get; set; } = string.Empty;
    public string Program { get; set; } = "BLT BBM / BSU";
}

/// <summary>
/// DTO Request Inquiry NIK pada Cetak Danom Satuan
/// </summary>
public class CdsInquiryRequestDto
{
    public string Nik { get; set; } = string.Empty;
    public string ClientVersion { get; set; } = "5.0.0";
}

using System.Text;
using CetakDanom.Application.DTOs;
using CetakDanom.Application.Interfaces;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Infrastructure.Mock;

/// <summary>
/// MOCK IMPLEMENTATION ONLY.
/// Menyimulasikan pembacaan parameter surat (param_xxx.pos) dan logo (logoxxx.jpg),
/// serta memformat surat pemberitahuan penerima bantuan sosial untuk pencetakan.
/// </summary>
public class MockSuratService : ISuratService
{
    private readonly IQrCodeService _qrCodeService;

    public MockSuratService(IQrCodeService qrCodeService)
    {
        _qrCodeService = qrCodeService;
    }

    public Task<IReadOnlyList<SuratParameterDto>> GetAvailableParametersAsync(CancellationToken cancellationToken = default)
    {
        var list = new List<SuratParameterDto>
        {
            new()
            {
                ProjectCode = "BST",
                Subfix = "1",
                FileName = "param_bst_1.pos",
                JudulSurat = "SURAT PEMBERITAHUAN PENYALURAN BANTUAN SOSIAL TUNAI (BST)",
                LogoFileName = "logo_perusahaan.jpg",
                LogoInstansiFileName = "logo_bst_1.jpg",
                IsiTeksSurat = new List<string>
                {
                    "Diberitahukan kepada Keluarga Penerima Manfaat (KPM) bahwa dana Bantuan Sosial Tunai (BST) telah dapat dicairkan melalui Kantor Pos.",
                    "Penyaluran dilakukan dengan tetap menerapkan protokol pelayanan tertib dan menunjukkan dokumen identitas asli.",
                    "Persyaratan pengambilan bantuan:",
                    "1. Membawa Asli KTP Elektronik (KTP-el) penerima yang masih berlaku.",
                    "2. Membawa Asli Kartu Keluarga (KK).",
                    "3. Membawa Surat Pemberitahuan ini saat datang ke loket Kantor Pos / Komunitas.",
                    "Dana bantuan tidak dikenakan potongan biaya apapun dari pihak manapun."
                }
            },
            new()
            {
                ProjectCode = "PKH",
                Subfix = "2",
                FileName = "param_pkh_2.pos",
                JudulSurat = "SURAT PEMBERITAHUAN PENYALURAN PROGRAM KELUARGA HARAPAN (PKH)",
                LogoFileName = "logo_perusahaan.jpg",
                LogoInstansiFileName = "logo_pkh_2.jpg",
                IsiTeksSurat = new List<string>
                {
                    "Kementerian Sosial RI melalui PT Pos Indonesia (Persero) menyalurkan dana bantuan Program Keluarga Harapan (PKH).",
                    "KPM diharapkan hadir sesuai jadwal dan lokasi yang telah ditentukan bersama pendamping PKH setempat.",
                    "Persyaratan wajib:",
                    "1. Membawa KTP-el dan Kartu Keluarga asli.",
                    "2. Jika berhalangan karena sakit keras/lansia, pengambilan dapat diwakilkan oleh anggota keluarga dalam 1 KK dengan surat kuasa bermeterai.",
                    "Bantuan ini ditujukan untuk peningkatan gizi, pendidikan anak, dan kesehatan keluarga."
                }
            },
            new()
            {
                ProjectCode = "BLT",
                Subfix = "1",
                FileName = "param_blt_1.pos",
                JudulSurat = "SURAT UNDANGAN PENERIMA BANTUAN LANGSUNG TUNAI (BLT) BBM",
                LogoFileName = "logo_perusahaan.jpg",
                LogoInstansiFileName = "logo_blt_1.jpg",
                IsiTeksSurat = new List<string>
                {
                    "Bersama ini kami mengundang Saudara/i Penerima Bantuan Langsung Tunai (BLT) BBM untuk mengambil dana bantuan di lokasi pelayanan Kantor Pos.",
                    "Waktu pelayanan dimulai pukul 08.00 s.d. 16.00 WIB sesuai jadwal per RW/Dusun.",
                    "Kelengkapan dokumen yang wajib dibawa:",
                    "1. Surat Pemberitahuan/Undangan ber-QR Code ini.",
                    "2. KTP-el Asli Penerima dan Kartu Keluarga (KK) Asli.",
                    "Petugas berhak menolak pembayaran apabila data identitas fisik tidak sesuai dengan dokumen resmi."
                }
            },
            new()
            {
                ProjectCode = "SEM",
                Subfix = "1",
                FileName = "param_sem_1.pos",
                JudulSurat = "SURAT PEMBERITAHUAN BANTUAN PANGAN NON TUNAI / PROGRAM SEMBAKO",
                LogoFileName = "logo_perusahaan.jpg",
                LogoInstansiFileName = "logo_sem_1.jpg",
                IsiTeksSurat = new List<string>
                {
                    "Pemberitahuan penyaluran Program Sembako Tunai tahun anggaran berjalan melalui jaringan PT Pos Indonesia.",
                    "Dana bantuan sebesar Rp 200.000/bulan wajib dibelanjakan untuk bahan pangan yang mengandung karbohidrat, protein hewani, protein nabati, dan vitamin/mineral.",
                    "Dilarang keras membelanjakan dana bantuan untuk rokok, minuman keras, atau barang terlarang lainnya.",
                    "KPM wajib menandatangani Surat Pernyataan Tanggung Jawab Mutlak (SPTJM) pada saat penerimaan dana."
                }
            }
        };

        return Task.FromResult<IReadOnlyList<SuratParameterDto>>(list);
    }

    public async Task<SuratParameterDto> LoadParameterAsync(string projectCode, string subfix, CancellationToken cancellationToken = default)
    {
        var list = await GetAvailableParametersAsync(cancellationToken);
        var found = list.FirstOrDefault(p => 
            p.ProjectCode.Equals(projectCode, StringComparison.OrdinalIgnoreCase) && 
            p.Subfix.Equals(subfix, StringComparison.OrdinalIgnoreCase));

        return found ?? list[0];
    }

    public Task<PrintPreviewDocument> PrepareSuratPrintPreviewAsync(
        PenerimaBansos record, 
        SuratParameterDto parameter, 
        Petugas? petugas)
    {
        // Barcode payload surat pemberitahuan (NIK|NOMOR_DANOM|KANTOR)
        string qrPayload = $"{record.Nik}|{record.Danom}|{petugas?.Nopend ?? "40000"}|{parameter.ProjectCode}|{parameter.Subfix}";

        var sb = new StringBuilder();
        sb.AppendLine("====================================================================================================");
        sb.AppendLine("                                      PT POS INDONESIA (PERSERO)                                    ");
        sb.AppendLine($"               {parameter.JudulSurat}               ");
        sb.AppendLine($"                     KANTOR POS: {petugas?.Kantor ?? "KCU BANDUNG"} ({petugas?.Nopend ?? "40000"})                   ");
        sb.AppendLine("====================================================================================================");
        sb.AppendLine($"Nomor Berkas  : {parameter.ProjectCode}-{record.Danom:D6}/{DateTime.Now:yyyyMMdd}");
        sb.AppendLine($"Lampiran      : 1 (Satu) Lembar Bukti Pengambilan");
        sb.AppendLine($"Perihal       : Pemberitahuan Penyaluran Bantuan Sosial {parameter.ProjectCode} Tahap {parameter.Subfix}");
        sb.AppendLine($"Tanggal Cetak : {DateTime.Now:dd MMMM yyyy}");
        sb.AppendLine("----------------------------------------------------------------------------------------------------");
        sb.AppendLine("Kepada Yth. KPM Penerima Bantuan:");
        sb.AppendLine($"Nama Penerima : {record.Nama}");
        sb.AppendLine($"NIK           : {record.Nik}");
        sb.AppendLine($"Alamat        : {record.Alamat}");
        sb.AppendLine($"Wilayah       : Kel. {record.Kelurahan}, Kec. {record.Kecamatan}, {record.Kabupaten}");
        sb.AppendLine($"Nominal Bantuan : Rp {record.Nominal:N0}");
        sb.AppendLine($"Nomor Danom   : {record.Danom}");
        sb.AppendLine("----------------------------------------------------------------------------------------------------");
        sb.AppendLine("DOKUMEN PARAMETER & KLAUSUL (Disintesis dari " + parameter.FileName + "):");

        foreach (var paragraf in parameter.IsiTeksSurat)
        {
            sb.AppendLine($"  • {paragraf}");
        }

        sb.AppendLine("\nJADWAL & LOKASI PEMBAYARAN:");
        sb.AppendLine($"  Tempat  : Kantor Pos {petugas?.Kantor ?? "KCU BANDUNG"} / Loket Komunitas Kelurahan {record.Kelurahan}");
        sb.AppendLine($"  Waktu   : Jam Kerja (08:00 - 15:00 WIB)");
        sb.AppendLine("----------------------------------------------------------------------------------------------------");
        sb.AppendLine($"KODE VERIFIKASI QR CODE / BARCODE: {qrPayload}");
        sb.AppendLine("----------------------------------------------------------------------------------------------------");
        sb.AppendLine("\n                     Tanda Tangan Penerima,                      Kepala Kantor Pos,");
        sb.AppendLine($"\n\n\n               ( {record.Nama,-25} )             ( {petugas?.Nama ?? "MANAJER PELAYANAN",-25} )");
        sb.AppendLine("====================================================================================================");

        return Task.FromResult(new PrintPreviewDocument
        {
            DocType = DocumentType.SuratPemberitahuan,
            Title = parameter.JudulSurat,
            Subtitle = $"{record.Nama} ({record.Nik}) - Rp {record.Nominal:N0}",
            HeaderInfo = $"File Param: {parameter.FileName} | Logo: {parameter.LogoFileName}",
            Records = new[] { record },
            FormattedContent = sb.ToString(),
            QrCodePayloadSample = qrPayload,
            QrPayloadValid = true
        });
    }
}

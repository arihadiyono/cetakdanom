using CetakDanom.Application.DTOs;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Application.Interfaces;

/// <summary>
/// Abstraksi layanan pencarian data KPM satuan (Inquiry NIK) dan pencetakan kuitansi tanda terima
/// (menggantikan fungsionalitas WSO2 Gateway /cds_blt/getData2 pada CDS.exe).
/// </summary>
public interface ICdsBltService
{
    Task<CdsBltRecipientDto?> InquiryNikAsync(string nik, CancellationToken cancellationToken = default);
    Task<PrintPreviewDocument> PrepareKuitansiCdsPrintPreviewAsync(CdsBltRecipientDto recipient, Petugas? petugas);
}

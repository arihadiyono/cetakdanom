using CetakDanom.Application.DTOs;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Application.Interfaces;

/// <summary>
/// Abstraksi pengelolaan parameter surat (param_xxx.pos & logoxxx.jpg) dan pembuatan dokumen cetak surat pemberitahuan.
/// </summary>
public interface ISuratService
{
    Task<IReadOnlyList<SuratParameterDto>> GetAvailableParametersAsync(CancellationToken cancellationToken = default);
    Task<SuratParameterDto> LoadParameterAsync(string projectCode, string subfix, CancellationToken cancellationToken = default);
    Task<PrintPreviewDocument> PrepareSuratPrintPreviewAsync(PenerimaBansos record, SuratParameterDto parameter, Petugas? petugas);
}

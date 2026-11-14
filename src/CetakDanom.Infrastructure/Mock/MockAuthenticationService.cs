using CetakDanom.Application.DTOs;
using CetakDanom.Application.Interfaces;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Infrastructure.Mock;

/// <summary>
/// MOCK IMPLEMENTATION ONLY.
/// Mensimulasikan autentikasi petugas loket tanpa koneksi ke database produksi SIKAP/SQL Server.
/// </summary>
public class MockAuthenticationService : IAuthenticationService
{
    private Petugas? _currentPetugas;

    public Petugas? CurrentPetugas => _currentPetugas;
    public bool IsAuthenticated => _currentPetugas != null;

    private static readonly Dictionary<string, (string Password, Petugas Petugas)> DemoAccounts = new(StringComparer.OrdinalIgnoreCase)
    {
        {
            "demo",
            (
                "demo123",
                new Petugas
                {
                    IdPetugas = "PETUGAS_DEMO",
                    Nippos = "987654321",
                    Nama = "AHMAD HIDAYAT",
                    Nopend = "40000",
                    Kantor = "KCU BANDUNG",
                    Jabatan = "PETUGAS LOKET UTAMA"
                }
            )
        },
        {
            "petugas01",
            (
                "pos12345",
                new Petugas
                {
                    IdPetugas = "PETUGAS_001",
                    Nippos = "987650001",
                    Nama = "SITI NURHALIZA",
                    Nopend = "40000",
                    Kantor = "KCU BANDUNG",
                    Jabatan = "OPERATOR CETAK DANOM"
                }
            )
        },
        {
            "supervisor",
            (
                "super123",
                new Petugas
                {
                    IdPetugas = "SPV_001",
                    Nippos = "987600001",
                    Nama = "BAMBANG SUDARMO",
                    Nopend = "40000",
                    Kantor = "KCU BANDUNG",
                    Jabatan = "MANAJER PELAYANAN BANSOS"
                }
            )
        }
    };

    public Task<LoginResult> LoginAsync(LoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.UserId))
        {
            return Task.FromResult(LoginResult.Failed("User ID tidak boleh kosong."));
        }

        if (string.IsNullOrWhiteSpace(request.Password))
        {
            return Task.FromResult(LoginResult.Failed("Kata sandi tidak boleh kosong."));
        }

        if (DemoAccounts.TryGetValue(request.UserId.Trim(), out var account))
        {
            if (account.Password == request.Password)
            {
                _currentPetugas = new Petugas
                {
                    IdPetugas = account.Petugas.IdPetugas,
                    Nippos = account.Petugas.Nippos,
                    Nama = account.Petugas.Nama,
                    Nopend = account.Petugas.Nopend,
                    Kantor = account.Petugas.Kantor,
                    Jabatan = account.Petugas.Jabatan,
                    LoginTime = DateTime.Now
                };
                return Task.FromResult(LoginResult.Success(_currentPetugas));
            }
        }

        return Task.FromResult(LoginResult.Failed("User ID atau kata sandi tidak valid. Gunakan akun demo: 'demo' / 'demo123'.", "002"));
    }

    public void Logout()
    {
        _currentPetugas = null;
    }
}

using CetakDanom.Application.DTOs;
using CetakDanom.Application.Interfaces;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Infrastructure.Api;

public class ApiAuthenticationService : IAuthenticationService
{
    private readonly CetakDanomApiClient _apiClient;
    private Petugas? _currentPetugas;

    public ApiAuthenticationService(CetakDanomApiClient apiClient)
    {
        _apiClient = apiClient;
    }

    public Petugas? CurrentPetugas => _currentPetugas;

    public bool IsAuthenticated => _currentPetugas != null;

    public async Task<LoginResult> LoginAsync(LoginRequest request)
    {
        try
        {
            var res = await _apiClient.LoginAsync(request.UserId, request.Password, request.AppVersion);
            if (res == null)
            {
                return LoginResult.Failed("Login gagal: respon kosong dari server.");
            }

            _currentPetugas = new Petugas
            {
                IdPetugas = res.IdPetugas,
                Nippos = res.Nippos,
                Nama = res.Nama,
                Nopend = res.Nopend,
                Kantor = res.Kantor,
                Jabatan = res.Jabatan,
                LoginTime = DateTime.Now
            };

            return LoginResult.Success(_currentPetugas);
        }
        catch (HttpRequestException ex)
        {
            return LoginResult.Failed(ex.Message);
        }
        catch (Exception ex)
        {
            return LoginResult.Failed($"Gagal menghubungi layanan autentikasi: {ex.Message}");
        }
    }

    public void Logout()
    {
        _currentPetugas = null;
    }
}

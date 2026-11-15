using CetakDanom.Application.DTOs;
using CetakDanom.Infrastructure.Mock;
using Xunit;

namespace CetakDanom.UnitTests;

public class WilayahAndAuthTests
{
    [Fact]
    public async Task WilayahRepository_ShouldReturnValidCascadingHierarchy()
    {
        // Arrange
        var repo = new MockWilayahRepository();

        // Act
        var provs = await repo.GetProvinsiAsync();
        Assert.NotEmpty(provs);
        var jabar = provs.FirstOrDefault(p => p.Kode == "32");
        Assert.NotNull(jabar);

        var kabs = await repo.GetKabupatenAsync(jabar.Kode);
        Assert.NotEmpty(kabs);
        var kotaBandung = kabs.FirstOrDefault(k => k.Kode == "3273");
        Assert.NotNull(kotaBandung);

        var kecs = await repo.GetKecamatanAsync(kotaBandung.Kode);
        Assert.NotEmpty(kecs);
        var coblong = kecs.FirstOrDefault(k => k.Kode == "327301");
        Assert.NotNull(coblong);

        var kels = await repo.GetKelurahanAsync(coblong.Kode);
        Assert.NotEmpty(kels);
        Assert.Contains(kels, k => k.Nama == "DAGO");
    }

    [Fact]
    public async Task AuthenticationService_DemoAccount_ShouldLoginSuccessfully()
    {
        // Arrange
        var authService = new MockAuthenticationService();

        // Act
        var result = await authService.LoginAsync(new LoginRequest
        {
            UserId = "demo",
            Password = "demo123"
        });

        // Assert
        Assert.True(result.IsSuccess);
        Assert.Equal("000", result.StatusCode);
        Assert.NotNull(result.Petugas);
        Assert.Equal("40000", result.Petugas.Nopend);
        Assert.Equal("KCU BANDUNG", result.Petugas.Kantor);
        Assert.True(authService.IsAuthenticated);

        // Act: Logout
        authService.Logout();
        Assert.False(authService.IsAuthenticated);
        Assert.Null(authService.CurrentPetugas);
    }

    [Fact]
    public async Task AuthenticationService_WrongPassword_ShouldFail()
    {
        // Arrange
        var authService = new MockAuthenticationService();

        // Act
        var result = await authService.LoginAsync(new LoginRequest
        {
            UserId = "demo",
            Password = "wrongpassword"
        });

        // Assert
        Assert.False(result.IsSuccess);
        Assert.Equal("002", result.StatusCode);
        Assert.False(authService.IsAuthenticated);
    }

    [Fact]
    public async Task ApiAuthenticationService_LoginTPETUGAS_ShouldSucceed()
    {
        var apiClient = new CetakDanom.Infrastructure.Api.CetakDanomApiClient();
        bool isOnline = await apiClient.CheckHealthAsync();
        if (!isOnline) return; // Skip if API not running

        var authService = new CetakDanom.Infrastructure.Api.ApiAuthenticationService(apiClient);
        var result = await authService.LoginAsync(new LoginRequest
        {
            UserId = "asep",
            Password = "123"
        });

        Assert.True(result.IsSuccess);
        Assert.NotNull(result.Petugas);
        Assert.Equal("asep", result.Petugas.IdPetugas);
        Assert.Equal("40005", result.Petugas.Nopend);
        Assert.Equal("WESELPOSPUSAT", result.Petugas.Kantor);
    }

    [Fact]
    public async Task ApiWilayahRepository_DynamicRules_ShouldFollowUserSpecification()
    {
        var apiClient = new CetakDanom.Infrastructure.Api.CetakDanomApiClient();
        bool isOnline = await apiClient.CheckHealthAsync();
        if (!isOnline) return;

        var repo = new CetakDanom.Infrastructure.Api.ApiWilayahRepository(apiClient);

        // 1. Projects for NASIONAL, LOKAL, INSTANSI/LEMBAGA
        var projsNas = await repo.GetProjectsAsync("NASIONAL");
        Assert.NotEmpty(projsNas);

        var projsLokal = await repo.GetProjectsAsync("LOKAL");
        Assert.NotEmpty(projsLokal);

        var projsIns = await repo.GetProjectsAsync("INSTANSI/LEMBAGA");
        Assert.NotEmpty(projsIns);

        // 2. Tahap for ARSA in NASIONAL
        var tahapsNas = await repo.GetTahapAsync("NASIONAL", "ARSA");
        Assert.NotEmpty(tahapsNas);

        // 3. Wilayah cascade: Kabupaten -> Kecamatan -> Desa
        var kabs = await repo.GetAllKabupatenAsync();
        Assert.NotEmpty(kabs);

        var kab3204 = kabs.FirstOrDefault(k => k.Kode.StartsWith("3204"));
        Assert.NotNull(kab3204);

        var kecs = await repo.GetKecamatanByKabupatenAsync("3204");
        Assert.NotEmpty(kecs);

        var kec320416 = kecs.FirstOrDefault(k => k.Kode.StartsWith("320416"));
        Assert.NotNull(kec320416);

        var desas = await repo.GetDesaByKecamatanAsync("320416", "3204");
        Assert.NotEmpty(desas);
    }
}

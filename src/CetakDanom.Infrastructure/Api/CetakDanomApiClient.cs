using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using CetakDanom.Application.DTOs;
using CetakDanom.Domain.Entities;

namespace CetakDanom.Infrastructure.Api;

public class ApiEnvelope<T>
{
    [JsonPropertyName("success")]
    public bool Success { get; set; }

    [JsonPropertyName("message")]
    public string Message { get; set; } = string.Empty;

    [JsonPropertyName("data")]
    public T? Data { get; set; }
}

public class ApiLayananDto
{
    [JsonPropertyName("kode")]
    public string Kode { get; set; } = string.Empty;

    [JsonPropertyName("nama")]
    public string Nama { get; set; } = string.Empty;

    [JsonPropertyName("headerDanom")]
    public string HeaderDanom { get; set; } = string.Empty;
}

public class ApiTahapDto
{
    [JsonPropertyName("batch")]
    public string Batch { get; set; } = string.Empty;
}

public class ApiKabupatenDto
{
    [JsonPropertyName("kode")]
    public string Kode { get; set; } = string.Empty;

    [JsonPropertyName("nama")]
    public string Nama { get; set; } = string.Empty;
}

public class ApiKecamatanDto
{
    [JsonPropertyName("kode")]
    public string Kode { get; set; } = string.Empty;

    [JsonPropertyName("nama")]
    public string Nama { get; set; } = string.Empty;

    [JsonPropertyName("kabupatenId")]
    public string KabupatenId { get; set; } = string.Empty;
}

public class ApiKelurahanDto
{
    [JsonPropertyName("kode")]
    public string Kode { get; set; } = string.Empty;

    [JsonPropertyName("nama")]
    public string Nama { get; set; } = string.Empty;

    [JsonPropertyName("kecamatanId")]
    public string KecamatanId { get; set; } = string.Empty;

    [JsonPropertyName("kecamatanNama")]
    public string KecamatanNama { get; set; } = string.Empty;
}

public class ApiLoginResponseDto
{
    [JsonPropertyName("idPetugas")]
    public string IdPetugas { get; set; } = string.Empty;

    [JsonPropertyName("nippos")]
    public string Nippos { get; set; } = string.Empty;

    [JsonPropertyName("nama")]
    public string Nama { get; set; } = string.Empty;

    [JsonPropertyName("nopend")]
    public string Nopend { get; set; } = string.Empty;

    [JsonPropertyName("kantor")]
    public string Kantor { get; set; } = string.Empty;

    [JsonPropertyName("jabatan")]
    public string Jabatan { get; set; } = string.Empty;

    [JsonPropertyName("status")]
    public string Status { get; set; } = string.Empty;

    [JsonPropertyName("token")]
    public string Token { get; set; } = string.Empty;
}

public class ApiProjectDto
{
    [JsonPropertyName("idProject")]
    public string IdProject { get; set; } = string.Empty;

    [JsonPropertyName("deskripsi")]
    public string Deskripsi { get; set; } = string.Empty;
}

public class ApiTahapRefDto
{
    [JsonPropertyName("idTahap")]
    public string IdTahap { get; set; } = string.Empty;

    [JsonPropertyName("ketTahap")]
    public string KetTahap { get; set; } = string.Empty;
}

public class ApiDesaDto
{
    [JsonPropertyName("kode")]
    public string Kode { get; set; } = string.Empty;

    [JsonPropertyName("nama")]
    public string Nama { get; set; } = string.Empty;

    [JsonPropertyName("kecamatanId")]
    public string KecamatanId { get; set; } = string.Empty;

    [JsonPropertyName("kabupatenId")]
    public string KabupatenId { get; set; } = string.Empty;
}

public class ApiDanomListDto
{
    [JsonPropertyName("records")]
    public List<ApiDanomRecipientDto> Records { get; set; } = new();

    [JsonPropertyName("totalKpm")]
    public int TotalKpm { get; set; }

    [JsonPropertyName("totalNominal")]
    public decimal TotalNominal { get; set; }
}

public class ApiDanomRecipientDto
{
    [JsonPropertyName("idPelanggan")]
    public string IdPelanggan { get; set; } = string.Empty;

    [JsonPropertyName("nik")]
    public string Nik { get; set; } = string.Empty;

    [JsonPropertyName("nama")]
    public string Nama { get; set; } = string.Empty;

    [JsonPropertyName("alamat")]
    public string Alamat { get; set; } = string.Empty;

    [JsonPropertyName("alamatKtp")]
    public string AlamatKtp { get; set; } = string.Empty;

    [JsonPropertyName("nominal")]
    public decimal Nominal { get; set; }

    [JsonPropertyName("kuantitas")]
    public int Kuantitas { get; set; }

    [JsonPropertyName("total")]
    public decimal Total { get; set; }

    [JsonPropertyName("idKelurahan")]
    public string IdKelurahan { get; set; } = string.Empty;

    [JsonPropertyName("kelurahan")]
    public string Kelurahan { get; set; } = string.Empty;

    [JsonPropertyName("idKecamatan")]
    public string IdKecamatan { get; set; } = string.Empty;

    [JsonPropertyName("kecamatan")]
    public string Kecamatan { get; set; } = string.Empty;

    [JsonPropertyName("idKabupaten")]
    public string IdKabupaten { get; set; } = string.Empty;

    [JsonPropertyName("kabupaten")]
    public string Kabupaten { get; set; } = string.Empty;

    [JsonPropertyName("idProvinsi")]
    public string IdProvinsi { get; set; } = string.Empty;

    [JsonPropertyName("provinsi")]
    public string Provinsi { get; set; } = string.Empty;

    [JsonPropertyName("kprk")]
    public string Kprk { get; set; } = string.Empty;

    [JsonPropertyName("kantor")]
    public string Kantor { get; set; } = string.Empty;

    [JsonPropertyName("batch")]
    public string Batch { get; set; } = string.Empty;

    [JsonPropertyName("regional")]
    public string Regional { get; set; } = string.Empty;

    [JsonPropertyName("bs1")]
    public string Bs1 { get; set; } = string.Empty;

    [JsonPropertyName("barcode1")]
    public string Barcode1 { get; set; } = string.Empty;

    [JsonPropertyName("headerDanom")]
    public string HeaderDanom { get; set; } = string.Empty;

    [JsonPropertyName("rw")]
    public string Rw { get; set; } = string.Empty;

    [JsonPropertyName("rt")]
    public string Rt { get; set; } = string.Empty;

    [JsonPropertyName("statusDanom")]
    public string StatusDanom { get; set; } = "BelumCetak";
}

public class CetakDanomApiClient
{
    private readonly HttpClient _httpClient;
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true
    };

    public CetakDanomApiClient(HttpClient? httpClient = null)
    {
        var baseUrl = Environment.GetEnvironmentVariable("CETAKDANOM_API_URL") ?? "http://localhost:8080";
        _httpClient = httpClient ?? new HttpClient();
        if (_httpClient.BaseAddress == null)
        {
            _httpClient.BaseAddress = new Uri(baseUrl.TrimEnd('/') + "/");
        }
        _httpClient.Timeout = TimeSpan.FromSeconds(30);
    }

    public async Task<bool> CheckHealthAsync(CancellationToken ct = default)
    {
        try
        {
            var res = await _httpClient.GetFromJsonAsync<JsonElement>("api/v1/health", JsonOptions, ct);
            return res.TryGetProperty("status", out var s) && s.GetString() == "ok";
        }
        catch
        {
            return false;
        }
    }

    public async Task<ApiLoginResponseDto?> LoginAsync(string username, string password, string appVersion = "5.0.0", CancellationToken ct = default)
    {
        var payload = new { username, password, appVersion };
        var response = await _httpClient.PostAsJsonAsync("api/v1/auth/login", payload, JsonOptions, ct);
        if (!response.IsSuccessStatusCode)
        {
            var err = await response.Content.ReadFromJsonAsync<ApiEnvelope<object>>(JsonOptions, ct);
            throw new HttpRequestException(err?.Message ?? $"Login gagal (HTTP {(int)response.StatusCode})");
        }
        var result = await response.Content.ReadFromJsonAsync<ApiEnvelope<ApiLoginResponseDto>>(JsonOptions, ct);
        return result?.Data;
    }

    public async Task<List<ApiProjectDto>> GetProjectsAsync(string jenis = "NASIONAL", CancellationToken ct = default)
    {
        var url = $"api/v1/reference/project?jenis={Uri.EscapeDataString(jenis)}";
        var res = await _httpClient.GetFromJsonAsync<ApiEnvelope<List<ApiProjectDto>>>(url, JsonOptions, ct);
        return res?.Data ?? new List<ApiProjectDto>();
    }

    public async Task<List<ApiTahapRefDto>> GetTahapAsync(string jenis, string projectId, CancellationToken ct = default)
    {
        var url = $"api/v1/reference/tahap?jenis={Uri.EscapeDataString(jenis)}&project_id={Uri.EscapeDataString(projectId)}";
        var res = await _httpClient.GetFromJsonAsync<ApiEnvelope<List<ApiTahapRefDto>>>(url, JsonOptions, ct);
        return res?.Data ?? new List<ApiTahapRefDto>();
    }

    public async Task<List<ApiKabupatenDto>> GetAllKabupatenAsync(CancellationToken ct = default)
    {
        var url = "api/v1/reference/kabupaten";
        var res = await _httpClient.GetFromJsonAsync<ApiEnvelope<List<ApiKabupatenDto>>>(url, JsonOptions, ct);
        return res?.Data ?? new List<ApiKabupatenDto>();
    }

    public async Task<List<ApiKecamatanDto>> GetKecamatanByKabupatenAsync(string kabupatenId, CancellationToken ct = default)
    {
        var url = $"api/v1/reference/kecamatan?kabupaten_id={Uri.EscapeDataString(kabupatenId)}";
        var res = await _httpClient.GetFromJsonAsync<ApiEnvelope<List<ApiKecamatanDto>>>(url, JsonOptions, ct);
        return res?.Data ?? new List<ApiKecamatanDto>();
    }

    public async Task<List<ApiDesaDto>> GetDesaByKecamatanAsync(string kecamatanId, string kabupatenId = "", CancellationToken ct = default)
    {
        var url = $"api/v1/reference/desa?kecamatan_id={Uri.EscapeDataString(kecamatanId)}";
        if (!string.IsNullOrEmpty(kabupatenId))
        {
            url += $"&kabupaten_id={Uri.EscapeDataString(kabupatenId)}";
        }
        var res = await _httpClient.GetFromJsonAsync<ApiEnvelope<List<ApiDesaDto>>>(url, JsonOptions, ct);
        return res?.Data ?? new List<ApiDesaDto>();
    }

    public async Task<List<ApiLayananDto>> GetLayananAsync(CancellationToken ct = default)
    {
        var res = await _httpClient.GetFromJsonAsync<ApiEnvelope<List<ApiLayananDto>>>("api/v1/reference/layanan", JsonOptions, ct);
        return res?.Data ?? new List<ApiLayananDto>();
    }

    public async Task<List<string>> GetTahapAsync(string projectId, CancellationToken ct = default)
    {
        var res = await _httpClient.GetFromJsonAsync<ApiEnvelope<List<ApiTahapDto>>>($"api/v1/reference/tahap?project_id={Uri.EscapeDataString(projectId)}", JsonOptions, ct);
        return res?.Data?.Select(t => t.Batch).ToList() ?? new List<string>();
    }

    public async Task<List<ApiKabupatenDto>> GetKabupatenAsync(string nopend = "40000", string idPetugas = "demo", string nippos = "987654321", CancellationToken ct = default)
    {
        var url = $"api/v1/reference/kabupaten?nopend={nopend}&id_petugas={idPetugas}&nippos={nippos}";
        var res = await _httpClient.GetFromJsonAsync<ApiEnvelope<List<ApiKabupatenDto>>>(url, JsonOptions, ct);
        return res?.Data ?? new List<ApiKabupatenDto>();
    }

    public async Task<List<ApiKecamatanDto>> GetKecamatanAsync(string kabupatenId, string nopend = "40000", string idPetugas = "demo", string nippos = "987654321", CancellationToken ct = default)
    {
        var url = $"api/v1/reference/kecamatan?kabupaten_id={Uri.EscapeDataString(kabupatenId)}&nopend={nopend}&id_petugas={idPetugas}&nippos={nippos}";
        var res = await _httpClient.GetFromJsonAsync<ApiEnvelope<List<ApiKecamatanDto>>>(url, JsonOptions, ct);
        return res?.Data ?? new List<ApiKecamatanDto>();
    }

    public async Task<List<ApiKelurahanDto>> GetKelurahanAsync(string kecamatanId, string nopend = "40000", string idPetugas = "demo", string nippos = "987654321", CancellationToken ct = default)
    {
        var url = $"api/v1/reference/kelurahan?kecamatan_id={Uri.EscapeDataString(kecamatanId)}&nopend={nopend}&id_petugas={idPetugas}&nippos={nippos}";
        var res = await _httpClient.GetFromJsonAsync<ApiEnvelope<List<ApiKelurahanDto>>>(url, JsonOptions, ct);
        return res?.Data ?? new List<ApiKelurahanDto>();
    }

    public async Task<ApiDanomListDto> GetDanomListAsync(
        string kelurahanId, 
        string batch, 
        string projectId = "SPK1", 
        string sort = "Nama", 
        string search = "",
        string jenis = "NASIONAL",
        int page = 0,
        int pageSize = 0,
        CancellationToken ct = default)
    {
        var url = $"api/v1/danom?kelurahan_id={Uri.EscapeDataString(kelurahanId)}&batch={Uri.EscapeDataString(batch)}&project_id={Uri.EscapeDataString(projectId)}&sort={Uri.EscapeDataString(sort)}&search={Uri.EscapeDataString(search)}&jenis={Uri.EscapeDataString(jenis)}";
        if (page > 0 && pageSize > 0)
        {
            url += $"&page={page}&page_size={pageSize}";
        }

        var res = await _httpClient.GetFromJsonAsync<ApiEnvelope<ApiDanomListDto>>(url, JsonOptions, ct);
        var data = res?.Data ?? new ApiDanomListDto();
        data.Records ??= new List<ApiDanomRecipientDto>();
        return data;
    }

    public async Task<CdsBltRecipientDto?> InquiryNikAsync(string nik, CancellationToken ct = default)
    {
        try
        {
            var url = $"api/v1/danom/inquiry?nik={Uri.EscapeDataString(nik)}";
            var res = await _httpClient.GetFromJsonAsync<ApiEnvelope<CdsBltRecipientDto>>(url, JsonOptions, ct);
            return res?.Data;
        }
        catch (HttpRequestException ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
        {
            return null;
        }
    }
}

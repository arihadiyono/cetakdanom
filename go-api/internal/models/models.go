package models

import "time"

// Standard API Response envelope
type ApiResponse[T any] struct {
	Success    bool        `json:"success"`
	Message    string      `json:"message"`
	Data       T           `json:"data"`
	Pagination *Pagination `json:"pagination,omitempty"`
}

type Pagination struct {
	Page         int `json:"page"`
	PageSize     int `json:"pageSize"`
	TotalRecords int `json:"totalRecords"`
	TotalPages   int `json:"totalPages"`
}

type HealthResponse struct {
	Status    string    `json:"status"`
	Service   string    `json:"service"`
	Database  string    `json:"database"`
	Timestamp time.Time `json:"timestamp"`
}

// Auth models
type LoginRequest struct {
	Username   string `json:"username"`
	Password   string `json:"password"`
	AppVersion string `json:"appVersion,omitempty"`
}

type LoginResponse struct {
	IdPetugas string `json:"idPetugas"`
	Nippos    string `json:"nippos"`
	Nama      string `json:"nama"`
	Nopend    string `json:"nopend"`
	Kantor    string `json:"kantor"`
	Jabatan   string `json:"jabatan"`
	Status    string `json:"status"`
	Token     string `json:"token"`
}

// Project & Tahap Reference models
type ProjectRef struct {
	IdProject string `json:"idProject"`
	Deskripsi string `json:"deskripsi"`
}

type TahapRef struct {
	IdTahap  string `json:"idTahap"`
	KetTahap string `json:"ketTahap"`
}

// Legacy compat
type LayananBansos struct {
	Kode        string `json:"kode"`
	Nama        string `json:"nama"`
	HeaderDanom string `json:"headerDanom"`
}

type TahapBansos struct {
	Batch string `json:"batch"`
}

// Wilayah Reference models
type WilayahKabupaten struct {
	Kode string `json:"kode"`
	Nama string `json:"nama"`
}

type WilayahKecamatan struct {
	Kode        string `json:"kode"`
	Nama        string `json:"nama"`
	KabupatenId string `json:"kabupatenId"`
}

type WilayahKelurahan struct {
	Kode          string `json:"kode"`
	Nama          string `json:"nama"`
	KecamatanId   string `json:"kecamatanId"`
	KecamatanNama string `json:"kecamatanNama"`
	KabupatenId   string `json:"kabupatenId,omitempty"`
}

type WilayahDesa struct {
	Kode        string `json:"kode"`
	Nama        string `json:"nama"`
	KecamatanId string `json:"kecamatanId"`
	KabupatenId string `json:"kabupatenId"`
}

type DanomRecipient struct {
	IdPelanggan string  `json:"idPelanggan"`
	Nik         string  `json:"nik"`
	Nama        string  `json:"nama"`
	Alamat      string  `json:"alamat"`
	AlamatKtp   string  `json:"alamatKtp"`
	Nominal     float64 `json:"nominal"`
	Kuantitas   int     `json:"kuantitas"`
	Total       float64 `json:"total"`
	IdKelurahan string  `json:"idKelurahan"`
	Kelurahan   string  `json:"kelurahan"`
	IdKecamatan string  `json:"idKecamatan"`
	Kecamatan   string  `json:"kecamatan"`
	IdKabupaten string  `json:"idKabupaten"`
	Kabupaten   string  `json:"kabupaten"`
	IdProvinsi  string  `json:"idProvinsi"`
	Provinsi    string  `json:"provinsi"`
	Kprk        string  `json:"kprk"`
	Kantor      string  `json:"kantor"`
	Batch       string  `json:"batch"`
	Regional    string  `json:"regional"`
	Bs1         string  `json:"bs1"`
	Barcode1    string  `json:"barcode1"`
	HeaderDanom string  `json:"headerDanom"`
	Rw          string  `json:"rw"`
	Rt          string  `json:"rt"`
	StatusDanom string  `json:"statusDanom"`
}

type DanomListResult struct {
	Records      []DanomRecipient `json:"records"`
	TotalKpm     int              `json:"totalKpm"`
	TotalNominal float64          `json:"totalNominal"`
}

type CdsRecipientInquiry struct {
	IdResponse       string  `json:"idResponse"`
	IdPelanggan      string  `json:"idPelanggan"`
	Nik              string  `json:"nik"`
	Nama             string  `json:"nama"`
	AlamatDtks       string  `json:"alamatDtks"`
	NmDesaDtks       string  `json:"nmDesaDtks"`
	NmKecDtks        string  `json:"nmKecDtks"`
	NmKabDtks        string  `json:"nmKabDtks"`
	NmPropDtks       string  `json:"nmPropDtks"`
	Nominal          float64 `json:"nominal"`
	NoVoucher        string  `json:"noVoucher"`
	NamaPerusahaan   string  `json:"namaPerusahaan"`
	AlamatPerusahaan string  `json:"alamatPerusahaan"`
}

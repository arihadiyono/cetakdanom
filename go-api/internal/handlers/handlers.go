package handlers

import (
	"context"
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"
	"strconv"
	"time"

	"cetakdanom/api/internal/database"
	"cetakdanom/api/internal/models"
	"cetakdanom/api/internal/repositories"
	"cetakdanom/api/internal/services"
)

type Handlers struct {
	db           *database.DB
	authService  *services.AuthService
	refService   *services.ReferenceService
	danomService *services.DanomService
}

func NewHandlers(
	db *database.DB,
	authService *services.AuthService,
	refService *services.ReferenceService,
	danomService *services.DanomService,
) *Handlers {
	return &Handlers{
		db:           db,
		authService:  authService,
		refService:   refService,
		danomService: danomService,
	}
}

// HealthHandler returns API health and database connectivity status
func (h *Handlers) HealthHandler(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := contextWithTimeout(r, 3*time.Second)
	defer cancel()

	dbStatus := "connected"
	if err := h.db.SQL.PingContext(ctx); err != nil {
		dbStatus = "disconnected: " + err.Error()
	}

	res := models.HealthResponse{
		Status:    "ok",
		Service:   "go-api",
		Database:  dbStatus,
		Timestamp: time.Now(),
	}

	statusCode := http.StatusOK
	if dbStatus != "connected" {
		statusCode = http.StatusServiceUnavailable
	}

	writeJSON(w, statusCode, res)
}

// LoginHandler handles user authentication against TPETUGAS joined with TKANTOR
func (h *Handlers) LoginHandler(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := contextWithTimeout(r, 10*time.Second)
	defer cancel()

	var req models.LoginRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Format JSON tidak valid: "+err.Error())
		return
	}

	res, err := h.authService.Authenticate(ctx, req.Username, req.Password)
	if err != nil {
		slog.Warn("login failed", "username", req.Username, "error", err)
		if errors.Is(err, repositories.ErrUserNotFound) {
			writeError(w, http.StatusUnauthorized, "User ID tidak terdaftar")
			return
		}
		if errors.Is(err, repositories.ErrInvalidPassword) {
			writeError(w, http.StatusUnauthorized, "Password salah")
			return
		}
		writeError(w, http.StatusUnauthorized, err.Error())
		return
	}

	slog.Info("login successful", "userId", res.IdPetugas, "kantor", res.Kantor, "nopend", res.Nopend)
	writeSuccess(w, "Login berhasil", res, nil)
}

// GetProjectHandler returns projects based on Jenis Bansos: NASIONAL, LOKAL, INSTANSI/LEMBAGA
func (h *Handlers) GetProjectHandler(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := contextWithTimeout(r, 10*time.Second)
	defer cancel()

	jenis := r.URL.Query().Get("jenis")
	if jenis == "" {
		jenis = "NASIONAL"
	}

	list, err := h.refService.GetProjects(ctx, jenis)
	if err != nil {
		slog.Error("failed to get projects", "error", err, "jenis", jenis)
		writeError(w, http.StatusInternalServerError, "Gagal mengambil daftar project: "+err.Error())
		return
	}

	writeSuccess(w, "Daftar project/nama bantuan berhasil diambil", list, nil)
}

// GetTahapHandler returns stages based on Jenis Bansos and selected IdProject
func (h *Handlers) GetTahapHandler(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := contextWithTimeout(r, 10*time.Second)
	defer cancel()

	jenis := r.URL.Query().Get("jenis")
	if jenis == "" {
		jenis = "NASIONAL"
	}

	projectId := r.URL.Query().Get("project_id")
	if projectId == "" {
		writeSuccess(w, "Daftar tahap kosong", []models.TahapRef{}, nil)
		return
	}

	list, err := h.refService.GetTahapByProject(ctx, jenis, projectId)
	if err != nil {
		slog.Error("failed to get tahap", "error", err, "jenis", jenis, "project_id", projectId)
		writeError(w, http.StatusInternalServerError, "Gagal mengambil daftar tahap: "+err.Error())
		return
	}

	writeSuccess(w, "Daftar tahap berhasil diambil", list, nil)
}

// GetKabupatenHandler returns list of kabupaten/kota from KABUPATEN1
func (h *Handlers) GetKabupatenHandler(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := contextWithTimeout(r, 10*time.Second)
	defer cancel()

	list, err := h.refService.GetAllKabupaten(ctx)
	if err != nil {
		slog.Error("failed to get kabupaten", "error", err)
		writeError(w, http.StatusInternalServerError, "Gagal mengambil daftar kabupaten: "+err.Error())
		return
	}

	writeSuccess(w, "Daftar kabupaten berhasil diambil", list, nil)
}

// GetKecamatanHandler returns list of kecamatan for a kabupaten from KECAMATAN1
func (h *Handlers) GetKecamatanHandler(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := contextWithTimeout(r, 10*time.Second)
	defer cancel()

	kabId := r.URL.Query().Get("kabupaten_id")
	if kabId == "" {
		writeError(w, http.StatusBadRequest, "Parameter 'kabupaten_id' (kode kabupaten) wajib diisi.")
		return
	}

	list, err := h.refService.GetKecamatanByKabupaten(ctx, kabId)
	if err != nil {
		slog.Error("failed to get kecamatan", "error", err, "kabId", kabId)
		writeError(w, http.StatusInternalServerError, "Gagal mengambil daftar kecamatan: "+err.Error())
		return
	}

	writeSuccess(w, "Daftar kecamatan berhasil diambil", list, nil)
}

// GetDesaHandler returns list of desa/kelurahan for a kecamatan (and kabupaten) from DESA1
func (h *Handlers) GetDesaHandler(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := contextWithTimeout(r, 10*time.Second)
	defer cancel()

	kecId := r.URL.Query().Get("kecamatan_id")
	if kecId == "" {
		writeError(w, http.StatusBadRequest, "Parameter 'kecamatan_id' (kode kecamatan) wajib diisi.")
		return
	}
	kabId := r.URL.Query().Get("kabupaten_id")

	list, err := h.refService.GetDesaByKecamatan(ctx, kecId, kabId)
	if err != nil {
		slog.Error("failed to get desa", "error", err, "kecId", kecId, "kabId", kabId)
		writeError(w, http.StatusInternalServerError, "Gagal mengambil daftar desa/kelurahan: "+err.Error())
		return
	}

	writeSuccess(w, "Daftar desa/kelurahan berhasil diambil", list, nil)
}

// GetKelurahanHandler provides backward-compatible endpoint for kelurahan
func (h *Handlers) GetKelurahanHandler(w http.ResponseWriter, r *http.Request) {
	h.GetDesaHandler(w, r)
}

// GetLayananHandler provides backward-compatible endpoint for layanan
func (h *Handlers) GetLayananHandler(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := contextWithTimeout(r, 10*time.Second)
	defer cancel()

	list, err := h.refService.GetLayanan(ctx)
	if err != nil {
		slog.Error("failed to get layanan", "error", err)
		writeError(w, http.StatusInternalServerError, "Gagal mengambil daftar jenis bansos: "+err.Error())
		return
	}

	writeSuccess(w, "Daftar jenis bantuan sosial berhasil diambil", list, nil)
}

// GetDanomHandler queries actual Danom recipients from database
func (h *Handlers) GetDanomHandler(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := contextWithTimeout(r, 30*time.Second)
	defer cancel()

	q := r.URL.Query()
	kelurahanId := q.Get("kelurahan_id")
	batch := q.Get("batch")
	projectId := q.Get("project_id")

	if kelurahanId == "" {
		writeError(w, http.StatusBadRequest, "Parameter 'kelurahan_id' (kode 10 digit desa) wajib diisi.")
		return
	}
	if batch == "" {
		writeError(w, http.StatusBadRequest, "Parameter 'batch' (tahap) wajib diisi.")
		return
	}
	if projectId == "" {
		projectId = "SPK1"
	}

	sort := q.Get("sort")
	if sort == "" {
		sort = "Nama"
	}

	nopend := q.Get("nopend")
	idPetugas := q.Get("id_petugas")
	nippos := q.Get("nippos")
	jenis := q.Get("jenis")
	if jenis == "" {
		jenis = "NASIONAL"
	}
	search := q.Get("search")

	page, _ := strconv.Atoi(q.Get("page"))
	pageSize, _ := strconv.Atoi(q.Get("page_size"))

	result, pagination, err := h.danomService.GetDanomList(
		ctx, kelurahanId, batch, projectId, sort, nopend, idPetugas, nippos, jenis, search, page, pageSize,
	)
	if err != nil {
		slog.Error("failed to get danom list", "error", err, "kelurahanId", kelurahanId, "batch", batch, "projectId", projectId)
		writeError(w, http.StatusInternalServerError, "Gagal mengambil data Danom: "+err.Error())
		return
	}

	writeSuccess(w, "Data Danom aktual berhasil diambil dari basis data SQL Server", result, pagination)
}

// InquiryNikHandler inquires a single NIK for CDS Bukti Terima
func (h *Handlers) InquiryNikHandler(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := contextWithTimeout(r, 10*time.Second)
	defer cancel()

	nik := r.URL.Query().Get("nik")
	if nik == "" {
		writeError(w, http.StatusBadRequest, "Parameter 'nik' wajib diisi.")
		return
	}

	recipient, err := h.danomService.InquiryNik(ctx, nik)
	if err != nil {
		slog.Error("failed to inquiry nik", "error", err, "nik", nik)
		writeError(w, http.StatusInternalServerError, "Gagal mencari data NIK: "+err.Error())
		return
	}

	if recipient == nil {
		writeError(w, http.StatusNotFound, "Data penerima bansos dengan NIK "+nik+" tidak ditemukan di basis data.")
		return
	}

	writeSuccess(w, "Data penerima bansos ditemukan", recipient, nil)
}

// Helpers
func contextWithTimeout(r *http.Request, d time.Duration) (rCtx context.Context, cancel context.CancelFunc) {
	return context.WithTimeout(r.Context(), d)
}

func writeJSON(w http.ResponseWriter, status int, data any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(data)
}

func writeSuccess[T any](w http.ResponseWriter, message string, data T, pagination *models.Pagination) {
	res := models.ApiResponse[T]{
		Success:    true,
		Message:    message,
		Data:       data,
		Pagination: pagination,
	}
	writeJSON(w, http.StatusOK, res)
}

func writeError(w http.ResponseWriter, status int, message string) {
	res := models.ApiResponse[any]{
		Success: false,
		Message: message,
		Data:    nil,
	}
	writeJSON(w, status, res)
}

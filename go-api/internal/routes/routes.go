package routes

import (
	"net/http"

	"cetakdanom/api/internal/handlers"
	"cetakdanom/api/internal/middleware"
)

func SetupRouter(h *handlers.Handlers) http.Handler {
	mux := http.NewServeMux()

	// Health check
	mux.HandleFunc("GET /api/v1/health", h.HealthHandler)

	// Auth endpoint
	mux.HandleFunc("POST /api/v1/auth/login", h.LoginHandler)

	// Reference endpoints
	mux.HandleFunc("GET /api/v1/reference/project", h.GetProjectHandler)
	mux.HandleFunc("GET /api/v1/reference/layanan", h.GetLayananHandler)
	mux.HandleFunc("GET /api/v1/reference/tahap", h.GetTahapHandler)
	mux.HandleFunc("GET /api/v1/reference/kabupaten", h.GetKabupatenHandler)
	mux.HandleFunc("GET /api/v1/reference/kecamatan", h.GetKecamatanHandler)
	mux.HandleFunc("GET /api/v1/reference/desa", h.GetDesaHandler)
	mux.HandleFunc("GET /api/v1/reference/kelurahan", h.GetKelurahanHandler)

	// Danom endpoints
	mux.HandleFunc("GET /api/v1/danom", h.GetDanomHandler)
	mux.HandleFunc("GET /api/v1/danom/inquiry", h.InquiryNikHandler)

	// Wrap in global middlewares
	var handler http.Handler = mux
	handler = middleware.LoggingMiddleware(handler)
	handler = middleware.CorsMiddleware(handler)
	handler = middleware.RecoveryMiddleware(handler)

	return handler
}

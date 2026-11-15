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

	// Reference endpoints
	mux.HandleFunc("GET /api/v1/reference/layanan", h.GetLayananHandler)
	mux.HandleFunc("GET /api/v1/reference/tahap", h.GetTahapHandler)
	mux.HandleFunc("GET /api/v1/reference/kabupaten", h.GetKabupatenHandler)
	mux.HandleFunc("GET /api/v1/reference/kecamatan", h.GetKecamatanHandler)
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

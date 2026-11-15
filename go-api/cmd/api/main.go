package main

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"cetakdanom/api/internal/config"
	"cetakdanom/api/internal/database"
	"cetakdanom/api/internal/handlers"
	"cetakdanom/api/internal/repositories"
	"cetakdanom/api/internal/routes"
	"cetakdanom/api/internal/services"
)

func main() {
	// 1. Structured logging
	logger := slog.New(slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelInfo,
	}))
	slog.SetDefault(logger)

	slog.Info("starting CetakDanom Go REST API service...")

	// 2. Load configuration from environment / .env
	cfg := config.LoadConfig()

	// 3. Connect to SQL Server database
	db, err := database.Connect(cfg)
	if err != nil {
		slog.Error("fatal database connection error", "error", err)
		os.Exit(1)
	}
	defer db.Close()

	// 4. Initialize repository & service layers
	refRepo := repositories.NewReferenceRepository(db.SQL)
	danomRepo := repositories.NewDanomRepository(db.SQL)

	refService := services.NewReferenceService(refRepo)
	danomService := services.NewDanomService(danomRepo)

	// 5. Initialize handlers & routes
	h := handlers.NewHandlers(db, refService, danomService)
	router := routes.SetupRouter(h)

	// 6. Start HTTP Server
	serverAddr := fmt.Sprintf(":%s", cfg.AppPort)
	srv := &http.Server{
		Addr:         serverAddr,
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 45 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Channel to listen for errors from ListenAndServe
	serverErrors := make(chan error, 1)

	go func() {
		slog.Info("server listening and serving requests", "addr", "http://localhost"+serverAddr)
		serverErrors <- srv.ListenAndServe()
	}()

	// Channel to listen for interrupt signals for graceful shutdown
	shutdown := make(chan os.Signal, 1)
	signal.Notify(shutdown, os.Interrupt, syscall.SIGTERM)

	// Block until signal or error
	select {
	case err := <-serverErrors:
		if !errors.Is(err, http.ErrServerClosed) {
			slog.Error("server error", "error", err)
		}
	case sig := <-shutdown:
		slog.Info("shutdown signal received", "signal", sig.String())

		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		if err := srv.Shutdown(ctx); err != nil {
			slog.Error("failed to gracefully shutdown server", "error", err)
			_ = srv.Close()
		}
		slog.Info("server stopped gracefully")
	}
}

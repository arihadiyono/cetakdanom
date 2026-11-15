package database

import (
	"context"
	"database/sql"
	"fmt"
	"log/slog"
	"net/url"
	"time"

	"cetakdanom/api/internal/config"
	_ "github.com/microsoft/go-mssqldb"
)

type DB struct {
	SQL *sql.DB
}

func Connect(cfg *config.Config) (*DB, error) {
	// Construct connection URL for go-mssqldb
	query := url.Values{}
	query.Add("database", cfg.DBName)
	query.Add("encrypt", cfg.DBEncrypt)
	query.Add("trustServerCertificate", cfg.DBTrustServerCertificate)
	query.Add("app name", "CetakDanomGoAPI")
	query.Add("connection timeout", "15")

	u := &url.URL{
		Scheme:   "sqlserver",
		User:     url.UserPassword(cfg.DBUser, cfg.DBPassword),
		Host:     fmt.Sprintf("%s:%s", cfg.DBHost, cfg.DBPort),
		RawQuery: query.Encode(),
	}

	// Safe connection string for logging (masking password)
	maskedUser := url.UserPassword(cfg.DBUser, "******")
	maskedURL := *u
	maskedURL.User = maskedUser
	slog.Info("connecting to database", "target", maskedURL.String())

	conn, err := sql.Open("sqlserver", u.String())
	if err != nil {
		return nil, fmt.Errorf("failed to initialize db connection pool: %w", err)
	}

	conn.SetMaxOpenConns(cfg.DBMaxOpenConns)
	conn.SetMaxIdleConns(cfg.DBMaxIdleConns)
	conn.SetConnMaxLifetime(cfg.DBConnMaxLifetime)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := conn.PingContext(ctx); err != nil {
		conn.Close()
		return nil, fmt.Errorf("failed to ping database at %s:%s (%s): %w", cfg.DBHost, cfg.DBPort, cfg.DBName, err)
	}

	slog.Info("database connection established successfully", 
		"host", cfg.DBHost, 
		"database", cfg.DBName, 
		"max_open_conns", cfg.DBMaxOpenConns,
	)

	return &DB{SQL: conn}, nil
}

func (db *DB) Close() error {
	if db.SQL != nil {
		return db.SQL.Close()
	}
	return nil
}

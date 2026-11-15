package config

import (
	"bufio"
	"os"
	"strconv"
	"strings"
	"time"
)

type Config struct {
	AppEnv  string
	AppPort string

	DBHost                  string
	DBPort                  string
	DBName                  string
	DBUser                  string
	DBPassword              string
	DBEncrypt               string
	DBTrustServerCertificate string

	DBMaxOpenConns    int
	DBMaxIdleConns    int
	DBConnMaxLifetime time.Duration
	DBQueryTimeout    time.Duration
}

func LoadConfig() *Config {
	// Try loading .env if present
	loadDotEnv(".env")

	cfg := &Config{
		AppEnv:  getEnv("APP_ENV", "development"),
		AppPort: getEnv("APP_PORT", "8080"),

		DBHost:                  getEnv("DB_HOST", "10.29.41.125"),
		DBPort:                  getEnv("DB_PORT", "1433"),
		DBName:                  getEnv("DB_NAME", "DB_BLT"),
		DBUser:                  getEnv("DB_USER", "bangtek"),
		DBPassword:              getEnv("DB_PASSWORD", "p@ss2020"),
		DBEncrypt:               getEnv("DB_ENCRYPT", "disable"),
		DBTrustServerCertificate: getEnv("DB_TRUST_SERVER_CERTIFICATE", "true"),

		DBMaxOpenConns:    getEnvInt("DB_MAX_OPEN_CONNS", 15),
		DBMaxIdleConns:    getEnvInt("DB_MAX_IDLE_CONNS", 5),
		DBConnMaxLifetime: getEnvDuration("DB_CONN_MAX_LIFETIME", 30*time.Minute),
		DBQueryTimeout:    getEnvDuration("DB_QUERY_TIMEOUT", 30*time.Second),
	}

	return cfg
}

func getEnv(key, defaultVal string) string {
	if val, ok := os.LookupEnv(key); ok && val != "" {
		return val
	}
	return defaultVal
}

func getEnvInt(key string, defaultVal int) int {
	if val, ok := os.LookupEnv(key); ok {
		if i, err := strconv.Atoi(val); err == nil {
			return i
		}
	}
	return defaultVal
}

func getEnvDuration(key string, defaultVal time.Duration) time.Duration {
	if val, ok := os.LookupEnv(key); ok {
		if d, err := time.ParseDuration(val); err == nil {
			return d
		}
	}
	return defaultVal
}

func loadDotEnv(filepath string) {
	file, err := os.Open(filepath)
	if err != nil {
		return
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		parts := strings.SplitN(line, "=", 2)
		if len(parts) == 2 {
			k := strings.TrimSpace(parts[0])
			v := strings.TrimSpace(parts[1])
			v = strings.Trim(v, `"'`)
			if _, exists := os.LookupEnv(k); !exists {
				os.Setenv(k, v)
			}
		}
	}
}

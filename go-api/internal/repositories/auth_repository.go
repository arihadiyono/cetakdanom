package repositories

import (
	"context"
	"crypto/md5"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"strings"
	"time"

	"cetakdanom/api/internal/models"
)

var (
	ErrUserNotFound     = errors.New("User ID tidak terdaftar")
	ErrInvalidPassword  = errors.New("Password salah")
	ErrUserInactive     = errors.New("Status user tidak aktif")
)

type AuthRepository struct {
	db *sql.DB
}

func NewAuthRepository(db *sql.DB) *AuthRepository {
	return &AuthRepository{db: db}
}

func (r *AuthRepository) Authenticate(ctx context.Context, username, password string) (*models.LoginResponse, error) {
	username = strings.TrimSpace(username)
	if username == "" {
		return nil, errors.New("User ID harus diisi")
	}

	query := `
		SELECT 
			RTRIM(p.ID_PETUGAS) AS ID_PETUGAS,
			RTRIM(p.PASS_PETUGAS) AS PASS_PETUGAS,
			ISNULL(RTRIM(p.ID_KANTOR), '') AS ID_KANTOR,
			ISNULL(RTRIM(k.KET_KANTOR), '') AS KET_KANTOR,
			ISNULL(RTRIM(p.ID_PEGAWAI), '') AS ID_PEGAWAI,
			ISNULL(RTRIM(p.ID_JABATAN), '') AS ID_JABATAN,
			ISNULL(RTRIM(p.ID_STATUS), '') AS ID_STATUS
		FROM TPETUGAS p
		LEFT JOIN TKANTOR k ON p.ID_KANTOR = k.ID_KANTOR
		WHERE RTRIM(p.ID_PETUGAS) = @p1
	`

	var idPetugas, passHash, idKantor, ketKantor, idPegawai, idJabatan, idStatus string
	err := r.db.QueryRowContext(ctx, query, sql.Named("p1", username)).Scan(
		&idPetugas,
		&passHash,
		&idKantor,
		&ketKantor,
		&idPegawai,
		&idJabatan,
		&idStatus,
	)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, ErrUserNotFound
		}
		return nil, fmt.Errorf("error querying TPETUGAS: %w", err)
	}

	// Verify Password Hash:
	// Delphi formula: StrToMD5(UserId + Password)
	hashDelphi := md5Hex(username + password)
	hashRaw := md5Hex(password)

	passHash = strings.ToLower(strings.TrimSpace(passHash))
	if passHash != hashDelphi && passHash != hashRaw {
		return nil, ErrInvalidPassword
	}

	// Name display logic
	nama := idPetugas
	if idPegawai != "" && idPegawai != "000000000" {
		nama = fmt.Sprintf("%s (%s)", idPetugas, idPegawai)
	}

	token := fmt.Sprintf("petugas_%s_%d", idPetugas, time.Now().UnixNano())

	return &models.LoginResponse{
		IdPetugas: idPetugas,
		Nippos:    idPegawai,
		Nama:      nama,
		Nopend:    idKantor,
		Kantor:    ketKantor,
		Jabatan:   idJabatan,
		Status:    idStatus,
		Token:     token,
	}, nil
}

func md5Hex(s string) string {
	h := md5.Sum([]byte(s))
	return hex.EncodeToString(h[:])
}
